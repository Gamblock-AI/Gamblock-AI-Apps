#include "gamblock_service.h"
#include <tlhelp32.h>
#include <psapi.h>
#include <string>
#include <vector>
#include <algorithm>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "psapi.lib")

// === Gamblock Service Implementation ===

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

    // Start process hardening
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
        // Set failure actions — restart on crash
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
    // Set process as critical — if killed, system BSODs
    // This prevents Task Manager termination
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

    // Mark process as critical
    typedef NTSTATUS(NTAPI *RtlSetProcessIsCritical)(BOOLEAN, PBOOLEAN, BOOLEAN);
    HMODULE ntdll = GetModuleHandleW(L"ntdll.dll");
    if (ntdll) {
        auto RtlSetProcessIsCritical = (RtlSetProcessIsCritical)GetProcAddress(ntdll, "RtlSetProcessIsCritical");
        if (RtlSetProcessIsCritical) {
            RtlSetProcessIsCritical(TRUE, nullptr, FALSE);
        }
    }
    return true;
}

bool GamblockService::StartWebSocketServer(int port) {
    m_wsRunning = true;
    // TODO: Implement WebSocket server for browser extension IPC
    // The server receives DOM text from the browser extension
    // and forwards it to the local AI classifier
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

            // Check for known gambling apps
            if (IsGamblingProcess(exeName, L"")) {
                TerminateProcessById(pe.th32ProcessID);
            }

            // Check window title for gambling keywords
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
    // Blacklist of known gambling process names and keywords
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
