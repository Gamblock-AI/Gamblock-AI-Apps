#ifndef GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_
#define GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_

#include <winsock2.h>
#include <windows.h>

#include <atomic>
#include <map>
#include <mutex>
#include <set>
#include <string>
#include <thread>
#include <vector>

#include "../protection/hybrid_classifier.h"

namespace gamblock {

class ProtectionService {
 public:
  static ProtectionService& Instance();
  static void WINAPI ServiceMain(DWORD argc, wchar_t** argv);
  static DWORD WINAPI ControlHandler(DWORD control,
                                     DWORD event_type,
                                     void* event_data,
                                     void* context);

  bool Install();
  bool Uninstall();
  int RunConsole();

 private:
  ProtectionService() = default;
  ~ProtectionService();
  ProtectionService(const ProtectionService&) = delete;
  ProtectionService& operator=(const ProtectionService&) = delete;

  bool StartRuntime();
  void StopRuntime();
  void WebSocketLoop();
  void HandleWebSocketClient(SOCKET client);
  void PipeLoop();
  void HandlePipeClient(HANDLE pipe);
  void HandlePipeCommand(const std::string& command);
  void SendAgentEvent(const std::string& json);
  void EnsureUserAgentRunning();

  bool LoadArtifacts();
  bool UpdateArtifacts(const std::string& base_url);
  std::string SnapshotJson(const std::string& request_id);
  std::string PairingToken(bool rotate);
  bool StoreGrant(const std::string& grant_json);
  bool HasActiveGrant(const char* purpose = nullptr);
  void IncrementAggregate(const std::string& type);
  std::string AggregatesJson(const std::string& request_id,
                             bool completed_only);
  void AcknowledgeAggregates(const std::string& command);

  SERVICE_STATUS_HANDLE status_handle_ = nullptr;
  SERVICE_STATUS status_{};
  std::atomic<bool> running_{false};
  std::atomic<int> sensor_connections_{0};
  std::thread websocket_thread_;
  std::vector<std::thread> websocket_client_threads_;
  std::thread pipe_thread_;
  mutable std::mutex pipe_mutex_;
  HANDLE pipe_client_ = INVALID_HANDLE_VALUE;
  mutable std::mutex state_mutex_;
  mutable std::mutex client_mutex_;
  std::set<SOCKET> connected_clients_;
  std::set<SOCKET> authenticated_clients_;
  mutable std::mutex aggregate_mutex_;
  std::map<std::string, int> aggregates_;
  HybridClassifier classifier_;
  std::string artifact_error_;
  std::string device_id_;
};

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_
