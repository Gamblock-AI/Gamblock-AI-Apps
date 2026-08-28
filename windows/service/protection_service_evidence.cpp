#include "protection_service.h"

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <regex>
#include <sstream>

#include "service_support.h"

namespace gamblock {
namespace {

constexpr std::uintmax_t kMaximumEvidenceBytes = 5ULL * 1024ULL * 1024ULL;
constexpr size_t kMaximumPendingSamples = 256;
constexpr auto kPendingSampleLifetime = std::chrono::minutes(2);
const std::regex kSafeLabel("^[A-Za-z0-9_-]{1,64}$");

struct Phase4Config {
  std::string run_id;
  std::string device_alias;
  std::string scenario;
};

std::optional<Phase4Config> ReadPhase4Config() {
  const auto value =
      ReadTextFile(DataDirectory() / L"phase4-evidence" / L"config.json");
  if (!value)
    return std::nullopt;
  const auto run_id = JsonString(*value, "run_id");
  const auto device_alias = JsonString(*value, "device_alias");
  const auto scenario = JsonString(*value, "scenario");
  if (!run_id || !device_alias || !scenario ||
      !std::regex_match(*run_id, kSafeLabel) ||
      !std::regex_match(*device_alias, kSafeLabel) ||
      !std::regex_match(*scenario, kSafeLabel)) {
    return std::nullopt;
  }
  return Phase4Config{*run_id, *device_alias, *scenario};
}

double Milliseconds(std::chrono::steady_clock::duration duration) {
  return std::chrono::duration<double, std::milli>(duration).count();
}

} // namespace

std::string ProtectionService::BeginPhase4Latency(
    std::chrono::steady_clock::time_point input_ready,
    double pre_input_duration_ms, double extraction_duration_ms,
    double queue_duration_ms, double classification_duration_ms,
    const ClassificationDecision &decision) {
  const auto config = ReadPhase4Config();
  if (!config)
    return {};

  const auto now = std::chrono::steady_clock::now();
  std::lock_guard lock(phase4_evidence_mutex_);
  for (auto sample = pending_phase4_latency_.begin();
       sample != pending_phase4_latency_.end();) {
    if (now - sample->second.input_ready > kPendingSampleLifetime) {
      sample = pending_phase4_latency_.erase(sample);
    } else {
      ++sample;
    }
  }
  if (pending_phase4_latency_.size() >= kMaximumPendingSamples)
    return {};

  const std::string evidence_id =
      "windows_" + std::to_string(GetTickCount64()) + "_" +
      std::to_string(phase4_evidence_sequence_.fetch_add(1));
  pending_phase4_latency_.emplace(
      evidence_id,
      PendingPhase4Latency{
          input_ready,
          std::clamp(pre_input_duration_ms, 0.0, 10000.0),
          std::clamp(extraction_duration_ms, 0.0, 10000.0),
          std::clamp(queue_duration_ms, 0.0, 10000.0),
          std::clamp(classification_duration_ms, 0.0, 10000.0),
          std::clamp(decision.preprocessing_duration_ms, 0.0, 10000.0),
          std::clamp(decision.rule_duration_ms, 0.0, 10000.0),
          std::clamp(decision.inference_duration_ms, 0.0, 10000.0),
          std::clamp(decision.decision_duration_ms, 0.0, 10000.0),
          config->run_id,
          config->device_alias,
          config->scenario,
          decision.model_version,
          decision.ruleset_version,
      });
  return evidence_id;
}

void ProtectionService::CompletePhase4Latency(const std::string &evidence_id,
                                              const std::string &outcome,
                                              bool block_succeeded,
                                              double block_action_duration_ms) {
  PendingPhase4Latency sample;
  {
    std::lock_guard lock(phase4_evidence_mutex_);
    const auto found = pending_phase4_latency_.find(evidence_id);
    if (found == pending_phase4_latency_.end())
      return;
    sample = found->second;
    pending_phase4_latency_.erase(found);
  }

  const double input_to_visible_ms = std::max(
      0.0, Milliseconds(std::chrono::steady_clock::now() - sample.input_ready));
  const double relay_ms = std::max(0.0, sample.pre_input_duration_ms -
                                            sample.extraction_duration_ms);
  const double dispatch_to_visible_ms =
      std::max(0.0, input_to_visible_ms - sample.queue_duration_ms -
                        sample.classification_duration_ms);
  const double scan_to_visible_ms =
      sample.pre_input_duration_ms + input_to_visible_ms;

  const auto directory = DataDirectory() / L"phase4-evidence";
  std::error_code error;
  std::filesystem::create_directories(directory, error);
  if (error)
    return;
  const auto path = directory / L"latency.jsonl";
  if (std::filesystem::exists(path, error) && !error &&
      std::filesystem::file_size(path, error) >= kMaximumEvidenceBytes) {
    return;
  }

  std::ofstream output(path, std::ios::app | std::ios::binary);
  if (!output)
    return;
  output << std::fixed << std::setprecision(3)
         << "{\"schema_version\":2,\"platform\":\"windows\","
         << "\"run_id\":\"" << EscapeJson(sample.run_id) << "\","
         << "\"sample_id\":\"" << EscapeJson(evidence_id) << "\","
         << "\"device_alias\":\"" << EscapeJson(sample.device_alias) << "\","
         << "\"scenario\":\"" << EscapeJson(sample.scenario) << "\","
         << "\"model_version\":\"" << EscapeJson(sample.model_version) << "\","
         << "\"ruleset_version\":\"" << EscapeJson(sample.ruleset_version)
         << "\","
         << "\"outcome\":\"" << EscapeJson(outcome) << "\","
         << "\"presentation_path\":\"native_shell_flutter\","
         << "\"block_succeeded\":" << (block_succeeded ? "true" : "false")
         << ',' << "\"extraction_ms\":" << sample.extraction_duration_ms << ','
         << "\"relay_ms\":" << relay_ms << ','
         << "\"queue_ms\":" << sample.queue_duration_ms << ','
         << "\"preprocessing_ms\":" << sample.preprocessing_duration_ms << ','
         << "\"rule_ms\":" << sample.rule_duration_ms << ','
         << "\"inference_ms\":" << sample.inference_duration_ms << ','
         << "\"decision_ms\":" << sample.decision_duration_ms << ','
         << "\"classification_ms\":" << sample.classification_duration_ms << ','
         << "\"block_action_ms\":"
         << std::clamp(block_action_duration_ms, 0.0, 10000.0) << ','
         << "\"dispatch_to_visible_ms\":" << dispatch_to_visible_ms << ','
         << "\"input_to_visible_ms\":" << input_to_visible_ms << ','
         << "\"scan_to_visible_ms\":" << scan_to_visible_ms << "}\n";
}

} // namespace gamblock
