#ifndef GAMBLOCK_SERVICE_H
#define GAMBLOCK_SERVICE_H

#include <windows.h>
#include <string>
#include <functional>

// Gamblock Windows Service — Background protection daemon (PRD §3.1 / §3.2)
//
// Runs as LocalSystem and is protected against casual termination via SCM
// failure actions (auto-restart on crash/kill). It is the SOLE authority for
// blocking decisions and Pattern Interrupt execution. The browser extension is
// only a passive DOM sensor that feeds this service over an authenticated
// WebSocket on ws://127.0.0.1:9090.
//
// IMPORTANT: do NOT mark this process critical (RtlSetProcessIsCritical). A
// critical process BSODs the machine on termination, which is unacceptable for
// a recovery product. Anti-tamper relies on auto-restart (see Install()).

class GamblockService {
public:
    static GamblockService& Instance();

    bool Install();
    bool Uninstall();
    bool Start();
    bool Stop();
    bool IsRunning() const;

    // AI engine integration
    void SetModelPath(const std::wstring& path);
    std::wstring GetModelPath() const;

    // Process monitoring
    using BlockCallback = std::function<void(const std::wstring& processName, const std::wstring& windowTitle)>;
    void SetBlockCallback(BlockCallback cb);

    // WebSocket IPC with browser extension (ws://127.0.0.1:9090).
    // See the contract documented in gamblock_service.cpp::StartWebSocketServer.
    bool StartWebSocketServer(int port = 9090);
    void StopWebSocketServer();

    // Process hardening (debug privilege for inspection only; NOT critical).
    bool EnableProcessHardening();
    bool VerifySignature();

private:
    GamblockService() = default;
    ~GamblockService();

    static DWORD WINAPI ServiceWorkerThread(LPVOID lpParam);
    static void WINAPI ServiceMain(DWORD argc, LPWSTR* argv);
    static DWORD WINAPI HandlerEx(DWORD control, DWORD eventType, LPVOID eventData, LPVOID context);

    SERVICE_STATUS_HANDLE m_statusHandle = nullptr;
    SERVICE_STATUS m_status = {};
    std::wstring m_modelPath;
    std::wstring m_serviceName = L"GamblockAIProtection";
    BlockCallback m_blockCallback;
    bool m_wsRunning = false;
};

// Process monitor — scans for gambling-related executables (PRD §3.2:
// Window Title Monitoring for portable .exe gambling apps).
namespace ProcessMonitor {
    bool Initialize();
    void Shutdown();
    bool ScanActiveProcesses();
    bool IsGamblingProcess(const std::wstring& exeName, const std::wstring& windowTitle);
    void TerminateProcessById(DWORD pid);
}

#endif // GAMBLOCK_SERVICE_H
