#ifndef GAMBLOCK_SERVICE_H
#define GAMBLOCK_SERVICE_H

#include <windows.h>
#include <string>
#include <functional>

// Gamblock Windows Service — Background protection daemon
// Runs as LocalSystem, immune to Task Manager termination

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

    // WebSocket IPC with browser extension
    bool StartWebSocketServer(int port = 9090);
    void StopWebSocketServer();

    // Anti-tamper
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

// Process monitor — scans for gambling-related executables
namespace ProcessMonitor {
    bool Initialize();
    void Shutdown();
    bool ScanActiveProcesses();
    bool IsGamblingProcess(const std::wstring& exeName, const std::wstring& windowTitle);
    void TerminateProcessById(DWORD pid);
}

#endif // GAMBLOCK_SERVICE_H
