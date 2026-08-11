#include "native_protection_bridge.h"

#include <algorithm>
#include <array>
#include <cwctype>

#include <psapi.h>

namespace {

std::wstring ForegroundProcessPath(HWND window) {
  DWORD process_id = 0;
  GetWindowThreadProcessId(window, &process_id);
  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, process_id);
  if (process == nullptr) return {};
  std::array<wchar_t, MAX_PATH> path{};
  DWORD path_size = static_cast<DWORD>(path.size());
  const bool read = QueryFullProcessImageNameW(process, 0, path.data(), &path_size);
  CloseHandle(process);
  return read ? std::wstring(path.data(), path_size) : std::wstring();
}

void Lowercase(std::wstring* value) {
  std::transform(value->begin(), value->end(), value->begin(),
                 [](wchar_t character) {
                   return static_cast<wchar_t>(std::towlower(character));
                 });
}

}  // namespace

void NativeProtectionBridge::SendBrowserBack() {
  const HWND foreground = GetForegroundWindow();
  if (foreground == nullptr) return;
  std::wstring executable = ForegroundProcessPath(foreground);
  Lowercase(&executable);
  if (executable.find(L"chrome.exe") == std::wstring::npos &&
      executable.find(L"msedge.exe") == std::wstring::npos) return;
  INPUT inputs[4]{};
  inputs[0].type = INPUT_KEYBOARD;
  inputs[0].ki.wVk = VK_MENU;
  inputs[1].type = INPUT_KEYBOARD;
  inputs[1].ki.wVk = VK_LEFT;
  inputs[2].type = INPUT_KEYBOARD;
  inputs[2].ki.wVk = VK_LEFT;
  inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;
  inputs[3].type = INPUT_KEYBOARD;
  inputs[3].ki.wVk = VK_MENU;
  inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;
  SendInput(4, inputs, sizeof(INPUT));
}
