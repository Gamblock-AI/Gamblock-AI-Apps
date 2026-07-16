#include "native_protection_bridge.h"

std::mutex NativeProtectionBridge::callback_mutex_;
NativeProtectionBridge* NativeProtectionBridge::instance_ = nullptr;

NativeProtectionBridge::NativeProtectionBridge(flutter::FlutterEngine* engine,
                                               HWND window)
    : window_(window) {
  {
    std::lock_guard lock(callback_mutex_);
    instance_ = this;
  }
  ConfigureMethodChannel(engine);
  ConfigureEventChannel(engine);
  pipe_thread_ = std::thread(&NativeProtectionBridge::ConnectLoop, this);
  InstallSettingsMonitor();
}

NativeProtectionBridge::~NativeProtectionBridge() {
  running_ = false;
  RemoveSettingsMonitor();
  {
    std::lock_guard lock(callback_mutex_);
    if (instance_ == this) instance_ = nullptr;
  }
  {
    std::lock_guard lock(pipe_mutex_);
    if (pipe_ != INVALID_HANDLE_VALUE) {
      CancelIoEx(pipe_, nullptr);
    }
  }
  response_ready_.notify_all();
  if (pipe_thread_.joinable()) pipe_thread_.join();
}
