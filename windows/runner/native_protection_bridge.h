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
#include <map>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <thread>

class NativeProtectionBridge {
 public:
  static constexpr UINT kNativeEventMessage = WM_APP + 73;

  NativeProtectionBridge(flutter::FlutterEngine* engine, HWND window);
  ~NativeProtectionBridge();

  void HandleWindowMessage();

 private:
  void ConfigureMethodChannel(flutter::FlutterEngine* engine);
  void ConfigureEventChannel(flutter::FlutterEngine* engine);
  void ConnectLoop();
  std::string CallService(const std::string& type,
                          const std::string& fields = "",
                          DWORD timeout_ms = 5000);
  void HandlePipeMessage(const std::string& message);
  void DispatchEvent(const std::string& message);
  void InstallSettingsMonitor();
  void RemoveSettingsMonitor();
  void InspectForegroundWindow(HWND foreground);
  static void CALLBACK ForegroundHook(HWINEVENTHOOK hook,
                                      DWORD event,
                                      HWND window,
                                      LONG object_id,
                                      LONG child_id,
                                      DWORD event_thread,
                                      DWORD event_time);
  static void SendBrowserBack();
  static void SendBackKeystroke();

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
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      method_channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      event_channel_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
  HWINEVENTHOOK foreground_hook_ = nullptr;
  ULONGLONG last_settings_prompt_ = 0;

  static std::mutex callback_mutex_;
  static NativeProtectionBridge* instance_;
};

#endif  // RUNNER_NATIVE_PROTECTION_BRIDGE_H_
