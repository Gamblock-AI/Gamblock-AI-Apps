#include "native_protection_bridge.h"

#include <atomic>
#include <array>
#include <chrono>
#include <sstream>
#include <utility>

#include "native_protection_codec.h"

namespace {

constexpr wchar_t kPipeName[] = L"\\\\.\\pipe\\GamblockAIProtection";
constexpr DWORD kPipeOperationPollMs = 200;
constexpr DWORD kPipeWriteTimeoutMs = 5000;

using gamblock::native_bridge::EscapeJson;
using gamblock::native_bridge::JsonString;

bool WaitForPipeRead(HANDLE pipe,
                     OVERLAPPED* operation,
                     const std::atomic<bool>& running,
                     DWORD* transferred) {
  while (running.load()) {
    const DWORD wait = WaitForSingleObject(operation->hEvent,
                                           kPipeOperationPollMs);
    if (wait == WAIT_OBJECT_0) {
      return GetOverlappedResult(pipe, operation, transferred, FALSE) != FALSE;
    }
    if (wait != WAIT_TIMEOUT) break;
  }
  CancelIoEx(pipe, operation);
  GetOverlappedResult(pipe, operation, transferred, TRUE);
  return false;
}

bool ReadPipeMessage(HANDLE pipe,
                     void* buffer,
                     DWORD capacity,
                     const std::atomic<bool>& running,
                     DWORD* read) {
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) return false;
  OVERLAPPED operation{};
  operation.hEvent = event;
  const BOOL completed = ReadFile(pipe, buffer, capacity, read, &operation);
  const DWORD error = completed ? ERROR_SUCCESS : GetLastError();
  const bool success = completed ||
      (error == ERROR_IO_PENDING &&
       WaitForPipeRead(pipe, &operation, running, read));
  CloseHandle(event);
  return success && running.load();
}

bool WritePipeMessage(HANDLE pipe, const std::string& payload) {
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) return false;
  OVERLAPPED operation{};
  operation.hEvent = event;
  const DWORD payload_bytes = static_cast<DWORD>(payload.size());
  DWORD written = 0;
  const BOOL completed =
      WriteFile(pipe, payload.data(), payload_bytes, &written, &operation);
  const DWORD error = completed ? ERROR_SUCCESS : GetLastError();
  bool success = completed;
  if (!completed && error == ERROR_IO_PENDING) {
    const DWORD wait = WaitForSingleObject(event, kPipeWriteTimeoutMs);
    if (wait == WAIT_OBJECT_0) {
      success = GetOverlappedResult(pipe, &operation, &written, FALSE) != FALSE;
    } else {
      CancelIoEx(pipe, &operation);
      GetOverlappedResult(pipe, &operation, &written, TRUE);
    }
  }
  CloseHandle(event);
  return success && written == payload_bytes;
}

}  // namespace

void NativeProtectionBridge::ConnectLoop() {
  std::array<char, 65536> buffer{};
  while (running_) {
    HANDLE pipe = CreateFileW(kPipeName, GENERIC_READ | GENERIC_WRITE, 0,
                              nullptr, OPEN_EXISTING, FILE_FLAG_OVERLAPPED,
                              nullptr);
    if (pipe == INVALID_HANDLE_VALUE) {
      // The service can be restarting or still creating the named pipe. Keep
      // reconnect polling short so a pending intervention is not held behind
      // a coarse retry interval.
      Sleep(100);
      continue;
    }
    if (!running_) {
      CloseHandle(pipe);
      break;
    }
    DWORD mode = PIPE_READMODE_MESSAGE;
    SetNamedPipeHandleState(pipe, &mode, nullptr, nullptr);
    bool active = false;
    {
      std::lock_guard lock(pipe_mutex_);
      if (running_) {
        pipe_ = pipe;
        active = true;
      }
    }
    if (!active) {
      CloseHandle(pipe);
      break;
    }
    while (running_) {
      DWORD read = 0;
      if (!ReadPipeMessage(pipe, buffer.data(),
                           static_cast<DWORD>(buffer.size() - 1), running_,
                           &read) ||
          read == 0) break;
      buffer[read] = '\0';
      std::stringstream messages(std::string(buffer.data(), read));
      std::string message;
      while (std::getline(messages, message)) {
        if (!message.empty()) HandlePipeMessage(message);
      }
    }
    {
      std::lock_guard lock(pipe_mutex_);
      if (pipe_ == pipe) pipe_ = INVALID_HANDLE_VALUE;
    }
    CloseHandle(pipe);
    response_ready_.notify_all();
  }
}

std::string NativeProtectionBridge::CallService(const std::string& type,
                                                const std::string& fields,
                                                DWORD timeout_ms) {
  const std::string request_id = std::to_string(request_sequence_.fetch_add(1));
  const std::string command =
      "{\"type\":\"" + EscapeJson(type) + "\",\"request_id\":\"" +
      request_id + "\"" + fields + "}";
  {
    std::lock_guard lock(pipe_mutex_);
    if (!running_ || pipe_ == INVALID_HANDLE_VALUE ||
        !WritePipeMessage(pipe_, command)) return {};
  }
  std::unique_lock lock(response_mutex_);
  response_ready_.wait_for(lock, std::chrono::milliseconds(timeout_ms),
                           [this, &request_id] {
                             return responses_.find(request_id) != responses_.end() ||
                                    !running_;
                           });
  const auto found = responses_.find(request_id);
  if (found == responses_.end()) return {};
  std::string response = std::move(found->second);
  responses_.erase(found);
  return response;
}

void NativeProtectionBridge::HandlePipeMessage(const std::string& message) {
  if (JsonString(message, "type") == "response") {
    const std::string request_id = JsonString(message, "request_id");
    {
      std::lock_guard lock(response_mutex_);
      responses_[request_id] = message;
    }
    response_ready_.notify_all();
    return;
  }
  {
    std::lock_guard lock(event_mutex_);
    events_.push(message);
  }
  PostMessageW(window_, kNativeEventMessage, 0, 0);
}
