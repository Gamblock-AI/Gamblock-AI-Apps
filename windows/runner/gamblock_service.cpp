#include "gamblock_service.h"
#include <tlhelp32.h>
#include <psapi.h>
#include <string>
#include <vector>
#include <algorithm>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "psapi.lib")

// === Gamblock Service Implementation ===
//
// Security note (PRD §3.2): the service runs as LocalSystem and is protected
// against casual termination. Protection is achieved via the SCM failure
// actions configured in Install() (auto-restart on crash/kill) rather than by
// marking the process critical. Marking the process critical via
// RtlSetProcessIsCritical(TRUE) would BSOD the whole machine if the process
// ever died, which is unacceptable for a user-facing recovery product. We rely
// on auto-restart instead.

GamblockService& GamblockService::Instance() {
    static GamblockService instance;
    return instance;
}

GamblockService::~GamblockService() {
    StopWebSocketServer();
}

void WINAPI GamblockService::ServiceMain(DWORD argc, LPWSTR* argv) {
    auto& svc = Instance();
    svc.m_statusHandle = RegisterServiceCtrlHandlerExW(
        svc.m_serviceName.c_str(),
        HandlerEx, nullptr);

    if (!svc.m_statusHandle) return;

    svc.m_status.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    svc.m_status.dwCurrentState = SERVICE_START_PENDING;
    SetServiceStatus(svc.m_statusHandle, &svc.m_status);

    svc.m_status.dwCurrentState = SERVICE_RUNNING;
    SetServiceStatus(svc.m_statusHandle, &svc.m_status);

    // Main protection loop
    ServiceWorkerThread(nullptr);

    svc.m_status.dwCurrentState = SERVICE_STOPPED;
    SetServiceStatus(svc.m_statusHandle, &svc.m_status);
}

DWORD WINAPI GamblockService::ServiceWorkerThread(LPVOID) {
    auto& svc = Instance();

    // Start WebSocket for browser extension IPC
    svc.StartWebSocketServer(9090);

    // Harden the process (debug privileges for process inspection only —
    // NOT RtlSetProcessIsCritical, which would BSOD on termination).
    svc.EnableProcessHardening();

    // Main monitoring loop
    while (svc.m_status.dwCurrentState == SERVICE_RUNNING) {
        ProcessMonitor::ScanActiveProcesses();
        Sleep(2000); // Scan every 2 seconds
    }

    return 0;
}

bool GamblockService::Install() {
    SC_HANDLE scm = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_ALL_ACCESS);
    if (!scm) return false;

    wchar_t path[MAX_PATH];
    GetModuleFileNameW(nullptr, path, MAX_PATH);
    std::wstring cmd = std::wstring(L"\"") + path + L"\"";

    SC_HANDLE svc = CreateServiceW(
        scm, m_serviceName.c_str(), L"Gamblock AI Protection",
        SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS,
        SERVICE_AUTO_START, SERVICE_ERROR_NORMAL,
        cmd.c_str(), nullptr, nullptr, nullptr, nullptr, nullptr);

    if (svc) {
        // Failure actions — auto-restart on crash or kill (PRD §3.2 anti-tamper).
        // This is the safe replacement for marking the process critical: if the
        // service is terminated, SCM restarts it after 60s, then 120s. Recovery
        // counter resets after 24h of continuous uptime.
        SERVICE_FAILURE_ACTIONSW fa = {};
        SC_ACTION actions[3] = {};
        actions[0].Type = SC_ACTION_RESTART;
        actions[0].Delay = 60000;
        actions[1].Type = SC_ACTION_RESTART;
        actions[1].Delay = 120000;
        actions[2].Type = SC_ACTION_NONE;
        fa.dwResetPeriod = 86400;
        fa.lpRebootMsg = nullptr;
        fa.lpCommand = nullptr;
        fa.cActions = 3;
        fa.lpsaActions = actions;
        ChangeServiceConfig2W(svc, SERVICE_CONFIG_FAILURE_ACTIONS, &fa);

        // Allow the service to restart even before any user logs in.
        // (SERVICE_AUTO_START already covers boot start; this sets the delayed
        // autostart flag for reliability on slower machines.)
        BOOL delayed = TRUE;
        ChangeServiceConfig2W(svc, SERVICE_CONFIG_DELAYED_AUTO_START_INFO, &delayed);

        CloseServiceHandle(svc);
    }
    CloseServiceHandle(scm);
    return svc != nullptr;
}

bool GamblockService::Start() {
    SC_HANDLE scm = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
    if (!scm) return false;
    SC_HANDLE svc = OpenServiceW(scm, m_serviceName.c_str(), SERVICE_START);
    if (!svc) { CloseServiceHandle(scm); return false; }
    bool ok = StartServiceW(svc, 0, nullptr);
    CloseServiceHandle(svc);
    CloseServiceHandle(scm);
    return ok;
}

bool GamblockService::EnableProcessHardening() {
    // Acquire SeDebugPrivilege so we can inspect and terminate other processes.
    // This is used only for process scanning/termination authority — it does
    // NOT make this process critical (which would BSOD on death).
    HANDLE hToken;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken)) {
        LUID luid;
        if (LookupPrivilegeValueW(nullptr, SE_DEBUG_NAME, &luid)) {
            TOKEN_PRIVILEGES tp = {};
            tp.PrivilegeCount = 1;
            tp.Privileges[0].Luid = luid;
            tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
            AdjustTokenPrivileges(hToken, FALSE, &tp, 0, nullptr, nullptr);
        }
        CloseHandle(hToken);
    }

    // NOTE: We intentionally do NOT call RtlSetProcessIsCritical(TRUE).
    // A critical process triggers a BSOD if it is terminated, which is too
    // dangerous for a recovery product. Anti-tamper is instead provided by the
    // SCM auto-restart failure actions configured in Install().
    return true;
}

// WebSocket IPC contract (PRD §3.1 / §3.3):
//
// The service exposes ws://127.0.0.1:9090 for the browser extension. Protocol:
//   1. Extension connects and sends { "type": "auth", "token": "<pairing>" }.
//   2. Service validates the token against the token periodically generated by
//      the Gamblock desktop client. Reply { "type": "auth_ok" } or
//      { "type": "auth_denied" } and close on rejection.
//   3. On auth_ok, extension sends { "type": "dom_scan", "url", "title",
//      "headings", "anchorTexts", "timestamp" }.
//   4. Service feeds the DOM text to the local Logistic Regression model
//      (see ai_inference_stub.dart contract). If the score exceeds threshold,
//      the SERVICE executes the block + Pattern Interrupt — never the extension.
//
// Implementation is deferred (stubbed) because it requires a Windows-specific
// WebSocket library and cannot be built/validated in the current Linux dev
// environment. Keep this contract in sync with background.js.
bool GamblockService::StartWebSocketServer(int port) {
    m_wsRunning = true;
    // TODO: Implement the authenticated WebSocket server described above.
    // Recommended library: Beast (Boost) or a minimal hand-rolled HTTP/WS
    // upgrade on the loopback socket only. Bind strictly to 127.0.0.1.
    return true;
}

void GamblockService::StopWebSocketServer() {
    m_wsRunning = false;
}

void GamblockService::SetBlockCallback(BlockCallback cb) {
    m_blockCallback = cb;
}

// === Process Monitor ===

bool ProcessMonitor::ScanActiveProcesses() {
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return false;

    PROCESSENTRY32W pe = { sizeof(pe) };
    if (Process32FirstW(snapshot, &pe)) {
        do {
            std::wstring exeName(pe.szExeFile);
            std::transform(exeName.begin(), exeName.end(), exeName.begin(), ::tolower);

            // Check for known gambling apps by executable name.
            if (IsGamblingProcess(exeName, L"")) {
                TerminateProcessById(pe.th32ProcessID);
            }

            // Check the foreground window's title for gambling keywords
            // (PRD §3.2: Window Title Monitoring for portable .exe gambling apps).
            if (pe.th32ProcessID != 0) {
                HWND hwnd = GetForegroundWindow();
                if (hwnd) {
                    DWORD pid;
                    GetWindowThreadProcessId(hwnd, &pid);
                    if (pid == pe.th32ProcessID) {
                        wchar_t title[256];
                        GetWindowTextW(hwnd, title, 256);
                        std::wstring wTitle(title);
                        if (IsGamblingProcess(L"", wTitle)) {
                            TerminateProcessById(pe.th32ProcessID);
                        }
                    }
                }
            }
        } while (Process32NextW(snapshot, &pe));
    }

    CloseHandle(snapshot);
    return true;
}

bool ProcessMonitor::IsGamblingProcess(const std::wstring& exe, const std::wstring& title) {
    // Static keyword blacklist used as a fast first-pass filter. The primary
    // detection path for browser content is the on-device AI classifier fed by
    // the browser extension's DOM scans; this list covers portable .exe gambling
    // apps that never go through a browser (PRD §3.2).
    static const std::vector<std::wstring> keywords = {
        L"slot", L"casino", L"poker", L"judi", L"togel", L"betting",
        L"sportbook", L"bandar", L"domino", L"ceme", L"gaple"
    };

    std::wstring lower = exe + title;
    std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);

    for (const auto& kw : keywords) {
        if (lower.find(kw) != std::wstring::npos) {
            return true;
        }
    }
    return false;
}

void ProcessMonitor::TerminateProcessById(DWORD pid) {
    HANDLE h = OpenProcess(PROCESS_TERMINATE, FALSE, pid);
    if (h) {
        TerminateProcess(h, 1);
        CloseHandle(h);
    }
}
