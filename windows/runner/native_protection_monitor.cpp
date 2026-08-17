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

std::wstring WindowTitle(HWND window) {
  std::array<wchar_t, 512> title{};
  const int length = GetWindowTextW(
      window, title.data(), static_cast<int>(title.size()));
  return length > 0 ? std::wstring(title.data(), length) : std::wstring();
}

bool SendKeyChord(WORD modifier, WORD key) {
  INPUT inputs[4]{};
  inputs[0].type = INPUT_KEYBOARD;
  inputs[0].ki.wVk = modifier;
  inputs[1].type = INPUT_KEYBOARD;
  inputs[1].ki.wVk = key;
  inputs[2].type = INPUT_KEYBOARD;
  inputs[2].ki.wVk = key;
  inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;
  inputs[3].type = INPUT_KEYBOARD;
  inputs[3].ki.wVk = modifier;
  inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;
  return SendInput(4, inputs, sizeof(INPUT)) == 4;
}

}  // namespace

bool NativeProtectionBridge::SendBrowserBack() {
  const HWND foreground = GetForegroundWindow();
  if (foreground == nullptr) return false;
  std::wstring executable = ForegroundProcessPath(foreground);
  Lowercase(&executable);
  if (executable.find(L"chrome.exe") == std::wstring::npos &&
      executable.find(L"msedge.exe") == std::wstring::npos &&
      executable.find(L"opera.exe") == std::wstring::npos &&
      executable.find(L"firefox.exe") == std::wstring::npos &&
      executable.find(L"ucbrowser.exe") == std::wstring::npos) return false;
  const std::wstring title_before = WindowTitle(foreground);
  if (SendKeyChord(VK_MENU, VK_LEFT)) {
    // A browser with no Back entry accepts the chord but leaves the protected
    // page in place. Compare only transient, device-local window state; never
    // persist or emit the title. If navigation did not become observable,
    // close the browser tab as the supported no-history fallback.
    Sleep(200);
    if (GetForegroundWindow() != foreground) return false;
    const std::wstring title_after = WindowTitle(foreground);
    if (!title_before.empty() && title_after != title_before) return true;
  }
  // If UIPI rejects Back, or no navigation was observable, use the
  // browser-scoped close-tab shortcut. Failure remains degraded while the
  // Pattern Interrupt is still presented.
  return SendKeyChord(VK_CONTROL, 'W');
}
