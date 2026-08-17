#include <string>

#include "protection_service.h"

int wmain(int argc, wchar_t** argv) {
  auto& service = gamblock::ProtectionService::Instance();
  const std::wstring command = argc > 1 ? argv[1] : L"--service";
  if (command == L"--install") {
    return service.Install() ? 0 : 1;
  }
  if (command == L"--uninstall") {
    return service.BeginApprovedRemoval() ? 0 : 1;
  }
  if (command == L"--admin-uninstall") {
    // Windows SCM permissions are the explicit administrator break-glass
    // boundary. Standard users cannot stop/delete this LocalSystem service.
    return service.Uninstall(false) ? 0 : 1;
  }
  if (command == L"--console") {
    return service.RunConsole();
  }
  SERVICE_TABLE_ENTRYW table[] = {
      {const_cast<wchar_t*>(L"GamblockAIProtection"),
       gamblock::ProtectionService::ServiceMain},
      {nullptr, nullptr},
  };
  return StartServiceCtrlDispatcherW(table) ? 0 : 1;
}
