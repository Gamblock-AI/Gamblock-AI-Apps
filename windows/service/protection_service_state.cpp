#include "protection_service.h"

#include <algorithm>
#include <array>
#include <filesystem>
#include <fstream>
#include <sstream>

#include "device_key.h"
#include "grant_trust_store.h"
#include "grant_verifier.h"
#include "service_support.h"

namespace gamblock {

namespace {
// Local wall-clock hour (0-23). Hourly aggregate histograms are recorded in
// the service host's local time so "jam rawan" reflects the user's own peak
// hours. The values remain aggregate counts with no browsing content.
int LocalHour() {
  SYSTEMTIME time{};
  GetLocalTime(&time);
  return static_cast<int>(time.wHour);
}

std::int64_t EpochSeconds() {
  return std::chrono::duration_cast<std::chrono::seconds>(
             std::chrono::system_clock::now().time_since_epoch())
      .count();
}

bool ValidDeviceId(const std::string& value) {
  if (value.empty() || value.size() > 256) return false;
  for (const unsigned char character : value) {
    if ((character >= 'a' && character <= 'z') ||
        (character >= 'A' && character <= 'Z') ||
        (character >= '0' && character <= '9') || character == '-' ||
        character == '_' || character == '.' || character == ':') {
      continue;
    }
    return false;
  }
  return true;
}

std::string GrantIdDigest(const std::string& token_id) {
  return Sha256Bytes(std::vector<unsigned char>(token_id.begin(),
                                                token_id.end()));
}

std::map<std::string, std::int64_t> ReadConsumedGrants(std::int64_t now) {
  std::map<std::string, std::int64_t> grants;
  const auto protected_value =
      ReadProtected(DataDirectory() / L"consumed-grants.bin");
  if (!protected_value) return grants;
  std::istringstream input(*protected_value);
  std::string digest;
  std::int64_t expires_at = 0;
  while (input >> digest >> expires_at) {
    if (digest.size() == 64 && expires_at > now) grants[digest] = expires_at;
  }
  return grants;
}

bool WriteConsumedGrants(const std::map<std::string, std::int64_t>& grants) {
  std::ostringstream output;
  for (const auto& [digest, expires_at] : grants) {
    output << digest << ' ' << expires_at << '\n';
  }
  return WriteProtected(DataDirectory() / L"consumed-grants.bin",
                        output.str());
}

bool IsConsumedGrant(const std::string& token_id, std::int64_t now) {
  const std::string digest = GrantIdDigest(token_id);
  if (digest.size() != 64) return true;
  const auto grants = ReadConsumedGrants(now);
  return grants.find(digest) != grants.end();
}

bool RecordConsumedGrant(const std::string& token_id,
                         std::int64_t expires_at,
                         std::int64_t now) {
  const std::string digest = GrantIdDigest(token_id);
  if (digest.size() != 64) return false;
  auto grants = ReadConsumedGrants(now);
  grants[digest] = expires_at;
  if (grants.size() > 256) {
    const auto oldest = std::min_element(
        grants.begin(), grants.end(), [](const auto& left, const auto& right) {
          return left.second < right.second;
        });
    if (oldest != grants.end()) grants.erase(oldest);
  }
  return WriteConsumedGrants(grants);
}
}  // namespace

std::string ProtectionService::SnapshotJson(const std::string& request_id) {
  std::lock_guard lock(state_mutex_);
  const bool connected = sensor_connections_.load() > 0;
  const bool active = classifier_.loaded();
  const bool paused = HasActiveGrant();
  const bool block_action_degraded = block_action_degraded_.load();
  std::ostringstream snapshot;
  snapshot << "{\"type\":\""
           << (request_id.empty() ? "protection_status" : "response") << "\"";
  if (!request_id.empty()) {
    snapshot << ",\"request_id\":\"" << EscapeJson(request_id) << "\"";
  }
  snapshot << ",\"platform\":\"windows\",\"status\":\""
           << (paused ? "paused"
                      : (active && connected && !block_action_degraded
                             ? "active"
                             : "degraded"))
           << "\",\"service_running\":true,\"sensor_status\":\""
           << (connected ? "connected" : "disconnected")
           << "\",\"permission_status\":\"granted\",\"model_version\":\""
           << EscapeJson(classifier_.model_version())
           << "\",\"ruleset_version\":\""
           << EscapeJson(classifier_.ruleset_version())
           << "\",\"supports_controlled_removal\":true";
  if (!active) {
    snapshot << ",\"degraded_reason_code\":\"artifact_invalid\"";
  } else if (!connected) {
    snapshot << ",\"degraded_reason_code\":\"browser_sensor_disconnected\"";
  } else if (block_action_degraded) {
    snapshot << ",\"degraded_reason_code\":\"browser_block_action_failed\"";
  }
  snapshot << '}';
  return snapshot.str();
}

std::string ProtectionService::PairingToken(bool rotate) {
  const auto path = DataDirectory() / L"pairing-token.bin";
  if (!rotate) {
    const auto existing = ReadProtected(path);
    if (existing && existing->size() == 64) return *existing;
  }
  const std::string token = Hex(RandomBytes(32));
  if (token.size() != 64 || !WriteProtected(path, token)) return {};
  if (rotate) {
    std::lock_guard lock(client_mutex_);
    for (const SOCKET client : authenticated_clients_) shutdown(client, SD_BOTH);
  }
  return token;
}

bool ProtectionService::LoadDeviceId(const std::string& device_id) {
  if (!ValidDeviceId(device_id)) return false;
  std::lock_guard lock(device_mutex_);
  if (!device_id_.empty()) return ConstantTimeEqual(device_id_, device_id);
  device_id_ = device_id;
  return true;
}

bool ProtectionService::SetDeviceId(const std::string& device_id) {
  if (!ValidDeviceId(device_id)) return false;
  std::lock_guard lock(device_mutex_);
  if (!device_id_.empty()) return ConstantTimeEqual(device_id_, device_id);
  if (!WriteProtected(DataDirectory() / L"device-id.bin", device_id)) {
    return false;
  }
  device_id_ = device_id;
  return true;
}

std::string ProtectionService::GrantKeyEnrollmentJson(
    const std::string& request_id,
    const std::string& device_id,
    const std::string& challenge_token) {
  {
    std::lock_guard lock(device_mutex_);
    if (device_id_.empty() ||
        !ConstantTimeEqual(device_id_, device_id)) {
      return "{\"type\":\"response\",\"request_id\":\"" +
             EscapeJson(request_id) +
             "\",\"ok\":false,\"error_code\":\"device_binding_mismatch\"}";
    }
  }
  std::string error;
  const auto enrollment =
      CreateGrantKeyEnrollment(device_id, challenge_token, &error);
  if (!enrollment) {
    return "{\"type\":\"response\",\"request_id\":\"" +
           EscapeJson(request_id) + "\",\"ok\":false,\"error_code\":\"" +
           EscapeJson(error) + "\"}";
  }
  return "{\"type\":\"response\",\"request_id\":\"" +
         EscapeJson(request_id) +
         "\",\"ok\":true,\"public_jwk\":\"" +
         EscapeJson(enrollment->public_jwk) + "\",\"jwk_thumbprint\":\"" +
         EscapeJson(enrollment->jwk_thumbprint) + "\",\"proof\":\"" +
         EscapeJson(enrollment->proof) + "\"}";
}

bool ProtectionService::StoreGrant(const std::string& compact_jws) {
  std::string device_id;
  {
    std::lock_guard lock(device_mutex_);
    device_id = device_id_;
  }
  const auto thumbprint = ExistingGrantKeyThumbprint();
  const std::int64_t now = EpochSeconds();
  const auto grant = device_id.empty() || !thumbprint
                         ? std::nullopt
                         : VerifyProtectionGrant(
                               compact_jws, kProtectionGrantTrustStoreBase64,
                               device_id, *thumbprint, now);
  std::lock_guard lock(grant_mutex_);
  if (!grant || IsConsumedGrant(grant->token_id, now) ||
      !WriteProtected(DataDirectory() / L"active-grant.bin", compact_jws)) {
    return false;
  }
  active_grant_action_ = grant->action;
  active_grant_token_id_ = grant->token_id;
  active_grant_expires_at_ = grant->expires_at;
  const auto remaining_seconds = std::min(grant->expires_at - now,
                                          grant->expires_at - grant->issued_at);
  active_grant_deadline_ = std::chrono::steady_clock::now() +
                           std::chrono::seconds(remaining_seconds);
  return true;
}

bool ProtectionService::HasActiveGrant(const char* purpose) {
  return CheckActiveGrant(purpose, false);
}

bool ProtectionService::ConsumeActiveGrant(const char* purpose) {
  return CheckActiveGrant(purpose, true);
}

bool ProtectionService::CheckActiveGrant(const char* purpose, bool consume) {
  const auto allowed_for_purpose = [purpose](const std::string& action) {
    if (purpose != nullptr && std::string(purpose) == "uninstall") {
      return action == "uninstall_detected" || action == "emergency_access";
    }
    return action == "pause_protection" || action == "emergency_access";
  };
  const std::int64_t now = EpochSeconds();
  const auto monotonic_now = std::chrono::steady_clock::now();
  std::lock_guard grant_lock(grant_mutex_);
  if (!active_grant_action_.empty() && now < active_grant_expires_at_ &&
      monotonic_now < active_grant_deadline_) {
    if (!allowed_for_purpose(active_grant_action_)) return false;
    if (!consume) return true;
    if (active_grant_token_id_.empty() ||
        !RecordConsumedGrant(active_grant_token_id_, active_grant_expires_at_,
                             now)) {
      return false;
    }
    active_grant_action_.clear();
    active_grant_token_id_.clear();
    active_grant_expires_at_ = 0;
    active_grant_deadline_ = {};
    std::error_code error;
    std::filesystem::remove(DataDirectory() / L"active-grant.bin", error);
    return true;
  }
  active_grant_action_.clear();
  active_grant_token_id_.clear();
  active_grant_expires_at_ = 0;
  active_grant_deadline_ = {};

  const auto path = DataDirectory() / L"active-grant.bin";
  const auto compact_jws = ReadProtected(path);
  std::string device_id;
  {
    std::lock_guard lock(device_mutex_);
    device_id = device_id_;
  }
  const auto thumbprint = ExistingGrantKeyThumbprint();
  const auto grant = compact_jws && thumbprint
                         ? VerifyProtectionGrant(
                               *compact_jws, kProtectionGrantTrustStoreBase64,
                               device_id, *thumbprint, now)
                         : std::nullopt;
  if (!grant || IsConsumedGrant(grant->token_id, now)) {
    std::error_code error;
    std::filesystem::remove(path, error);
    return false;
  }
  active_grant_action_ = grant->action;
  active_grant_token_id_ = grant->token_id;
  active_grant_expires_at_ = grant->expires_at;
  const auto remaining_seconds = std::min(grant->expires_at - now,
                                          grant->expires_at - grant->issued_at);
  active_grant_deadline_ = monotonic_now +
                           std::chrono::seconds(remaining_seconds);
  if (!allowed_for_purpose(active_grant_action_)) return false;
  if (!consume) return true;
  if (!RecordConsumedGrant(active_grant_token_id_, active_grant_expires_at_,
                           now)) {
    return false;
  }
  active_grant_action_.clear();
  active_grant_token_id_.clear();
  active_grant_expires_at_ = 0;
  active_grant_deadline_ = {};
  std::error_code error;
  std::filesystem::remove(path, error);
  return true;
}

void ProtectionService::IncrementAggregate(const std::string& type) {
  static const std::array<std::string, 4> allowed = {
      "intervention_shown", "block_count_sync", "tamper_detected",
      "permission_revoked"};
  if (std::find(allowed.begin(), allowed.end(), type) == allowed.end()) return;
  static const std::array<std::string, 2> hourly_types = {
      "block_count_sync", "intervention_shown"};
  const bool hourly =
      std::find(hourly_types.begin(), hourly_types.end(), type) !=
      hourly_types.end();
  std::lock_guard lock(aggregate_mutex_);
  const std::string date = UtcDate();
  ++aggregates_[date + ":" + type];
  if (hourly) {
    ++aggregates_[date + ":" + type + ":" + std::to_string(LocalHour())];
  }
  std::ofstream file(DataDirectory() / L"aggregates.txt", std::ios::trunc);
  for (const auto& [key, count] : aggregates_) file << key << ' ' << count << '\n';
}

std::string ProtectionService::AggregatesJson(const std::string& request_id,
                                              bool completed_only) {
  std::lock_guard lock(aggregate_mutex_);
  const std::string today = UtcDate();
  const auto hourly_array = [this](const std::string& date,
                                   const std::string& event_type) {
    std::ostringstream out;
    out << '[';
    for (int hour = 0; hour < 24; ++hour) {
      if (hour) out << ',';
      const auto it = aggregates_.find(
          date + ":" + event_type + ":" + std::to_string(hour));
      out << (it == aggregates_.end() ? 0 : it->second);
    }
    out << ']';
    return out.str();
  };
  std::ostringstream response;
  response << "{\"type\":\"response\",\"request_id\":\""
           << EscapeJson(request_id) << "\",\"items\":[";
  bool first = true;
  for (const auto& [key, count] : aggregates_) {
    const auto separator = key.find(':');
    if (separator == std::string::npos) continue;
    const std::string date = key.substr(0, separator);
    if ((completed_only && date >= today) || (!completed_only && date != today)) {
      continue;
    }
    const std::string remainder = key.substr(separator + 1);
    if (remainder.find(':') != std::string::npos) continue;
    if (!first) response << ',';
    first = false;
    response << "{\"key\":\"" << EscapeJson(key) << "\",\"date\":\""
             << date << "\",\"event_type\":\""
             << EscapeJson(remainder) << "\",\"count\":" << count
             << ",\"hourly\":" << hourly_array(date, remainder) << '}';
  }
  response << "]}";
  return response.str();
}

void ProtectionService::AcknowledgeAggregates(const std::string& command) {
  const auto keys = JsonStringArray(command, "keys", 128, 64);
  std::lock_guard lock(aggregate_mutex_);
  for (const auto& key : keys) {
    aggregates_.erase(key);
    for (int hour = 0; hour < 24; ++hour) {
      aggregates_.erase(key + ":" + std::to_string(hour));
    }
  }
  std::ofstream file(DataDirectory() / L"aggregates.txt", std::ios::trunc);
  for (const auto& [key, count] : aggregates_) file << key << ' ' << count << '\n';
}

}  // namespace gamblock
