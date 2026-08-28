#include "native_protection_bridge.h"

#include <chrono>
#include <utility>

#include "native_protection_codec.h"

namespace {

using gamblock::native_bridge::JsonBool;
using gamblock::native_bridge::JsonString;

constexpr wchar_t kNativeInterventionShellClass[] =
    L"GamblockNativeInterventionShell";

LRESULT CALLBACK NativeInterventionShellProc(HWND window, UINT message,
                                             WPARAM wparam, LPARAM lparam) {
  if (message == WM_PAINT) {
    PAINTSTRUCT paint{};
    HDC dc = BeginPaint(window, &paint);
    RECT bounds{};
    GetClientRect(window, &bounds);
    HBRUSH background = CreateSolidBrush(RGB(11, 19, 43));
    FillRect(dc, &bounds, background);
    DeleteObject(background);
    SetBkMode(dc, TRANSPARENT);
    SetTextColor(dc, RGB(255, 255, 255));
    HFONT font =
        CreateFontW(-28, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE,
                    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                    CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_SWISS, L"Segoe UI");
    HGDIOBJ previous = SelectObject(dc, font);
    DrawTextW(dc, L"Take a pause before continuing", -1, &bounds,
              DT_CENTER | DT_VCENTER | DT_SINGLELINE);
    SelectObject(dc, previous);
    DeleteObject(font);
    EndPaint(window, &paint);
    return 0;
  }
  return DefWindowProcW(window, message, wparam, lparam);
}

ATOM EnsureNativeInterventionShellClass() {
  static const ATOM atom = [] {
    WNDCLASSW window_class{};
    window_class.lpfnWndProc = NativeInterventionShellProc;
    window_class.hInstance = GetModuleHandleW(nullptr);
    window_class.lpszClassName = kNativeInterventionShellClass;
    return RegisterClassW(&window_class);
  }();
  return atom;
}

} // namespace

void NativeProtectionBridge::ShowNativeInterventionShell() {
  if (native_intervention_shell_ == nullptr) {
    if (EnsureNativeInterventionShellClass() == 0)
      return;
    RECT bounds{};
    GetClientRect(window_, &bounds);
    native_intervention_shell_ =
        CreateWindowExW(WS_EX_NOACTIVATE, kNativeInterventionShellClass,
                        L"Gamblock-AI", WS_CHILD | WS_VISIBLE, 0, 0,
                        bounds.right - bounds.left, bounds.bottom - bounds.top,
                        window_, nullptr, GetModuleHandleW(nullptr), nullptr);
  }
  if (native_intervention_shell_ == nullptr)
    return;
  SetWindowPos(native_intervention_shell_, HWND_TOP, 0, 0, 0, 0,
               SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
  RedrawWindow(native_intervention_shell_, nullptr, nullptr,
               RDW_INVALIDATE | RDW_UPDATENOW | RDW_ERASE);
}

void NativeProtectionBridge::HideNativeInterventionShell() {
  if (native_intervention_shell_ == nullptr)
    return;
  DestroyWindow(native_intervention_shell_);
  native_intervention_shell_ = nullptr;
}

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
        HideNativeInterventionShell();
        active_intervention_id_.clear();
        pending_block_action_result_.reset();
        pending_block_action_duration_ms_.reset();
        if (intervention_lock_changed_)
          intervention_lock_changed_(false);
      }
      continue;
    }
    if (type == "intervention_required") {
      const std::string intervention_id =
          JsonString(message, "intervention_id");
      const bool is_new = !intervention_id.empty() &&
                          intervention_id != active_intervention_id_;
      bool browser_block_succeeded = false;
      double browser_block_duration_ms = 0.0;
      if (is_new) {
        active_intervention_id_ = intervention_id;
        intervention_expiry_retries_ = 0;
        const auto block_action_started = std::chrono::steady_clock::now();
        browser_block_succeeded = SendBrowserBack();
        browser_block_duration_ms =
            std::chrono::duration<double, std::milli>(
                std::chrono::steady_clock::now() - block_action_started)
                .count();
        if (intervention_lock_changed_)
          intervention_lock_changed_(true);
      }
      ShowWindow(window_, SW_RESTORE);
      const bool foreground = SetForegroundWindow(window_) != FALSE;
      const bool raised =
          SetWindowPos(window_, HWND_TOPMOST, 0, 0, 0, 0,
                       SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW) != FALSE;
      const bool restored_z_order =
          SetWindowPos(window_, HWND_NOTOPMOST, 0, 0, 0, 0,
                       SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW) != FALSE;
      ShowNativeInterventionShell();
      if (is_new) {
        pending_block_action_result_ =
            browser_block_succeeded && foreground && raised && restored_z_order;
        pending_block_action_duration_ms_ = browser_block_duration_ms;
        SetTimer(window_, kInterventionExpiryTimer, 30000, nullptr);
        SetTimer(window_, kInterventionCloseGateTimer, 7000, nullptr);
      }
      DispatchEvent(message);
      FlushPendingBlockAction(750);
      if (is_new && !active_intervention_id_.empty()) {
        const std::string fields =
            ",\"intervention_id\":\"" +
            gamblock::native_bridge::EscapeJson(active_intervention_id_) + "\"";
        CallService("ack_intervention_visible", fields, 1000);
      }
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
  const bool completed =
      JsonBool(CallService("complete_intervention", fields, 750), "ok");
  if (completed) {
    KillTimer(window_, kInterventionExpiryTimer);
    KillTimer(window_, kInterventionCloseGateTimer);
    active_intervention_id_.clear();
    HideNativeInterventionShell();
    pending_block_action_result_.reset();
    pending_block_action_duration_ms_.reset();
    if (intervention_lock_changed_)
      intervention_lock_changed_(false);
    return;
  }
  if (++intervention_expiry_retries_ < 5) {
    SetTimer(window_, kInterventionExpiryTimer, 1000, nullptr);
  } else {
    KillTimer(window_, kInterventionExpiryTimer);
    active_intervention_id_.clear();
    HideNativeInterventionShell();
    pending_block_action_result_.reset();
    pending_block_action_duration_ms_.reset();
    if (intervention_lock_changed_)
      intervention_lock_changed_(false);
  }
}

void NativeProtectionBridge::PrepareForWindowClose() {
  if (active_intervention_id_.empty())
    return;
  FlushPendingBlockAction(500);
  const std::string fields =
      ",\"intervention_id\":\"" +
      gamblock::native_bridge::EscapeJson(active_intervention_id_) + "\"";
  CallService("complete_intervention", fields, 750);
  KillTimer(window_, kInterventionExpiryTimer);
  KillTimer(window_, kInterventionCloseGateTimer);
  active_intervention_id_.clear();
  HideNativeInterventionShell();
  pending_block_action_result_.reset();
  pending_block_action_duration_ms_.reset();
  if (intervention_lock_changed_)
    intervention_lock_changed_(false);
}

void NativeProtectionBridge::FlushPendingBlockAction(DWORD timeout_ms) {
  if (!pending_block_action_result_ || active_intervention_id_.empty())
    return;
  const std::string fields =
      ",\"intervention_id\":\"" +
      gamblock::native_bridge::EscapeJson(active_intervention_id_) +
      "\",\"succeeded\":" + (*pending_block_action_result_ ? "true" : "false") +
      ",\"duration_ms\":" +
      std::to_string(pending_block_action_duration_ms_.value_or(0.0));
  if (JsonBool(CallService("block_action_result", fields, timeout_ms), "ok")) {
    pending_block_action_result_.reset();
    pending_block_action_duration_ms_.reset();
  }
}

void NativeProtectionBridge::DispatchEvent(const std::string &message) {
  if (!event_sink_) {
    std::lock_guard lock(event_mutex_);
    pending_flutter_events_.push(message);
    return;
  }
  flutter::EncodableMap payload{
      {flutter::EncodableValue("type"),
       flutter::EncodableValue(JsonString(message, "type", "unknown"))},
  };
  for (const auto &key :
       {"reason_code", "model_version", "ruleset_version", "status", "platform",
        "sensor_status", "permission_status", "degraded_reason_code",
        "evidence_id", "intervention_id"}) {
    const std::string value = JsonString(message, key);
    if (!value.empty()) {
      payload[flutter::EncodableValue(key)] = flutter::EncodableValue(value);
    }
  }
  for (const auto &key : {"service_running"}) {
    if (message.find("\"" + std::string(key) + "\"") != std::string::npos) {
      payload[flutter::EncodableValue(key)] =
          flutter::EncodableValue(JsonBool(message, key));
    }
  }
  event_sink_->Success(flutter::EncodableValue(payload));
}
