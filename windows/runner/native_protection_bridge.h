#ifndef RUNNER_NATIVE_PROTECTION_BRIDGE_H_
#define RUNNER_NATIVE_PROTECTION_BRIDGE_H_

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/flutter_engine.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <atomic>
#include <condition_variable>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <queue>
#include <string>
#include <thread>

class NativeProtectionBridge {
 public:
  static constexpr UINT kNativeEventMessage = WM_APP + 73;
  static constexpr UINT_PTR kInterventionExpiryTimer = 0x47424c4b;
  static constexpr UINT_PTR kInterventionCloseGateTimer = 0x47424c4c;

  NativeProtectionBridge(flutter::FlutterEngine* engine,
                         HWND window,
                         std::function<void(bool)> intervention_lock_changed);
  ~NativeProtectionBridge();

  void HandleWindowMessage();
  void HandleInterventionTimeout();
  void PrepareForWindowClose();

 private:
  void ConfigureMethodChannel(flutter::FlutterEngine* engine);
  void ConfigureEventChannel(flutter::FlutterEngine* engine);
  void ConnectLoop();
  std::string CallService(const std::string& type,
                          const std::string& fields = "",
                          DWORD timeout_ms = 5000);
  void HandlePipeMessage(const std::string& message);
  void DispatchEvent(const std::string& message);
  void FlushPendingBlockAction(DWORD timeout_ms);
  static bool SendBrowserBack();

  HWND window_;
  HANDLE pipe_ = INVALID_HANDLE_VALUE;
  std::thread pipe_thread_;
  std::atomic<bool> running_{true};
  std::atomic<unsigned long> request_sequence_{1};
  std::mutex pipe_mutex_;
  std::mutex response_mutex_;
  std::condition_variable response_ready_;
  std::map<std::string, std::string> responses_;
  std::mutex event_mutex_;
  std::queue<std::string> events_;
  std::queue<std::string> pending_flutter_events_;
  std::string active_intervention_id_;
  std::optional<bool> pending_block_action_result_;
  int intervention_expiry_retries_ = 0;
  std::function<void(bool)> intervention_lock_changed_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      method_channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      event_channel_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

#endif  // RUNNER_NATIVE_PROTECTION_BRIDGE_H_
