#include "protection_service.h"

#include <userenv.h>
#include <wtsapi32.h>

#include "service_support.h"

namespace gamblock {
namespace {

constexpr DWORD kPipeWriteTimeoutMs = 5000;
constexpr auto kUserAgentRetryDelay = std::chrono::seconds(10);

bool SessionIsActive(DWORD session_id) {
  if (session_id == 0xffffffff) return false;
  LPWSTR value = nullptr;
  DWORD bytes = 0;
  const bool queried = WTSQuerySessionInformationW(
                           WTS_CURRENT_SERVER_HANDLE, session_id,
                           WTSConnectState, &value, &bytes) != FALSE;
  const bool active = queried && bytes >= sizeof(WTS_CONNECTSTATE_CLASS) &&
                      value != nullptr &&
                      *reinterpret_cast<WTS_CONNECTSTATE_CLASS*>(value) ==
                          WTSActive;
  if (value != nullptr) WTSFreeMemory(value);
  return active;
}

DWORD ActiveInteractiveSession(DWORD preferred_session_id) {
  if (SessionIsActive(preferred_session_id)) return preferred_session_id;
  const DWORD console_session_id = WTSGetActiveConsoleSessionId();
  return SessionIsActive(console_session_id) ? console_session_id : 0xffffffff;
}

bool WritePipeMessage(HANDLE pipe, const std::string& payload) {
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) return false;
  OVERLAPPED operation{};
  operation.hEvent = event;
  DWORD written = 0;
  const BOOL completed = WriteFile(
      pipe, payload.data(), static_cast<DWORD>(payload.size()), &written,
      &operation);
  const DWORD error = completed ? ERROR_SUCCESS : GetLastError();
  bool success = completed != FALSE;
  if (!success && error == ERROR_IO_PENDING) {
    if (WaitForSingleObject(event, kPipeWriteTimeoutMs) == WAIT_OBJECT_0) {
      success = GetOverlappedResult(
                    pipe, &operation, &written, FALSE) != FALSE;
    } else {
      CancelIoEx(pipe, &operation);
      GetOverlappedResult(pipe, &operation, &written, TRUE);
    }
  }
  CloseHandle(event);
  return success && written == payload.size();
}

}  // namespace

void ProtectionService::SendAgentEvent(const std::string& json) {
  std::lock_guard lock(pipe_mutex_);
  if (pipe_client_ == INVALID_HANDLE_VALUE) return;
  const std::string framed = json + "\n";
  if (!WritePipeMessage(pipe_client_, framed)) {
    pipe_client_ = INVALID_HANDLE_VALUE;
  }
}

void ProtectionService::RequestUserAgent(DWORD session_id) {
  session_id = ActiveInteractiveSession(session_id);
  const DWORD previous = interactive_session_id_.exchange(session_id);
  if (previous != session_id) {
    std::lock_guard pipe_lock(pipe_mutex_);
    if (pipe_listener_ != INVALID_HANDLE_VALUE) {
      CancelIoEx(pipe_listener_, nullptr);
    }
    if (pipe_client_ != INVALID_HANDLE_VALUE) {
      CancelIoEx(pipe_client_, nullptr);
      DisconnectNamedPipe(pipe_client_);
      pipe_client_ = INVALID_HANDLE_VALUE;
    }
  }
  {
    std::lock_guard lock(user_agent_mutex_);
    user_agent_requested_ = true;
  }
  user_agent_wakeup_.notify_one();
}

void ProtectionService::UserAgentLoop() {
  while (running_) {
    {
      std::unique_lock lock(user_agent_mutex_);
      user_agent_wakeup_.wait_for(lock, std::chrono::seconds(5), [this] {
        return user_agent_requested_ || !running_.load();
      });
      user_agent_requested_ = false;
    }
    if (!running_) break;
    {
      std::lock_guard lock(pipe_mutex_);
      if (pipe_client_ != INVALID_HANDLE_VALUE) continue;
    }
    const auto now = std::chrono::steady_clock::now();
    if (last_user_agent_launch_.time_since_epoch().count() != 0 &&
        now - last_user_agent_launch_ < kUserAgentRetryDelay) {
      continue;
    }
    last_user_agent_launch_ = now;
    EnsureUserAgentRunning();
  }
}

void ProtectionService::EnsureUserAgentRunning() {
  const DWORD session_id = interactive_session_id_.load();
  if (session_id == 0xffffffff) return;
  HANDLE token = nullptr;
  if (!WTSQueryUserToken(session_id, &token)) return;
  void* environment = nullptr;
  const bool has_environment =
      CreateEnvironmentBlock(&environment, token, FALSE) != FALSE;
  const auto agent_path = ExecutableDirectory() / L"gamblock_ai_apps.exe";
  if (GetFileAttributesW(agent_path.c_str()) == INVALID_FILE_ATTRIBUTES) {
    if (environment) DestroyEnvironmentBlock(environment);
    CloseHandle(token);
    return;
  }
  std::wstring command = L"\"" + agent_path.wstring() + L"\" --protection-agent";
  STARTUPINFOW startup{};
  startup.cb = sizeof(startup);
  startup.lpDesktop = const_cast<LPWSTR>(L"winsta0\\default");
  PROCESS_INFORMATION process{};
  if (CreateProcessAsUserW(token, nullptr, command.data(), nullptr, nullptr,
                           FALSE,
                           has_environment ? CREATE_UNICODE_ENVIRONMENT : 0,
                           environment,
                           ExecutableDirectory().c_str(), &startup, &process)) {
    CloseHandle(process.hThread);
    CloseHandle(process.hProcess);
  }
  if (environment) DestroyEnvironmentBlock(environment);
  CloseHandle(token);
}

}  // namespace gamblock
