#ifndef GAMBLOCK_SERVICE_SUPPORT_H_
#define GAMBLOCK_SERVICE_SUPPORT_H_

#include <winsock2.h>
#include <windows.h>

#include <filesystem>
#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace gamblock {

inline constexpr wchar_t kServiceName[] = L"GamblockAIProtection";
inline constexpr wchar_t kPipeName[] = L"\\\\.\\pipe\\GamblockAIProtection";
inline constexpr int kWebSocketPort = 9090;
inline constexpr size_t kMaximumHttpBytes = 16384;
inline constexpr size_t kMaximumFrameBytes = 65536;
inline constexpr size_t kMaximumDomMessageBytes = 32768;
inline constexpr DWORD kWebSocketAcceptPollMs = 10;
inline constexpr DWORD kWebSocketHandshakeTimeoutMs = 10000;
inline constexpr DWORD kWebSocketIdleTimeoutMs = 45000;

std::filesystem::path ExecutableDirectory();
std::filesystem::path DataDirectory();
std::optional<std::string> ReadTextFile(const std::filesystem::path& path);
std::string Sha256File(const std::filesystem::path& path);
std::string Sha256Bytes(const std::vector<unsigned char>& bytes);
std::optional<std::pair<std::filesystem::path, std::filesystem::path>>
VerifiedArtifactPair(const std::filesystem::path& directory);
std::string Narrow(const std::wstring& value);
std::wstring Widen(const std::string& value);
std::string EscapeJson(const std::string& value);
std::optional<std::string> JsonString(const std::string& json,
                                      const std::string& key);
std::optional<double> JsonNumber(const std::string& json,
                                 const std::string& key);
std::optional<bool> JsonBool(const std::string& json,
                             const std::string& key);
std::vector<std::string> JsonStringArray(const std::string& json,
                                         const std::string& key,
                                         size_t maximum_items,
                                         size_t maximum_item_bytes);
std::string RequestId(const std::string& command);
std::string UtcDate();
bool ConstantTimeEqual(const std::string& left, const std::string& right);

std::vector<unsigned char> RandomBytes(size_t count);
std::string Hex(const std::vector<unsigned char>& bytes);
bool WriteProtected(const std::filesystem::path& path,
                    const std::string& cleartext);
std::optional<std::string> ReadProtected(const std::filesystem::path& path);
bool IsFuture(const std::string& expiry);

bool RecvExact(SOCKET socket, void* buffer, size_t bytes);
bool SendExact(SOCKET socket, const void* buffer, size_t bytes);
bool SetReceiveTimeout(SOCKET socket, DWORD timeout_ms);
std::optional<std::pair<unsigned char, std::string>> ReadWebSocketFrame(
    SOCKET socket);
bool SendWebSocketFrame(SOCKET socket,
                        unsigned char opcode,
                        const std::string& payload);
std::string WebSocketAccept(const std::string& key);
std::optional<std::string> HttpHeader(const std::string& request,
                                      const std::string& name);

bool BuildPipeSecurity(DWORD session_id,
                       SECURITY_ATTRIBUTES* attributes,
                       PSECURITY_DESCRIPTOR* descriptor,
                       PACL* acl);

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_SUPPORT_H_
