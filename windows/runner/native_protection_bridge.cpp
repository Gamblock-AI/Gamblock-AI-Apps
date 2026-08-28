#include "native_protection_bridge.h"

#include <utility>

NativeProtectionBridge::NativeProtectionBridge(flutter::FlutterEngine* engine,
                                               HWND window,
                                               std::function<void(bool)>
                                                   intervention_lock_changed)
    : window_(window),
      intervention_lock_changed_(std::move(intervention_lock_changed)) {
  ConfigureMethodChannel(engine);
  ConfigureEventChannel(engine);
  PrepareNativeInterventionShell();
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
  DestroyNativeInterventionShell();
}
