#include "protection_service.h"

#include <array>
#include <cwctype>
#include <filesystem>
#include <optional>

namespace gamblock {
namespace {

std::optional<std::wstring> InstalledProductCode() {
  std::array<wchar_t, 64> value{};
  DWORD bytes = static_cast<DWORD>(value.size() * sizeof(wchar_t));
  const LSTATUS status = RegGetValueW(
      HKEY_LOCAL_MACHINE, L"Software\\GamblockAI", L"ProductCode",
      RRF_RT_REG_SZ | RRF_SUBKEY_WOW6464KEY, nullptr, value.data(), &bytes);
  if (status != ERROR_SUCCESS || bytes < 2 * sizeof(wchar_t)) {
    return std::nullopt;
  }
  std::wstring product_code(value.data());
  if (product_code.size() != 38 || product_code.front() != L'{' ||
      product_code.back() != L'}') {
    return std::nullopt;
  }
  for (size_t index = 1; index + 1 < product_code.size(); ++index) {
    const bool hyphen = index == 9 || index == 14 || index == 19 || index == 24;
    if ((hyphen && product_code[index] != L'-') ||
        (!hyphen && std::iswxdigit(product_code[index]) == 0)) {
      return std::nullopt;
    }
  }
  return product_code;
}

std::optional<std::filesystem::path> SystemMsiexecPath() {
  std::array<wchar_t, MAX_PATH> system_directory{};
  const UINT length = GetSystemDirectoryW(
      system_directory.data(), static_cast<UINT>(system_directory.size()));
  if (length == 0 ||
      length >= static_cast<UINT>(system_directory.size())) {
    return std::nullopt;
  }
  const auto path =
      std::filesystem::path(system_directory.data()) / L"msiexec.exe";
  if (GetFileAttributesW(path.c_str()) == INVALID_FILE_ATTRIBUTES) {
    return std::nullopt;
  }
  return path;
}

}  // namespace

bool ProtectionService::BeginApprovedRemoval() {
  const auto product_code = InstalledProductCode();
  const auto msiexec_path = SystemMsiexecPath();
  if (!product_code || !msiexec_path || !ConsumeActiveGrant("uninstall")) {
    SetLastError(ERROR_ACCESS_DENIED);
    return false;
  }

  std::wstring command = L"\"" + msiexec_path->wstring() + L"\" /x " +
                         *product_code + L" /qn /norestart";
  STARTUPINFOW startup{};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process{};
  const bool launched = CreateProcessW(
                            msiexec_path->c_str(), command.data(), nullptr,
                            nullptr, FALSE,
                            DETACHED_PROCESS | CREATE_NEW_PROCESS_GROUP,
                            nullptr, nullptr, &startup, &process) != FALSE;
  if (launched) {
    CloseHandle(process.hThread);
    CloseHandle(process.hProcess);
  }
  return launched;
}

}  // namespace gamblock
