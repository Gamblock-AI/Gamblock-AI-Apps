#include "native_protection_bridge.h"

#include <utility>

#include "native_protection_codec.h"

namespace {

using gamblock::native_bridge::JsonBool;
using gamblock::native_bridge::JsonString;

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
    if (JsonString(message, "type") == "settings_surface") {
      const std::string response = CallService("settings_interaction");
      if (!JsonBool(response, "allowed", false)) SendBackKeystroke();
      continue;
    }
    if (JsonString(message, "type") == "intervention_shown") {
      SendBrowserBack();
      ShowWindow(window_, SW_RESTORE);
      SetForegroundWindow(window_);
      SetWindowPos(window_, HWND_TOPMOST, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
      SetWindowPos(window_, HWND_NOTOPMOST, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
    }
    DispatchEvent(message);
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
                          "permission_status", "degraded_reason_code"}) {
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
