#include "native_protection_bridge.h"

#include <utility>

#include "native_protection_codec.h"

namespace {

using gamblock::native_bridge::JsonString;
using gamblock::native_bridge::JsonBool;

}  // namespace

void NativeProtectionBridge::HandleWindowMessage() {
  std::queue<std::string> pending;
  {
    std::lock_guard lock(event_mutex_);
    std::swap(pending, events_);
  }
  while (!pending.empty()) {
    const std::string message = std::move(pending.front());
    pending.pop();
    const std::string type = JsonString(message, "type");
    if (type == "intervention_completed") {
      const std::string intervention_id =
          JsonString(message, "intervention_id");
      if (!intervention_id.empty() &&
          intervention_id == active_intervention_id_) {
        KillTimer(window_, kInterventionExpiryTimer);
        KillTimer(window_, kInterventionCloseGateTimer);
        active_intervention_id_.clear();
        pending_block_action_result_.reset();
        if (intervention_lock_changed_) intervention_lock_changed_(false);
      }
      continue;
    }
    if (type == "intervention_required") {
      const std::string intervention_id =
          JsonString(message, "intervention_id");
      const bool is_new = !intervention_id.empty() &&
                          intervention_id != active_intervention_id_;
      bool browser_block_succeeded = false;
      if (is_new) {
        active_intervention_id_ = intervention_id;
        intervention_expiry_retries_ = 0;
        SetTimer(window_, kInterventionExpiryTimer, 30000, nullptr);
        SetTimer(window_, kInterventionCloseGateTimer, 7000, nullptr);
        browser_block_succeeded = SendBrowserBack();
        if (intervention_lock_changed_) intervention_lock_changed_(true);
      }
      ShowWindow(window_, SW_RESTORE);
      const bool foreground = SetForegroundWindow(window_) != FALSE;
      const bool raised = SetWindowPos(
                              window_, HWND_TOPMOST, 0, 0, 0, 0,
                              SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW) != FALSE;
      const bool restored_z_order =
          SetWindowPos(window_, HWND_NOTOPMOST, 0, 0, 0, 0,
                       SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW) != FALSE;
      if (is_new) {
        pending_block_action_result_ =
            browser_block_succeeded && foreground && raised && restored_z_order;
      }
      DispatchEvent(message);
      FlushPendingBlockAction(750);
      continue;
    }
    DispatchEvent(message);
  }
}

void NativeProtectionBridge::HandleInterventionTimeout() {
  if (active_intervention_id_.empty()) {
    KillTimer(window_, kInterventionExpiryTimer);
    KillTimer(window_, kInterventionCloseGateTimer);
    return;
  }
  FlushPendingBlockAction(750);
  const std::string fields =
      ",\"intervention_id\":\"" +
      gamblock::native_bridge::EscapeJson(active_intervention_id_) + "\"";
  const bool completed = JsonBool(
      CallService("complete_intervention", fields, 750), "ok");
  if (completed) {
    KillTimer(window_, kInterventionExpiryTimer);
    KillTimer(window_, kInterventionCloseGateTimer);
    active_intervention_id_.clear();
    pending_block_action_result_.reset();
    if (intervention_lock_changed_) intervention_lock_changed_(false);
    return;
  }
  if (++intervention_expiry_retries_ < 5) {
    SetTimer(window_, kInterventionExpiryTimer, 1000, nullptr);
  } else {
    KillTimer(window_, kInterventionExpiryTimer);
    active_intervention_id_.clear();
    pending_block_action_result_.reset();
    if (intervention_lock_changed_) intervention_lock_changed_(false);
  }
}

void NativeProtectionBridge::PrepareForWindowClose() {
  if (active_intervention_id_.empty()) return;
  FlushPendingBlockAction(500);
  const std::string fields =
      ",\"intervention_id\":\"" +
      gamblock::native_bridge::EscapeJson(active_intervention_id_) + "\"";
  CallService("complete_intervention", fields, 750);
  KillTimer(window_, kInterventionExpiryTimer);
  KillTimer(window_, kInterventionCloseGateTimer);
  active_intervention_id_.clear();
  pending_block_action_result_.reset();
  if (intervention_lock_changed_) intervention_lock_changed_(false);
}

void NativeProtectionBridge::FlushPendingBlockAction(DWORD timeout_ms) {
  if (!pending_block_action_result_ || active_intervention_id_.empty()) return;
  const std::string fields =
      ",\"intervention_id\":\"" +
      gamblock::native_bridge::EscapeJson(active_intervention_id_) +
      "\",\"succeeded\":" +
      (*pending_block_action_result_ ? "true" : "false");
  if (JsonBool(CallService("block_action_result", fields, timeout_ms), "ok")) {
    pending_block_action_result_.reset();
  }
}

void NativeProtectionBridge::DispatchEvent(const std::string& message) {
  if (!event_sink_) {
    std::lock_guard lock(event_mutex_);
    pending_flutter_events_.push(message);
    return;
  }
  flutter::EncodableMap payload{
      {flutter::EncodableValue("type"),
       flutter::EncodableValue(JsonString(message, "type", "unknown"))},
  };
  for (const auto& key : {"reason_code", "model_version", "ruleset_version",
                          "status", "platform", "sensor_status",
                          "permission_status", "degraded_reason_code",
                          "evidence_id", "intervention_id"}) {
    const std::string value = JsonString(message, key);
    if (!value.empty()) {
      payload[flutter::EncodableValue(key)] = flutter::EncodableValue(value);
    }
  }
  for (const auto& key : {"service_running"}) {
    if (message.find("\"" + std::string(key) + "\"") != std::string::npos) {
      payload[flutter::EncodableValue(key)] =
          flutter::EncodableValue(JsonBool(message, key));
    }
  }
  event_sink_->Success(flutter::EncodableValue(payload));
}
