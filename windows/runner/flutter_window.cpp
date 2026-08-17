#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project,
                             bool start_hidden)
    : project_(project), start_hidden_(start_hidden) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  protection_bridge_ = std::make_unique<NativeProtectionBridge>(
      flutter_controller_->engine(), GetHandle(),
      [this](bool locked) { intervention_locked_.store(locked); });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    if (!start_hidden_) {
      this->Show();
    }
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  protection_bridge_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  const bool close_request =
      message == WM_CLOSE ||
      (message == WM_SYSCOMMAND && (wparam & 0xfff0) == SC_CLOSE);
  if (close_request) {
    if (intervention_locked_.load()) return 0;
    if (protection_bridge_) protection_bridge_->PrepareForWindowClose();
  }
  if (message == WM_TIMER &&
      wparam == NativeProtectionBridge::kInterventionCloseGateTimer) {
    KillTimer(hwnd, NativeProtectionBridge::kInterventionCloseGateTimer);
    intervention_locked_.store(false);
    return 0;
  }
  if (message == WM_TIMER &&
      wparam == NativeProtectionBridge::kInterventionExpiryTimer &&
      protection_bridge_) {
    protection_bridge_->HandleInterventionTimeout();
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case NativeProtectionBridge::kNativeEventMessage:
      if (protection_bridge_) {
        protection_bridge_->HandleWindowMessage();
      }
      return 0;
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
