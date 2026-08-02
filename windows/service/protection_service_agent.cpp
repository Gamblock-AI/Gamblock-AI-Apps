#include "protection_service.h"

#include <userenv.h>
#include <wtsapi32.h>

#include "service_support.h"

namespace gamblock {
namespace {

constexpr DWORD kPipeWriteTimeoutMs = 5000;

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

void ProtectionService::EnsureUserAgentRunning() {
  {
    std::lock_guard lock(pipe_mutex_);
    if (pipe_client_ != INVALID_HANDLE_VALUE) return;
  }
  HANDLE token = nullptr;
  if (!WTSQueryUserToken(WTSGetActiveConsoleSessionId(), &token)) return;
  void* environment = nullptr;
  CreateEnvironmentBlock(&environment, token, FALSE);
  const auto agent_path = ExecutableDirectory() / L"gamblock_ai_apps.exe";
  std::wstring command = L"\"" + agent_path.wstring() + L"\" --protection-agent";
  STARTUPINFOW startup{};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process{};
  if (CreateProcessAsUserW(token, nullptr, command.data(), nullptr, nullptr,
                           FALSE, CREATE_UNICODE_ENVIRONMENT, environment,
                           ExecutableDirectory().c_str(), &startup, &process)) {
    CloseHandle(process.hThread);
    CloseHandle(process.hProcess);
  }
  if (environment) DestroyEnvironmentBlock(environment);
  CloseHandle(token);
  for (int attempt = 0; attempt < 100; ++attempt) {
    {
      std::lock_guard lock(pipe_mutex_);
      if (pipe_client_ != INVALID_HANDLE_VALUE) return;
    }
    Sleep(100);
  }
}

}  // namespace gamblock
