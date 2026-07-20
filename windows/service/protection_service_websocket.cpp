#include "protection_service.h"

#include <algorithm>
#include <array>
#include <chrono>
#include <cctype>
#include <sstream>

#include <ws2tcpip.h>

#include "service_support.h"

namespace gamblock {

void ProtectionService::WebSocketLoop() {
  const SOCKET listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (listener == INVALID_SOCKET) return;
  BOOL exclusive = TRUE;
  setsockopt(listener, SOL_SOCKET, SO_EXCLUSIVEADDRUSE,
             reinterpret_cast<const char*>(&exclusive), sizeof(exclusive));
  sockaddr_in address{};
  address.sin_family = AF_INET;
  address.sin_port = htons(kWebSocketPort);
  inet_pton(AF_INET, "127.0.0.1", &address.sin_addr);
  if (bind(listener, reinterpret_cast<sockaddr*>(&address),
           sizeof(address)) == SOCKET_ERROR ||
      listen(listener, 4) == SOCKET_ERROR) {
    closesocket(listener);
    return;
  }
  u_long non_blocking = 1;
  if (ioctlsocket(listener, FIONBIO, &non_blocking) == SOCKET_ERROR) {
    closesocket(listener);
    return;
  }
  while (running_) {
    SOCKET client = accept(listener, nullptr, nullptr);
    if (client == INVALID_SOCKET) {
      if (!running_) break;
      if (WSAGetLastError() == WSAEWOULDBLOCK) Sleep(100);
      continue;
    }
    bool accepted = false;
    {
      std::lock_guard lock(client_mutex_);
      if (running_) {
        connected_clients_.insert(client);
        accepted = true;
      }
    }
    if (!accepted) {
      shutdown(client, SD_BOTH);
      closesocket(client);
      break;
    }
    websocket_client_threads_.emplace_back(
        &ProtectionService::HandleWebSocketClient, this, client);
  }
  closesocket(listener);
}

void ProtectionService::HandleWebSocketClient(SOCKET client) {
  bool sensor_counted = false;
  const auto close_client = [this, client, &sensor_counted] {
    {
      std::lock_guard lock(client_mutex_);
      authenticated_clients_.erase(client);
      connected_clients_.erase(client);
    }
    if (sensor_counted) {
      sensor_connections_--;
      SendAgentEvent(SnapshotJson(""));
    }
    shutdown(client, SD_BOTH);
    closesocket(client);
  };
  SetReceiveTimeout(client, kWebSocketHandshakeTimeoutMs);
  std::string request;
  std::array<char, 2048> buffer{};
  while (request.find("\r\n\r\n") == std::string::npos &&
         request.size() < kMaximumHttpBytes) {
    const int received = recv(client, buffer.data(), static_cast<int>(buffer.size()), 0);
    if (received <= 0) {
      close_client();
      return;
    }
    request.append(buffer.data(), received);
  }
  const auto key = HttpHeader(request, "Sec-WebSocket-Key");
  const auto origin = HttpHeader(request, "Origin");
  const auto upgrade = HttpHeader(request, "Upgrade");
  const auto connection_header = HttpHeader(request, "Connection");
  const auto version = HttpHeader(request, "Sec-WebSocket-Version");
  const bool valid_origin = origin &&
      (origin->rfind("chrome-extension://", 0) == 0 ||
       origin->rfind("edge-extension://", 0) == 0);
  if (!key || !upgrade || !connection_header || !version || !valid_origin ||
      *version != "13" || request.rfind("GET / HTTP/1.1", 0) != 0) {
    constexpr char kForbiddenResponse[] = "HTTP/1.1 403 Forbidden\r\n\r\n";
    SendExact(client, kForbiddenResponse, sizeof(kForbiddenResponse) - 1);
    close_client();
    return;
  }
  std::string upgraded = *upgrade;
  std::transform(upgraded.begin(), upgraded.end(), upgraded.begin(),
                 [](unsigned char value) -> char {
                   return static_cast<char>(std::tolower(value));
                 });
  std::string connection_value = *connection_header;
  std::transform(connection_value.begin(), connection_value.end(),
                 connection_value.begin(),
                 [](unsigned char value) -> char {
                   return static_cast<char>(std::tolower(value));
                 });
  if (upgraded != "websocket" ||
      connection_value.find("upgrade") == std::string::npos) {
    close_client();
    return;
  }
  const std::string accept = WebSocketAccept(*key);
  const std::string response =
      "HTTP/1.1 101 Switching Protocols\r\n"
      "Upgrade: websocket\r\n"
      "Connection: Upgrade\r\n"
      "Sec-WebSocket-Accept: " + accept + "\r\n\r\n";
  if (!SendExact(client, response.data(), response.size())) {
    close_client();
    return;
  }

  bool authenticated = false;
  int scans_in_window = 0;
  auto rate_window = std::chrono::steady_clock::now();
  while (running_) {
    const auto frame = ReadWebSocketFrame(client);
    if (!frame) break;
    const auto [opcode, payload] = *frame;
    if (opcode == 0x8) break;
    if (opcode == 0x9) {
      SendWebSocketFrame(client, 0xA, payload);
      continue;
    }
    if (opcode != 0x1) continue;
    const std::string type = JsonString(payload, "type").value_or("");
    if (!authenticated) {
      if (type != "auth") break;
      const std::string supplied = JsonString(payload, "token").value_or("");
      const std::string expected = PairingToken(false);
      if (expected.empty() || !ConstantTimeEqual(supplied, expected)) {
        SendWebSocketFrame(client, 0x1, "{\"type\":\"auth_denied\"}");
        break;
      }
      authenticated = true;
      if (!SetReceiveTimeout(client, kWebSocketIdleTimeoutMs)) break;
      sensor_counted = true;
      sensor_connections_++;
      {
        std::lock_guard lock(client_mutex_);
        authenticated_clients_.insert(client);
      }
      SendWebSocketFrame(client, 0x1, "{\"type\":\"auth_ok\"}");
      SendAgentEvent(SnapshotJson(""));
      continue;
    }
    if (type == "ping") {
      SendWebSocketFrame(client, 0x1, "{\"type\":\"pong\"}");
      continue;
    }
    if (type != "dom_scan" || payload.size() > kMaximumDomMessageBytes ||
        HasActiveGrant()) continue;
    const auto now = std::chrono::steady_clock::now();
    if (now - rate_window > std::chrono::seconds(10)) {
      rate_window = now;
      scans_in_window = 0;
    }
    if (++scans_in_window > 30) continue;
    ClassificationInput input;
    input.url = JsonString(payload, "url").value_or("");
    input.title = JsonString(payload, "title").value_or("");
    input.headings = JsonStringArray(payload, "headings", 32, 256);
    input.anchor_texts = JsonStringArray(payload, "anchorTexts", 64, 256);
    ClassificationDecision decision;
    {
      std::lock_guard lock(state_mutex_);
      decision = classifier_.Classify(input);
    }
    if (decision.block) {
      IncrementAggregate("block_count_sync");
      IncrementAggregate("intervention_shown");
      EnsureUserAgentRunning();
      std::ostringstream event;
      event << "{\"type\":\"intervention_shown\",\"reason_code\":\""
            << EscapeJson(decision.reason_code)
            << "\",\"model_version\":\""
            << EscapeJson(decision.model_version)
            << "\",\"ruleset_version\":\""
            << EscapeJson(decision.ruleset_version) << "\"}";
      SendAgentEvent(event.str());
    }
  }
  close_client();
}

}  // namespace gamblock
