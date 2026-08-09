#include "protection_service.h"

#include <algorithm>
#include <array>
#include <filesystem>
#include <fstream>
#include <sstream>

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
}  // namespace

std::string ProtectionService::SnapshotJson(const std::string& request_id) {
  std::lock_guard lock(state_mutex_);
  const bool connected = sensor_connections_.load() > 0;
  const bool active = classifier_.loaded();
  const bool paused = HasActiveGrant();
  std::ostringstream snapshot;
  snapshot << "{\"type\":\""
           << (request_id.empty() ? "protection_status" : "response") << "\"";
  if (!request_id.empty()) {
    snapshot << ",\"request_id\":\"" << EscapeJson(request_id) << "\"";
  }
  snapshot << ",\"platform\":\"windows\",\"status\":\""
           << (paused ? "paused" : (active && connected ? "active" : "degraded"))
           << "\",\"service_running\":true,\"sensor_status\":\""
           << (connected ? "connected" : "disconnected")
           << "\",\"permission_status\":\"granted\",\"model_version\":\""
           << EscapeJson(classifier_.model_version())
           << "\",\"ruleset_version\":\""
           << EscapeJson(classifier_.ruleset_version()) << "\"";
  if (!active) {
    snapshot << ",\"degraded_reason_code\":\"artifact_invalid\"";
  } else if (!connected) {
    snapshot << ",\"degraded_reason_code\":\"browser_sensor_disconnected\"";
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

bool ProtectionService::StoreGrant(const std::string& grant_json) {
  const auto action = JsonString(grant_json, "action");
  const auto grant_device = JsonString(grant_json, "device_id");
  const auto expiry = JsonString(grant_json, "grant_expires_at");
  if (!action || !grant_device || device_id_.empty() ||
      *grant_device != device_id_ || !expiry || !IsFuture(*expiry)) return false;
  const std::array<std::string, 4> allowed = {
      "pause_protection", "disable_protection", "uninstall_detected",
      "emergency_access"};
  if (std::find(allowed.begin(), allowed.end(), *action) == allowed.end()) {
    return false;
  }
  return WriteProtected(DataDirectory() / L"active-grant.bin", grant_json);
}

bool ProtectionService::HasActiveGrant(const char* purpose) {
  const auto path = DataDirectory() / L"active-grant.bin";
  const auto grant = ReadProtected(path);
  if (!grant) return false;
  const auto action = JsonString(*grant, "action");
  const auto grant_device = JsonString(*grant, "device_id");
  const auto expiry = JsonString(*grant, "grant_expires_at");
  if (!action || !grant_device || *grant_device != device_id_ ||
      !expiry || !IsFuture(*expiry)) {
    std::error_code error;
    std::filesystem::remove(path, error);
    return false;
  }
  if (purpose == nullptr) return true;
  if (std::string(purpose) == "uninstall") {
    return *action == "uninstall_detected" || *action == "emergency_access";
  }
  return *action == "disable_protection" || *action == "uninstall_detected" ||
         *action == "emergency_access";
}

void ProtectionService::IncrementAggregate(const std::string& type) {
  static const std::array<std::string, 6> allowed = {
      "intervention_shown", "block_count_sync", "tamper_detected",
      "permission_revoked", "model_updated", "ruleset_updated"};
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
