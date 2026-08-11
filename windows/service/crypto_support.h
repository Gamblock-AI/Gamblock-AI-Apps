#ifndef GAMBLOCK_SERVICE_CRYPTO_SUPPORT_H_
#define GAMBLOCK_SERVICE_CRYPTO_SUPPORT_H_

#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace gamblock {

std::optional<std::vector<unsigned char>> Sha256Digest(
    std::string_view value);
std::string Base64Encode(const std::vector<unsigned char>& bytes);
std::optional<std::vector<unsigned char>> Base64Decode(
    std::string_view value);
std::string Base64UrlEncode(const std::vector<unsigned char>& bytes);
std::optional<std::vector<unsigned char>> Base64UrlDecode(
    std::string_view value);

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_CRYPTO_SUPPORT_H_
