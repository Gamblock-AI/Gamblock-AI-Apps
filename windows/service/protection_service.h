#ifndef GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_
#define GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_

#include <winsock2.h>
#include <windows.h>

#include <atomic>
#include <chrono>
#include <cstdint>
#include <condition_variable>
#include <map>
#include <mutex>
#include <optional>
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
  bool Uninstall(bool require_grant = true);
  bool BeginApprovedRemoval();
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
  void FlushPendingIntervention();
  void RequestUserAgent(DWORD session_id);
  void UserAgentLoop();
  void EnsureUserAgentRunning();

  bool LoadArtifacts();
  std::string SnapshotJson(const std::string& request_id);
  std::string PairingToken(bool rotate);
  bool LoadDeviceId(const std::string& device_id);
  bool SetDeviceId(const std::string& device_id);
  std::string GrantKeyEnrollmentJson(const std::string& request_id,
                                     const std::string& device_id,
                                     const std::string& challenge_token);
  bool StoreGrant(const std::string& compact_jws);
  bool HasActiveGrant(const char* purpose = nullptr);
  bool ConsumeActiveGrant(const char* purpose);
  bool CheckActiveGrant(const char* purpose, bool consume);
  void IncrementAggregate(const std::string& type);
  std::string AggregatesJson(const std::string& request_id,
                             bool completed_only);
  void AcknowledgeAggregates(const std::string& command);
  std::string BeginPhase4Latency(
      std::chrono::steady_clock::time_point input_ready,
      double pre_input_duration_ms,
      double extraction_duration_ms,
      double queue_duration_ms,
      double classification_duration_ms,
      const ClassificationDecision& decision);
  void CompletePhase4Latency(const std::string& evidence_id);
  std::optional<std::string> BeginIntervention(
      std::chrono::steady_clock::time_point input_ready,
      double pre_input_duration_ms,
      double extraction_duration_ms,
      double queue_duration_ms,
      double classification_duration_ms,
      const ClassificationDecision& decision);
  bool AcknowledgeInterventionVisible(const std::string& intervention_id);
  bool CompleteIntervention(const std::string& intervention_id);
  bool RecordBlockAction(const std::string& intervention_id, bool succeeded);

  struct PendingPhase4Latency {
    std::chrono::steady_clock::time_point input_ready;
    double pre_input_duration_ms = 0;
    double extraction_duration_ms = 0;
    double queue_duration_ms = 0;
    double classification_duration_ms = 0;
    std::string run_id;
    std::string device_alias;
    std::string scenario;
    std::string model_version;
    std::string ruleset_version;
  };

  struct PendingIntervention {
    std::string intervention_id;
    std::string reason_code;
    std::string model_version;
    std::string ruleset_version;
    std::string evidence_id;
    std::chrono::steady_clock::time_point deadline;
    bool visible = false;
    bool block_action_reported = false;
  };

  SERVICE_STATUS_HANDLE status_handle_ = nullptr;
  SERVICE_STATUS status_{};
  std::atomic<bool> running_{false};
  std::atomic<int> sensor_connections_{0};
  std::thread websocket_thread_;
  std::vector<std::thread> websocket_client_threads_;
  std::thread pipe_thread_;
  std::thread user_agent_thread_;
  mutable std::mutex pipe_mutex_;
  HANDLE pipe_client_ = INVALID_HANDLE_VALUE;
  HANDLE pipe_listener_ = INVALID_HANDLE_VALUE;
  std::mutex user_agent_mutex_;
  std::condition_variable user_agent_wakeup_;
  bool user_agent_requested_ = false;
  std::atomic<DWORD> interactive_session_id_{0xffffffff};
  std::chrono::steady_clock::time_point last_user_agent_launch_{};
  mutable std::mutex state_mutex_;
  mutable std::mutex client_mutex_;
  std::set<SOCKET> connected_clients_;
  std::set<SOCKET> authenticated_clients_;
  mutable std::mutex aggregate_mutex_;
  std::map<std::string, int> aggregates_;
  std::mutex phase4_evidence_mutex_;
  std::map<std::string, PendingPhase4Latency> pending_phase4_latency_;
  std::atomic<unsigned long> phase4_evidence_sequence_{1};
  std::mutex intervention_mutex_;
  std::optional<PendingIntervention> pending_intervention_;
  std::atomic<bool> block_action_degraded_{false};
  HybridClassifier classifier_;
  std::string artifact_error_;
  mutable std::mutex device_mutex_;
  std::string device_id_;
  mutable std::mutex grant_mutex_;
  std::string active_grant_action_;
  std::string active_grant_token_id_;
  std::int64_t active_grant_expires_at_ = 0;
  std::chrono::steady_clock::time_point active_grant_deadline_{};
};

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_PROTECTION_SERVICE_H_
