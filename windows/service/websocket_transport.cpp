#include "service_support.h"

#include <bcrypt.h>
#include <wincrypt.h>

#include <regex>

namespace gamblock {

bool RecvExact(SOCKET socket, void* buffer, size_t bytes) {
  auto* target = static_cast<char*>(buffer);
  size_t received = 0;
  while (received < bytes) {
    const int result = recv(socket, target + received,
                            static_cast<int>(bytes - received), 0);
    if (result <= 0) return false;
    received += static_cast<size_t>(result);
  }
  return true;
}

bool SendExact(SOCKET socket, const void* buffer, size_t bytes) {
  const auto* source = static_cast<const char*>(buffer);
  size_t sent = 0;
  while (sent < bytes) {
    const int result = send(socket, source + sent,
                            static_cast<int>(bytes - sent), 0);
    if (result <= 0) return false;
    sent += static_cast<size_t>(result);
  }
  return true;
}

bool SetReceiveTimeout(SOCKET socket, DWORD timeout_ms) {
  return setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO,
                    reinterpret_cast<const char*>(&timeout_ms),
                    sizeof(timeout_ms)) == 0;
}

std::optional<std::pair<unsigned char, std::string>> ReadWebSocketFrame(
    SOCKET socket) {
  unsigned char header[2]{};
  if (!RecvExact(socket, header, sizeof(header))) return std::nullopt;
  if ((header[0] & 0x80) == 0 || (header[0] & 0x70) != 0) return std::nullopt;
  const unsigned char opcode = header[0] & 0x0f;
  const bool masked = (header[1] & 0x80) != 0;
  uint64_t length = header[1] & 0x7f;
  if (length == 126) {
    unsigned char extended[2]{};
    if (!RecvExact(socket, extended, sizeof(extended))) return std::nullopt;
    length = (static_cast<uint64_t>(extended[0]) << 8) | extended[1];
  } else if (length == 127) {
    unsigned char extended[8]{};
    if (!RecvExact(socket, extended, sizeof(extended))) return std::nullopt;
    length = 0;
    for (const auto byte : extended) length = (length << 8) | byte;
  }
  if (!masked || length > kMaximumFrameBytes) return std::nullopt;
  unsigned char mask[4]{};
  if (!RecvExact(socket, mask, sizeof(mask))) return std::nullopt;
  std::string payload(static_cast<size_t>(length), '\0');
  if (length > 0 && !RecvExact(socket, payload.data(), payload.size())) {
    return std::nullopt;
  }
  for (size_t index = 0; index < payload.size(); ++index) {
    payload[index] = static_cast<char>(
        static_cast<unsigned char>(payload[index]) ^ mask[index % 4]);
  }
  return std::make_pair(opcode, payload);
}

bool SendWebSocketFrame(SOCKET socket,
                        unsigned char opcode,
                        const std::string& payload) {
  std::vector<unsigned char> frame;
  frame.push_back(0x80 | opcode);
  if (payload.size() < 126) {
    frame.push_back(static_cast<unsigned char>(payload.size()));
  } else {
    frame.push_back(126);
    frame.push_back(static_cast<unsigned char>((payload.size() >> 8) & 0xff));
    frame.push_back(static_cast<unsigned char>(payload.size() & 0xff));
  }
  frame.insert(frame.end(), payload.begin(), payload.end());
  return SendExact(socket, frame.data(), frame.size());
}

std::string WebSocketAccept(const std::string& key) {
  const std::string source = key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
  BCRYPT_ALG_HANDLE algorithm = nullptr;
  BCRYPT_HASH_HANDLE hash = nullptr;
  DWORD object_bytes = 0;
  DWORD result_bytes = 0;
  DWORD hash_bytes = 0;
  if (BCryptOpenAlgorithmProvider(&algorithm, BCRYPT_SHA1_ALGORITHM, nullptr,
                                  0) != 0 ||
      BCryptGetProperty(algorithm, BCRYPT_OBJECT_LENGTH,
                        reinterpret_cast<PUCHAR>(&object_bytes),
                        sizeof(object_bytes), &result_bytes, 0) != 0 ||
      BCryptGetProperty(algorithm, BCRYPT_HASH_LENGTH,
                        reinterpret_cast<PUCHAR>(&hash_bytes),
                        sizeof(hash_bytes), &result_bytes, 0) != 0) {
    if (algorithm) BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  std::vector<unsigned char> object(object_bytes);
  std::vector<unsigned char> digest(hash_bytes);
  if (BCryptCreateHash(algorithm, &hash, object.data(), object_bytes, nullptr,
                       0, 0) != 0 ||
      BCryptHashData(hash,
                     reinterpret_cast<PUCHAR>(const_cast<char*>(source.data())),
                     static_cast<ULONG>(source.size()), 0) != 0 ||
      BCryptFinishHash(hash, digest.data(), hash_bytes, 0) != 0) {
    if (hash) BCryptDestroyHash(hash);
    BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  BCryptDestroyHash(hash);
  BCryptCloseAlgorithmProvider(algorithm, 0);
  DWORD base64_bytes = 0;
  CryptBinaryToStringA(digest.data(), hash_bytes,
                       CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF, nullptr,
                       &base64_bytes);
  std::string base64(base64_bytes, '\0');
  CryptBinaryToStringA(digest.data(), hash_bytes,
                       CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF,
                       base64.data(), &base64_bytes);
  if (!base64.empty() && base64.back() == '\0') base64.pop_back();
  return base64;
}

std::optional<std::string> HttpHeader(const std::string& request,
                                      const std::string& name) {
  const std::regex pattern("(?:^|\\r\\n)" + name +
                           "\\s*:\\s*([^\\r\\n]+)",
                           std::regex_constants::icase);
  std::smatch match;
  return std::regex_search(request, match, pattern)
             ? std::optional<std::string>(match[1].str())
             : std::nullopt;
}

}  // namespace gamblock
