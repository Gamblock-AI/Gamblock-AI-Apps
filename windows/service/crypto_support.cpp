#include "crypto_support.h"

#include <windows.h>
#include <bcrypt.h>

#include <array>
#include <limits>
#include <utility>

namespace gamblock {
namespace {

constexpr char kBase64Alphabet[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
constexpr char kBase64UrlAlphabet[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

std::string EncodeBase64(const std::vector<unsigned char>& bytes,
                         const char* alphabet,
                         bool padded) {
  std::string output;
  output.reserve(((bytes.size() + 2) / 3) * 4);
  for (size_t index = 0; index < bytes.size(); index += 3) {
    const unsigned int first = bytes[index];
    const unsigned int second =
        index + 1 < bytes.size() ? bytes[index + 1] : 0;
    const unsigned int third =
        index + 2 < bytes.size() ? bytes[index + 2] : 0;
    const unsigned int block = (first << 16) | (second << 8) | third;
    output.push_back(alphabet[(block >> 18) & 0x3f]);
    output.push_back(alphabet[(block >> 12) & 0x3f]);
    if (index + 1 < bytes.size()) {
      output.push_back(alphabet[(block >> 6) & 0x3f]);
    } else if (padded) {
      output.push_back('=');
    }
    if (index + 2 < bytes.size()) {
      output.push_back(alphabet[block & 0x3f]);
    } else if (padded) {
      output.push_back('=');
    }
  }
  return output;
}

int DecodeCharacter(char character, bool url_safe) {
  if (character >= 'A' && character <= 'Z') return character - 'A';
  if (character >= 'a' && character <= 'z') return character - 'a' + 26;
  if (character >= '0' && character <= '9') return character - '0' + 52;
  if (character == (url_safe ? '-' : '+')) return 62;
  if (character == (url_safe ? '_' : '/')) return 63;
  return -1;
}

std::optional<std::vector<unsigned char>> DecodeBase64(
    std::string_view value,
    bool url_safe) {
  if (value.size() > static_cast<size_t>(std::numeric_limits<ULONG>::max())) {
    return std::nullopt;
  }
  if (url_safe && value.find('=') != std::string_view::npos) {
    return std::nullopt;
  }
  if ((!url_safe && value.size() % 4 != 0) ||
      (url_safe && value.size() % 4 == 1)) {
    return std::nullopt;
  }

  size_t padding = 0;
  if (!url_safe && !value.empty() && value.back() == '=') {
    padding = 1;
    if (value.size() > 1 && value[value.size() - 2] == '=') padding = 2;
  }
  const size_t content_size = value.size() - padding;
  for (size_t index = 0; index < content_size; ++index) {
    if (DecodeCharacter(value[index], url_safe) < 0) return std::nullopt;
  }
  for (size_t index = content_size; index < value.size(); ++index) {
    if (value[index] != '=') return std::nullopt;
  }
  if (!url_safe) {
    if (padding > 2 || (padding == 1 && content_size % 4 != 3) ||
        (padding == 2 && content_size % 4 != 2)) {
      return std::nullopt;
    }
  }

  std::vector<unsigned char> output;
  output.reserve((content_size * 6) / 8);
  unsigned int accumulator = 0;
  int bits = 0;
  for (size_t index = 0; index < content_size; ++index) {
    accumulator = (accumulator << 6) |
                  static_cast<unsigned int>(DecodeCharacter(value[index],
                                                             url_safe));
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      output.push_back(
          static_cast<unsigned char>((accumulator >> bits) & 0xff));
    }
  }
  if (bits > 0 && (accumulator & ((1u << bits) - 1u)) != 0) {
    return std::nullopt;
  }

  const std::string canonical = EncodeBase64(
      output, url_safe ? kBase64UrlAlphabet : kBase64Alphabet, !url_safe);
  if (canonical != value) return std::nullopt;
  return output;
}

}  // namespace

std::optional<std::vector<unsigned char>> Sha256Digest(
    std::string_view value) {
  if (value.size() > static_cast<size_t>(std::numeric_limits<ULONG>::max())) {
    return std::nullopt;
  }
  BCRYPT_ALG_HANDLE algorithm = nullptr;
  BCRYPT_HASH_HANDLE hash = nullptr;
  DWORD object_bytes = 0;
  DWORD digest_bytes = 0;
  DWORD returned = 0;
  if (BCryptOpenAlgorithmProvider(&algorithm, BCRYPT_SHA256_ALGORITHM, nullptr,
                                  0) != 0 ||
      BCryptGetProperty(algorithm, BCRYPT_OBJECT_LENGTH,
                        reinterpret_cast<PUCHAR>(&object_bytes),
                        sizeof(object_bytes), &returned, 0) != 0 ||
      BCryptGetProperty(algorithm, BCRYPT_HASH_LENGTH,
                        reinterpret_cast<PUCHAR>(&digest_bytes),
                        sizeof(digest_bytes), &returned, 0) != 0) {
    if (algorithm != nullptr) BCryptCloseAlgorithmProvider(algorithm, 0);
    return std::nullopt;
  }
  std::vector<unsigned char> object(object_bytes);
  std::vector<unsigned char> digest(digest_bytes);
  const auto* data = reinterpret_cast<const unsigned char*>(value.data());
  const bool created =
      BCryptCreateHash(algorithm, &hash, object.data(), object_bytes, nullptr,
                       0, 0) == 0;
  const bool updated =
      created &&
      BCryptHashData(hash, const_cast<PUCHAR>(data),
                     static_cast<ULONG>(value.size()), 0) == 0;
  const bool finished =
      updated && BCryptFinishHash(hash, digest.data(), digest_bytes, 0) == 0;
  if (hash != nullptr) BCryptDestroyHash(hash);
  BCryptCloseAlgorithmProvider(algorithm, 0);
  return finished ? std::optional<std::vector<unsigned char>>(std::move(digest))
                  : std::nullopt;
}

std::string Base64Encode(const std::vector<unsigned char>& bytes) {
  return EncodeBase64(bytes, kBase64Alphabet, true);
}

std::optional<std::vector<unsigned char>> Base64Decode(
    std::string_view value) {
  return DecodeBase64(value, false);
}

std::string Base64UrlEncode(const std::vector<unsigned char>& bytes) {
  return EncodeBase64(bytes, kBase64UrlAlphabet, false);
}

std::optional<std::vector<unsigned char>> Base64UrlDecode(
    std::string_view value) {
  return DecodeBase64(value, true);
}

}  // namespace gamblock
