#include "protection_service.h"

#include <algorithm>
#include <array>
#include <cwctype>
#include <fstream>

#include <shlobj.h>

#include "service_support.h"

namespace gamblock {
namespace {

bool IsInstalledUnderProgramFiles(const std::filesystem::path& executable) {
  std::array<wchar_t, MAX_PATH> program_files{};
  if (SHGetFolderPathW(nullptr, CSIDL_PROGRAM_FILES, nullptr,
                       SHGFP_TYPE_CURRENT, program_files.data()) != S_OK) {
    return false;
  }
  std::wstring root =
      std::filesystem::path(program_files.data()).lexically_normal().wstring();
  std::wstring candidate = executable.lexically_normal().wstring();
  std::transform(root.begin(), root.end(), root.begin(),
                 [](wchar_t value) { return std::towlower(value); });
  std::transform(candidate.begin(), candidate.end(), candidate.begin(),
                 [](wchar_t value) { return std::towlower(value); });
  if (!root.empty() && root.back() != L'\\') root.push_back(L'\\');
  return candidate.size() > root.size() &&
         candidate.compare(0, root.size(), root) == 0;
}

}  // namespace

ProtectionService& ProtectionService::Instance() {
  static ProtectionService service;
  return service;
}

ProtectionService::~ProtectionService() {
  StopRuntime();
}

void WINAPI ProtectionService::ServiceMain(DWORD, wchar_t**) {
  auto& service = Instance();
  service.status_handle_ =
      RegisterServiceCtrlHandlerExW(kServiceName, ControlHandler, &service);
  if (service.status_handle_ == nullptr) return;
  service.status_.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
  service.status_.dwControlsAccepted =
      SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN;
  service.status_.dwCurrentState = SERVICE_START_PENDING;
  SetServiceStatus(service.status_handle_, &service.status_);
  if (!service.StartRuntime()) {
    service.status_.dwCurrentState = SERVICE_STOPPED;
    service.status_.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR;
    service.status_.dwServiceSpecificExitCode = 1;
    SetServiceStatus(service.status_handle_, &service.status_);
    return;
  }
  service.status_.dwCurrentState = SERVICE_RUNNING;
  service.status_.dwWin32ExitCode = NO_ERROR;
  SetServiceStatus(service.status_handle_, &service.status_);
  while (service.running_) Sleep(250);
  service.StopRuntime();
  service.status_.dwCurrentState = SERVICE_STOPPED;
  service.status_.dwWin32ExitCode = NO_ERROR;
  SetServiceStatus(service.status_handle_, &service.status_);
}

DWORD WINAPI ProtectionService::ControlHandler(DWORD control,
                                               DWORD,
                                               void*,
                                               void* context) {
  auto* service = static_cast<ProtectionService*>(context);
  if (control == SERVICE_CONTROL_INTERROGATE) {
    SetServiceStatus(service->status_handle_, &service->status_);
    return NO_ERROR;
  }
  if (control == SERVICE_CONTROL_STOP) {
    // SCM access control is the administrative break-glass boundary. Normal
    // app maintenance remains grant-gated, while an elevated MSI/admin can
    // always stop the service cleanly without UI interception.
    service->status_.dwCurrentState = SERVICE_STOP_PENDING;
    SetServiceStatus(service->status_handle_, &service->status_);
    service->running_ = false;
    return NO_ERROR;
  }
  if (control == SERVICE_CONTROL_SHUTDOWN) {
    service->running_ = false;
    return NO_ERROR;
  }
  return ERROR_CALL_NOT_IMPLEMENTED;
}

bool ProtectionService::Install() {
  const auto service_path = ExecutableDirectory() / L"gamblock_ai_service.exe";
  if (!IsInstalledUnderProgramFiles(service_path)) {
    SetLastError(ERROR_ACCESS_DENIED);
    return false;
  }
  const std::wstring command = L"\"" + service_path.wstring() + L"\" --service";
  SC_HANDLE manager = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CREATE_SERVICE);
  if (manager == nullptr) return false;
  SC_HANDLE service = CreateServiceW(
      manager, kServiceName, L"Gamblock AI Protection",
      SERVICE_CHANGE_CONFIG | SERVICE_START | SERVICE_QUERY_STATUS,
      SERVICE_WIN32_OWN_PROCESS, SERVICE_AUTO_START, SERVICE_ERROR_NORMAL,
      command.c_str(), nullptr, nullptr, nullptr, L"LocalSystem", nullptr);
  if (service == nullptr && GetLastError() == ERROR_SERVICE_EXISTS) {
    service = OpenServiceW(manager, kServiceName,
                           SERVICE_CHANGE_CONFIG | SERVICE_START |
                               SERVICE_QUERY_STATUS);
  }
  if (service == nullptr) {
    CloseServiceHandle(manager);
    return false;
  }
  const bool configured =
      ChangeServiceConfigW(service, SERVICE_NO_CHANGE, SERVICE_AUTO_START,
                           SERVICE_ERROR_NORMAL, command.c_str(), nullptr,
                           nullptr, nullptr, L"LocalSystem", nullptr,
                           L"Gamblock AI Protection") != FALSE;
  SC_ACTION actions[3] = {
      {SC_ACTION_RESTART, 5000},
      {SC_ACTION_RESTART, 30000},
      {SC_ACTION_RESTART, 120000},
  };
  SERVICE_FAILURE_ACTIONSW failure_actions{};
  failure_actions.dwResetPeriod = 86400;
  failure_actions.cActions = 3;
  failure_actions.lpsaActions = actions;
  const bool recovery_configured =
      ChangeServiceConfig2W(service, SERVICE_CONFIG_FAILURE_ACTIONS,
                            &failure_actions) != FALSE;
  SERVICE_FAILURE_ACTIONS_FLAG failure_flag{TRUE};
  const bool recovery_enabled =
      ChangeServiceConfig2W(service, SERVICE_CONFIG_FAILURE_ACTIONS_FLAG,
                            &failure_flag) != FALSE;
  SERVICE_SID_INFO sid_info{SERVICE_SID_TYPE_UNRESTRICTED};
  const bool sid_configured =
      ChangeServiceConfig2W(service, SERVICE_CONFIG_SERVICE_SID_INFO,
                            &sid_info) != FALSE;
  const bool started = StartServiceW(service, 0, nullptr) != FALSE ||
                       GetLastError() == ERROR_SERVICE_ALREADY_RUNNING;
  CloseServiceHandle(service);
  CloseServiceHandle(manager);
  return configured && recovery_configured && recovery_enabled &&
         sid_configured && started;
}

bool ProtectionService::Uninstall(bool require_grant) {
  if (require_grant && !HasActiveGrant("uninstall")) {
    SetLastError(ERROR_ACCESS_DENIED);
    return false;
  }
  SC_HANDLE manager = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
  if (manager == nullptr) return false;
  SC_HANDLE service = OpenServiceW(manager, kServiceName, SERVICE_STOP | DELETE);
  if (service == nullptr) {
    CloseServiceHandle(manager);
    return false;
  }
  SERVICE_STATUS status{};
  ControlService(service, SERVICE_CONTROL_STOP, &status);
  const bool deleted = DeleteService(service) != FALSE;
  CloseServiceHandle(service);
  CloseServiceHandle(manager);
  return deleted;
}

int ProtectionService::RunConsole() {
  if (!StartRuntime()) return 1;
  while (running_) Sleep(250);
  StopRuntime();
  return 0;
}

bool ProtectionService::StartRuntime() {
  if (running_.exchange(true)) return true;
  WSADATA data{};
  if (WSAStartup(MAKEWORD(2, 2), &data) != 0) {
    running_ = false;
    return false;
  }
  LoadArtifacts();
  {
    std::ifstream file(DataDirectory() / L"aggregates.txt");
    std::string key;
    int count = 0;
    while (file >> key >> count) aggregates_[key] = count;
  }
  if (const auto stored_device =
          ReadProtected(DataDirectory() / L"device-id.bin")) {
    LoadDeviceId(*stored_device);
  } else if (const auto legacy_device =
                 ReadTextFile(DataDirectory() / L"device-id.txt")) {
    if (SetDeviceId(*legacy_device)) {
      std::error_code error;
      std::filesystem::remove(DataDirectory() / L"device-id.txt", error);
    }
  }
  websocket_thread_ = std::thread(&ProtectionService::WebSocketLoop, this);
  pipe_thread_ = std::thread(&ProtectionService::PipeLoop, this);
  return true;
}

void ProtectionService::StopRuntime() {
  if (!running_.exchange(false) && !websocket_thread_.joinable() &&
      !pipe_thread_.joinable()) return;
  {
    std::lock_guard lock(client_mutex_);
    for (const SOCKET client : connected_clients_) shutdown(client, SD_BOTH);
  }
  {
    std::lock_guard lock(pipe_mutex_);
    if (pipe_client_ != INVALID_HANDLE_VALUE) {
      CancelIoEx(pipe_client_, nullptr);
      DisconnectNamedPipe(pipe_client_);
    }
  }
  if (websocket_thread_.joinable()) websocket_thread_.join();
  for (auto& client_thread : websocket_client_threads_) {
    if (client_thread.joinable()) client_thread.join();
  }
  websocket_client_threads_.clear();
  if (pipe_thread_.joinable()) pipe_thread_.join();
  WSACleanup();
}

}  // namespace gamblock
