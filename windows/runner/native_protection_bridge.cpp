#include "native_protection_bridge.h"

NativeProtectionBridge::NativeProtectionBridge(flutter::FlutterEngine* engine,
                                               HWND window)
    : window_(window) {
  ConfigureMethodChannel(engine);
  ConfigureEventChannel(engine);
  pipe_thread_ = std::thread(&NativeProtectionBridge::ConnectLoop, this);
}

NativeProtectionBridge::~NativeProtectionBridge() {
  running_ = false;
  {
    std::lock_guard lock(pipe_mutex_);
    if (pipe_ != INVALID_HANDLE_VALUE) {
      CancelIoEx(pipe_, nullptr);
    }
  }
  response_ready_.notify_all();
  if (pipe_thread_.joinable()) pipe_thread_.join();
}
