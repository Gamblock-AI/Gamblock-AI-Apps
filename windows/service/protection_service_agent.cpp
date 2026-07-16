#include "protection_service.h"

#include <userenv.h>
#include <wtsapi32.h>

#include "service_support.h"

namespace gamblock {

void ProtectionService::SendAgentEvent(const std::string& json) {
  std::lock_guard lock(pipe_mutex_);
  if (pipe_client_ == INVALID_HANDLE_VALUE) return;
  const std::string framed = json + "\n";
  DWORD written = 0;
  if (!WriteFile(pipe_client_, framed.data(), static_cast<DWORD>(framed.size()),
                 &written, nullptr)) {
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
