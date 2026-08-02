#include "protection_service.h"

#include <atomic>
#include <array>
#include <fstream>
#include <sstream>

#include "service_support.h"

namespace gamblock {
namespace {

constexpr DWORD kPipeOperationPollMs = 200;

bool WaitForPipeOperation(HANDLE pipe,
                          OVERLAPPED* operation,
                          const std::atomic<bool>& running,
                          DWORD* transferred) {
  while (running.load()) {
    const DWORD wait = WaitForSingleObject(operation->hEvent,
                                           kPipeOperationPollMs);
    if (wait == WAIT_OBJECT_0) {
      return GetOverlappedResult(pipe, operation, transferred, FALSE) != FALSE;
    }
    if (wait != WAIT_TIMEOUT) break;
  }
  CancelIoEx(pipe, operation);
  GetOverlappedResult(pipe, operation, transferred, TRUE);
  return false;
}

bool ConnectPipe(HANDLE pipe, const std::atomic<bool>& running) {
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) return false;
  OVERLAPPED operation{};
  operation.hEvent = event;
  const BOOL connected = ConnectNamedPipe(pipe, &operation);
  const DWORD error = connected ? ERROR_SUCCESS : GetLastError();
  DWORD transferred = 0;
  const bool complete = connected || error == ERROR_PIPE_CONNECTED ||
      (error == ERROR_IO_PENDING &&
       WaitForPipeOperation(pipe, &operation, running, &transferred));
  CloseHandle(event);
  return complete && running.load();
}

bool ReadPipeMessage(HANDLE pipe,
                     void* buffer,
                     DWORD capacity,
                     const std::atomic<bool>& running,
                     DWORD* read) {
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) return false;
  OVERLAPPED operation{};
  operation.hEvent = event;
  const BOOL completed = ReadFile(pipe, buffer, capacity, read, &operation);
  const DWORD error = completed ? ERROR_SUCCESS : GetLastError();
  const bool success = completed ||
      (error == ERROR_IO_PENDING &&
       WaitForPipeOperation(pipe, &operation, running, read));
  CloseHandle(event);
  return success && running.load();
}

}  // namespace

void ProtectionService::PipeLoop() {
  while (running_) {
    SECURITY_ATTRIBUTES attributes{};
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    PACL acl = nullptr;
    if (!BuildPipeSecurity(&attributes, &descriptor, &acl)) {
      Sleep(2000);
      continue;
    }
    HANDLE pipe = CreateNamedPipeW(
        kPipeName, PIPE_ACCESS_DUPLEX | FILE_FLAG_FIRST_PIPE_INSTANCE |
                       FILE_FLAG_OVERLAPPED,
        PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT |
            PIPE_REJECT_REMOTE_CLIENTS,
        1, 65536, 65536, 1000, &attributes);
    LocalFree(descriptor);
    LocalFree(acl);
    if (pipe == INVALID_HANDLE_VALUE) {
      Sleep(1000);
      continue;
    }
    if (!ConnectPipe(pipe, running_)) {
      CloseHandle(pipe);
      continue;
    }
    bool active = false;
    {
      std::lock_guard lock(pipe_mutex_);
      if (running_) {
        pipe_client_ = pipe;
        active = true;
      }
    }
    if (!active) {
      DisconnectNamedPipe(pipe);
      CloseHandle(pipe);
      break;
    }
    HandlePipeClient(pipe);
    {
      std::lock_guard lock(pipe_mutex_);
      if (pipe_client_ == pipe) pipe_client_ = INVALID_HANDLE_VALUE;
    }
    if (running_) FlushFileBuffers(pipe);
    DisconnectNamedPipe(pipe);
    CloseHandle(pipe);
  }
}

void ProtectionService::HandlePipeClient(HANDLE pipe) {
  std::array<char, 65536> buffer{};
  while (running_) {
    DWORD read = 0;
    if (!ReadPipeMessage(pipe, buffer.data(),
                         static_cast<DWORD>(buffer.size() - 1), running_,
                         &read) ||
        read == 0) break;
    buffer[read] = '\0';
    HandlePipeCommand(std::string(buffer.data(), read));
  }
}

void ProtectionService::HandlePipeCommand(const std::string& command) {
  const std::string type = JsonString(command, "type").value_or("");
  const std::string request_id = RequestId(command);
  if (type == "intervention_committed") {
    CompletePhase4Latency(
        JsonString(command, "evidence_id").value_or(""));
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"ok\":true}");
  } else if (type == "snapshot") {
    SendAgentEvent(SnapshotJson(request_id));
  } else if (type == "self_test") {
    ClassificationDecision positive;
    ClassificationDecision negative;
    {
      std::lock_guard lock(state_mutex_);
      positive = classifier_.Classify({
          "https://contoh-judi.invalid/slot-gacor", "", {}, {}});
      negative = classifier_.Classify({
          "https://kampus.ac.id/penelitian", "Portal penelitian universitas",
          {"Pendidikan dan beasiswa"}, {"Jurnal research"},
      });
    }
    std::ostringstream response;
    response << "{\"type\":\"response\",\"request_id\":\""
             << EscapeJson(request_id) << "\",\"passed\":"
             << (positive.block && !negative.block ? "true" : "false")
             << ",\"reason_code\":\""
             << (positive.block && !negative.block ? "fixtures_passed"
                                                   : "fixture_mismatch")
             << "\",\"model_version\":\""
             << EscapeJson(positive.model_version)
             << "\",\"ruleset_version\":\""
             << EscapeJson(positive.ruleset_version) << "\"}";
    SendAgentEvent(response.str());
  } else if (type == "get_pairing_token" || type == "rotate_pairing_token") {
    const std::string token = PairingToken(type == "rotate_pairing_token");
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"pairing_token\":\"" +
                   EscapeJson(token) + "\"}");
  } else if (type == "set_device") {
    device_id_ = JsonString(command, "device_id").value_or("");
    std::ofstream(DataDirectory() / L"device-id.txt", std::ios::trunc) << device_id_;
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"ok\":true}");
  } else if (type == "store_grant") {
    const auto grant_start = command.find("\"grant\"");
    const auto object_start = command.find('{', grant_start);
    const auto object_end = command.rfind('}');
    const bool stored = object_start != std::string::npos &&
                        object_end > object_start &&
                        StoreGrant(command.substr(object_start,
                                                  object_end - object_start));
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"ok\":" +
                   (stored ? "true" : "false") + "}");
  } else if (type == "current_aggregates") {
    SendAgentEvent(AggregatesJson(request_id, false));
  } else if (type == "drain_aggregates") {
    SendAgentEvent(AggregatesJson(request_id, true));
  } else if (type == "ack_aggregates") {
    AcknowledgeAggregates(command);
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"ok\":true}");
  } else if (type == "check_artifacts") {
    const bool loaded = UpdateArtifacts(
        JsonString(command, "base_url").value_or(""));
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"checked\":" +
                   (loaded ? "true" : "false") + "}");
  } else if (type == "settings_interaction") {
    const bool allowed = HasActiveGrant("uninstall");
    if (!allowed) {
      IncrementAggregate("tamper_detected");
      SendAgentEvent("{\"type\":\"approval_required\"}");
    }
    SendAgentEvent("{\"type\":\"response\",\"request_id\":\"" +
                   EscapeJson(request_id) + "\",\"allowed\":" +
                   (allowed ? "true" : "false") + "}");
  }
}

}  // namespace gamblock
