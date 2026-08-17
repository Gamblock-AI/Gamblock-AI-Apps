#include "protection_service.h"

#include <chrono>
#include <sstream>

#include "service_support.h"

namespace gamblock {
namespace {

constexpr auto kInterventionLifetime = std::chrono::seconds(30);

std::string InterventionJson(const std::string& intervention_id,
                             const std::string& reason_code,
                             const std::string& model_version,
                             const std::string& ruleset_version) {
  std::ostringstream event;
  event << "{\"type\":\"intervention_required\",\"intervention_id\":\""
        << EscapeJson(intervention_id)
        << "\",\"reason_code\":\"" << EscapeJson(reason_code)
        << "\",\"model_version\":\"" << EscapeJson(model_version)
        << "\",\"ruleset_version\":\""
        << EscapeJson(ruleset_version) << "\"}";
  return event.str();
}

}  // namespace

std::optional<std::string> ProtectionService::BeginIntervention(
    std::chrono::steady_clock::time_point input_ready,
    double pre_input_duration_ms,
    double extraction_duration_ms,
    double queue_duration_ms,
    double classification_duration_ms,
    const ClassificationDecision& decision) {
  const auto now = std::chrono::steady_clock::now();
  std::lock_guard lock(intervention_mutex_);
  if (pending_intervention_ && now < pending_intervention_->deadline) {
    return std::nullopt;
  }
  pending_intervention_.reset();

  const std::string intervention_id = Hex(RandomBytes(16));
  if (intervention_id.size() != 32) return std::nullopt;
  const std::string evidence_id = BeginPhase4Latency(
      input_ready, pre_input_duration_ms, extraction_duration_ms,
      queue_duration_ms, classification_duration_ms, decision);
  pending_intervention_ = PendingIntervention{
      intervention_id,
      decision.reason_code,
      decision.model_version,
      decision.ruleset_version,
      evidence_id,
      now + kInterventionLifetime,
      false,
      false,
  };
  return InterventionJson(
      pending_intervention_->intervention_id,
      pending_intervention_->reason_code,
      pending_intervention_->model_version,
      pending_intervention_->ruleset_version);
}

void ProtectionService::FlushPendingIntervention() {
  std::string event;
  {
    std::lock_guard lock(intervention_mutex_);
    if (!pending_intervention_) return;
    if (std::chrono::steady_clock::now() >= pending_intervention_->deadline) {
      event = "{\"type\":\"intervention_completed\","
              "\"intervention_id\":\"" +
              EscapeJson(pending_intervention_->intervention_id) +
              "\",\"completion_reason\":\"expired\"}";
      pending_intervention_.reset();
    } else {
      event = InterventionJson(
          pending_intervention_->intervention_id,
          pending_intervention_->reason_code,
          pending_intervention_->model_version,
          pending_intervention_->ruleset_version);
    }
  }
  SendAgentEvent(event);
}

bool ProtectionService::AcknowledgeInterventionVisible(
    const std::string& intervention_id) {
  std::string evidence_id;
  bool first_acknowledgement = false;
  {
    std::lock_guard lock(intervention_mutex_);
    if (!pending_intervention_ || intervention_id.empty() ||
        !ConstantTimeEqual(pending_intervention_->intervention_id,
                           intervention_id)) {
      return false;
    }
    first_acknowledgement = !pending_intervention_->visible;
    pending_intervention_->visible = true;
    evidence_id = pending_intervention_->evidence_id;
  }
  if (first_acknowledgement) {
    IncrementAggregate("intervention_shown");
    CompletePhase4Latency(evidence_id);
  }
  return true;
}

bool ProtectionService::CompleteIntervention(
    const std::string& intervention_id) {
  std::lock_guard lock(intervention_mutex_);
  if (!pending_intervention_ || intervention_id.empty() ||
      !ConstantTimeEqual(pending_intervention_->intervention_id,
                         intervention_id)) {
    return false;
  }
  pending_intervention_.reset();
  return true;
}

bool ProtectionService::RecordBlockAction(const std::string& intervention_id,
                                          bool succeeded) {
  {
    std::lock_guard lock(intervention_mutex_);
    if (!pending_intervention_ || intervention_id.empty() ||
        !ConstantTimeEqual(pending_intervention_->intervention_id,
                           intervention_id)) {
      return false;
    }
    if (pending_intervention_->block_action_reported) return true;
    pending_intervention_->block_action_reported = true;
  }
  block_action_degraded_ = !succeeded;
  if (succeeded) IncrementAggregate("block_count_sync");
  return true;
}

}  // namespace gamblock
