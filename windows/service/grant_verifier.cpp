#include "grant_verifier.h"

#include <windows.h>
#include <bcrypt.h>
#include <wincrypt.h>

#include <array>
#include <charconv>
#include <cstring>
#include <map>
#include <string_view>
#include <system_error>
#include <utility>
#include <vector>

#include "crypto_support.h"

namespace gamblock {
namespace {

constexpr size_t kMaximumTokenBytes = 32768;
constexpr size_t kMaximumTrustStoreBytes = 32768;
constexpr std::int64_t kClockSkewSeconds = 60;
constexpr std::int64_t kMaximumSensitiveGrantSeconds = 10 * 60;
constexpr std::array<std::int64_t, 4> kPauseGrantSeconds = {
    15 * 60, 30 * 60, 60 * 60, 120 * 60};

struct JsonValue {
  enum class Type { kNull, kBoolean, kString, kNumber, kObject, kArray };

  Type type = Type::kNull;
  bool boolean = false;
  std::string text;
  std::map<std::string, JsonValue> object;
  std::vector<JsonValue> array;
};

class JsonParser {
 public:
  explicit JsonParser(std::string_view input) : input_(input) {}

  bool Parse(JsonValue* output) {
    SkipWhitespace();
    if (!ParseValue(0, output)) return false;
    SkipWhitespace();
    return position_ == input_.size();
  }

 private:
  static bool IsHex(char character) {
    return (character >= '0' && character <= '9') ||
           (character >= 'a' && character <= 'f') ||
           (character >= 'A' && character <= 'F');
  }

  static unsigned int HexValue(char character) {
    if (character >= '0' && character <= '9') return character - '0';
    if (character >= 'a' && character <= 'f') return character - 'a' + 10;
    return character - 'A' + 10;
  }

  static void AppendUtf8(unsigned int code_point, std::string* output) {
    if (code_point <= 0x7f) {
      output->push_back(static_cast<char>(code_point));
    } else if (code_point <= 0x7ff) {
      output->push_back(static_cast<char>(0xc0 | (code_point >> 6)));
      output->push_back(static_cast<char>(0x80 | (code_point & 0x3f)));
    } else if (code_point <= 0xffff) {
      output->push_back(static_cast<char>(0xe0 | (code_point >> 12)));
      output->push_back(
          static_cast<char>(0x80 | ((code_point >> 6) & 0x3f)));
      output->push_back(static_cast<char>(0x80 | (code_point & 0x3f)));
    } else {
      output->push_back(static_cast<char>(0xf0 | (code_point >> 18)));
      output->push_back(
          static_cast<char>(0x80 | ((code_point >> 12) & 0x3f)));
      output->push_back(
          static_cast<char>(0x80 | ((code_point >> 6) & 0x3f)));
      output->push_back(static_cast<char>(0x80 | (code_point & 0x3f)));
    }
  }

  bool ParseHex4(unsigned int* value) {
    if (position_ + 4 > input_.size()) return false;
    unsigned int parsed = 0;
    for (size_t index = 0; index < 4; ++index) {
      const char character = input_[position_++];
      if (!IsHex(character)) return false;
      parsed = (parsed << 4) | HexValue(character);
    }
    *value = parsed;
    return true;
  }

  bool ParseString(std::string* output) {
    if (position_ >= input_.size() || input_[position_++] != '"') return false;
    output->clear();
    while (position_ < input_.size()) {
      const unsigned char character =
          static_cast<unsigned char>(input_[position_++]);
      if (character == '"') return output->size() <= kMaximumTokenBytes;
      if (character < 0x20) return false;
      if (character != '\\') {
        output->push_back(static_cast<char>(character));
        continue;
      }
      if (position_ >= input_.size()) return false;
      const char escaped = input_[position_++];
      switch (escaped) {
        case '"': output->push_back('"'); break;
        case '\\': output->push_back('\\'); break;
        case '/': output->push_back('/'); break;
        case 'b': output->push_back('\b'); break;
        case 'f': output->push_back('\f'); break;
        case 'n': output->push_back('\n'); break;
        case 'r': output->push_back('\r'); break;
        case 't': output->push_back('\t'); break;
        case 'u': {
          unsigned int code_point = 0;
          if (!ParseHex4(&code_point)) return false;
          if (code_point >= 0xd800 && code_point <= 0xdbff) {
            if (position_ + 2 > input_.size() || input_[position_++] != '\\' ||
                input_[position_++] != 'u') {
              return false;
            }
            unsigned int low = 0;
            if (!ParseHex4(&low) || low < 0xdc00 || low > 0xdfff) return false;
            code_point = 0x10000 + ((code_point - 0xd800) << 10) +
                         (low - 0xdc00);
          } else if (code_point >= 0xdc00 && code_point <= 0xdfff) {
            return false;
          }
          AppendUtf8(code_point, output);
          break;
        }
        default: return false;
      }
    }
    return false;
  }

  bool ParseNumber(std::string* output) {
    const size_t start = position_;
    if (position_ < input_.size() && input_[position_] == '-') ++position_;
    if (position_ >= input_.size()) return false;
    if (input_[position_] == '0') {
      ++position_;
      if (position_ < input_.size() && input_[position_] >= '0' &&
          input_[position_] <= '9') {
        return false;
      }
    } else {
      if (input_[position_] < '1' || input_[position_] > '9') return false;
      while (position_ < input_.size() && input_[position_] >= '0' &&
             input_[position_] <= '9') {
        ++position_;
      }
    }
    if (position_ < input_.size() && input_[position_] == '.') {
      ++position_;
      const size_t fraction_start = position_;
      while (position_ < input_.size() && input_[position_] >= '0' &&
             input_[position_] <= '9') {
        ++position_;
      }
      if (position_ == fraction_start) return false;
    }
    if (position_ < input_.size() &&
        (input_[position_] == 'e' || input_[position_] == 'E')) {
      ++position_;
      if (position_ < input_.size() &&
          (input_[position_] == '+' || input_[position_] == '-')) {
        ++position_;
      }
      const size_t exponent_start = position_;
      while (position_ < input_.size() && input_[position_] >= '0' &&
             input_[position_] <= '9') {
        ++position_;
      }
      if (position_ == exponent_start) return false;
    }
    output->assign(input_.substr(start, position_ - start));
    return true;
  }

  bool ParseObject(size_t depth, JsonValue* output) {
    ++position_;
    output->type = JsonValue::Type::kObject;
    SkipWhitespace();
    if (position_ < input_.size() && input_[position_] == '}') {
      ++position_;
      return true;
    }
    while (position_ < input_.size() && output->object.size() < 128) {
      std::string key;
      if (!ParseString(&key)) return false;
      SkipWhitespace();
      if (position_ >= input_.size() || input_[position_++] != ':') return false;
      SkipWhitespace();
      JsonValue value;
      if (!ParseValue(depth + 1, &value)) return false;
      if (!output->object.emplace(std::move(key), std::move(value)).second) {
        return false;
      }
      SkipWhitespace();
      if (position_ >= input_.size()) return false;
      if (input_[position_] == '}') {
        ++position_;
        return true;
      }
      if (input_[position_++] != ',') return false;
      SkipWhitespace();
    }
    return false;
  }

  bool ParseArray(size_t depth, JsonValue* output) {
    ++position_;
    output->type = JsonValue::Type::kArray;
    SkipWhitespace();
    if (position_ < input_.size() && input_[position_] == ']') {
      ++position_;
      return true;
    }
    while (position_ < input_.size() && output->array.size() < 128) {
      JsonValue value;
      if (!ParseValue(depth + 1, &value)) return false;
      output->array.push_back(std::move(value));
      SkipWhitespace();
      if (position_ >= input_.size()) return false;
      if (input_[position_] == ']') {
        ++position_;
        return true;
      }
      if (input_[position_++] != ',') return false;
      SkipWhitespace();
    }
    return false;
  }

  bool ParseValue(size_t depth, JsonValue* output) {
    if (depth > 8 || position_ >= input_.size()) return false;
    const char character = input_[position_];
    if (character == '{') return ParseObject(depth, output);
    if (character == '[') return ParseArray(depth, output);
    if (character == '"') {
      output->type = JsonValue::Type::kString;
      return ParseString(&output->text);
    }
    if (character == '-' || (character >= '0' && character <= '9')) {
      output->type = JsonValue::Type::kNumber;
      return ParseNumber(&output->text);
    }
    if (input_.substr(position_, 4) == "true") {
      position_ += 4;
      output->type = JsonValue::Type::kBoolean;
      output->boolean = true;
      return true;
    }
    if (input_.substr(position_, 5) == "false") {
      position_ += 5;
      output->type = JsonValue::Type::kBoolean;
      output->boolean = false;
      return true;
    }
    if (input_.substr(position_, 4) == "null") {
      position_ += 4;
      output->type = JsonValue::Type::kNull;
      return true;
    }
    return false;
  }

  void SkipWhitespace() {
    while (position_ < input_.size() &&
           (input_[position_] == ' ' || input_[position_] == '\t' ||
            input_[position_] == '\r' || input_[position_] == '\n')) {
      ++position_;
    }
  }

  std::string_view input_;
  size_t position_ = 0;
};

void SetError(std::string* error, const char* value) {
  if (error != nullptr) *error = value;
}

const JsonValue* Field(const JsonValue& object, const char* name) {
  if (object.type != JsonValue::Type::kObject) return nullptr;
  const auto found = object.object.find(name);
  return found == object.object.end() ? nullptr : &found->second;
}

const std::string* StringField(const JsonValue& object, const char* name) {
  const JsonValue* value = Field(object, name);
  return value != nullptr && value->type == JsonValue::Type::kString
             ? &value->text
             : nullptr;
}

std::optional<std::int64_t> IntegerField(const JsonValue& object,
                                         const char* name) {
  const JsonValue* value = Field(object, name);
  if (value == nullptr || value->type != JsonValue::Type::kNumber ||
      value->text.empty() || value->text.find_first_of(".eE") !=
                                 std::string::npos) {
    return std::nullopt;
  }
  std::int64_t parsed = 0;
  const auto result = std::from_chars(value->text.data(),
                                      value->text.data() + value->text.size(),
                                      parsed);
  if (result.ec != std::errc() ||
      result.ptr != value->text.data() + value->text.size()) {
    return std::nullopt;
  }
  return parsed;
}

bool HasExactAudience(const JsonValue& payload,
                      const char* expected_audience) {
  const JsonValue* audience = Field(payload, "aud");
  if (audience == nullptr) return false;
  if (audience->type == JsonValue::Type::kString) {
    return audience->text == expected_audience;
  }
  return audience->type == JsonValue::Type::kArray &&
         audience->array.size() == 1 &&
         audience->array.front().type == JsonValue::Type::kString &&
         audience->array.front().text == expected_audience;
}

bool ConstantTimeEqual(std::string_view left, std::string_view right) {
  size_t difference = left.size() ^ right.size();
  const size_t maximum = left.size() > right.size() ? left.size() : right.size();
  for (size_t index = 0; index < maximum; ++index) {
    const unsigned char a = index < left.size()
                                ? static_cast<unsigned char>(left[index])
                                : 0;
    const unsigned char b = index < right.size()
                                ? static_cast<unsigned char>(right[index])
                                : 0;
    difference |= a ^ b;
  }
  return difference == 0;
}

bool ValidKeyId(const std::string& key_id) {
  if (key_id.empty() || key_id.size() > 64) return false;
  for (const unsigned char character : key_id) {
    if ((character >= 'a' && character <= 'z') ||
        (character >= 'A' && character <= 'Z') ||
        (character >= '0' && character <= '9') || character == '.' ||
        character == '_' || character == '-') {
      continue;
    }
    return false;
  }
  return true;
}

std::optional<std::vector<unsigned char>> PublicKeyDerForKid(
    const std::string& trust_store_base64,
    const std::string& key_id) {
  if (trust_store_base64.empty() ||
      trust_store_base64.size() > kMaximumTrustStoreBytes ||
      !ValidKeyId(key_id)) {
    return std::nullopt;
  }
  const auto decoded = Base64Decode(trust_store_base64);
  if (!decoded || decoded->empty() || decoded->size() > kMaximumTrustStoreBytes) {
    return std::nullopt;
  }
  const std::string json(decoded->begin(), decoded->end());
  JsonValue store;
  if (!JsonParser(json).Parse(&store) ||
      store.type != JsonValue::Type::kObject || store.object.empty()) {
    return std::nullopt;
  }
  for (const auto& entry : store.object) {
    if (!ValidKeyId(entry.first) ||
        entry.second.type != JsonValue::Type::kString) {
      return std::nullopt;
    }
  }
  const std::string* encoded_der = StringField(store, key_id.c_str());
  if (encoded_der == nullptr || encoded_der->size() > 4096) {
    return std::nullopt;
  }
  const auto der = Base64Decode(*encoded_der);
  return der && !der->empty() && der->size() <= 2048
             ? der
             : std::nullopt;
}

bool VerifyEs256(const std::vector<unsigned char>& public_key_der,
                 const std::string& signing_input,
                 const std::vector<unsigned char>& signature) {
  if (signature.size() != 64) return false;
  CERT_PUBLIC_KEY_INFO* public_key_info = nullptr;
  DWORD public_key_info_bytes = 0;
  if (!CryptDecodeObjectEx(X509_ASN_ENCODING, X509_PUBLIC_KEY_INFO,
                           public_key_der.data(),
                           static_cast<DWORD>(public_key_der.size()),
                           CRYPT_DECODE_ALLOC_FLAG, nullptr, &public_key_info,
                           &public_key_info_bytes)) {
    return false;
  }
  BCRYPT_KEY_HANDLE key = nullptr;
  const bool imported =
      CryptImportPublicKeyInfoEx2(X509_ASN_ENCODING, public_key_info, 0,
                                  nullptr, &key) != FALSE;
  LocalFree(public_key_info);
  if (!imported) return false;

  DWORD blob_bytes = 0;
  const bool sized =
      BCryptExportKey(key, nullptr, BCRYPT_ECCPUBLIC_BLOB, nullptr, 0,
                      &blob_bytes, 0) == 0;
  std::vector<unsigned char> blob(sized ? blob_bytes : 0);
  const bool exported =
      sized && blob_bytes >= sizeof(BCRYPT_ECCKEY_BLOB) &&
      BCryptExportKey(key, nullptr, BCRYPT_ECCPUBLIC_BLOB, blob.data(),
                      blob_bytes, &blob_bytes, 0) == 0;
  const auto* header = exported
                           ? reinterpret_cast<const BCRYPT_ECCKEY_BLOB*>(
                                 blob.data())
                           : nullptr;
  const bool p256 = header != nullptr &&
                    header->dwMagic == BCRYPT_ECDSA_PUBLIC_P256_MAGIC &&
                    header->cbKey == 32 &&
                    blob_bytes == sizeof(BCRYPT_ECCKEY_BLOB) + 64;
  const auto digest = Sha256Digest(signing_input);
  const bool verified =
      p256 && digest && digest->size() == 32 &&
      BCryptVerifySignature(key, nullptr, digest->data(),
                            static_cast<ULONG>(digest->size()),
                            const_cast<PUCHAR>(signature.data()),
                            static_cast<ULONG>(signature.size()), 0) == 0;
  BCryptDestroyKey(key);
  return verified;
}

bool ValidLifetime(const std::string& action,
                   std::int64_t issued_at,
                   std::int64_t not_before,
                   std::int64_t expires_at,
                   std::int64_t now) {
  if (issued_at <= 0 || not_before <= 0 || expires_at <= issued_at ||
      not_before > expires_at || issued_at > now + kClockSkewSeconds ||
      not_before > now + kClockSkewSeconds ||
      now >= expires_at ||
      not_before < issued_at - kClockSkewSeconds) {
    return false;
  }
  const std::int64_t lifetime = expires_at - issued_at;
  if (action == "pause_protection") {
    for (const auto allowed : kPauseGrantSeconds) {
      if (lifetime == allowed) return true;
    }
    return false;
  }
  return (action == "uninstall_detected" || action == "emergency_access") &&
         lifetime > 0 && lifetime <= kMaximumSensitiveGrantSeconds;
}

}  // namespace

std::optional<VerifiedGrant> VerifyProtectionGrant(
    const std::string& compact_jws,
    const std::string& trust_store_base64,
    const std::string& expected_device_id,
    const std::string& expected_jwk_thumbprint,
    std::int64_t now_epoch_seconds,
    std::string* error) {
  if (compact_jws.empty() || compact_jws.size() > kMaximumTokenBytes) {
    SetError(error, "token_size_invalid");
    return std::nullopt;
  }
  const size_t first_dot = compact_jws.find('.');
  const size_t second_dot =
      first_dot == std::string::npos ? std::string::npos
                                     : compact_jws.find('.', first_dot + 1);
  if (first_dot == std::string::npos || second_dot == std::string::npos ||
      compact_jws.find('.', second_dot + 1) != std::string::npos ||
      first_dot == 0 || second_dot == first_dot + 1 ||
      second_dot + 1 == compact_jws.size()) {
    SetError(error, "token_format_invalid");
    return std::nullopt;
  }

  const std::string header_segment = compact_jws.substr(0, first_dot);
  const std::string payload_segment =
      compact_jws.substr(first_dot + 1, second_dot - first_dot - 1);
  const std::string signature_segment = compact_jws.substr(second_dot + 1);
  const auto header_bytes = Base64UrlDecode(header_segment);
  const auto payload_bytes = Base64UrlDecode(payload_segment);
  const auto signature = Base64UrlDecode(signature_segment);
  if (!header_bytes || !payload_bytes || !signature ||
      header_bytes->empty() || payload_bytes->empty()) {
    SetError(error, "token_encoding_invalid");
    return std::nullopt;
  }

  JsonValue header;
  JsonValue payload;
  if (!JsonParser(std::string_view(
          reinterpret_cast<const char*>(header_bytes->data()),
          header_bytes->size())).Parse(&header) ||
      !JsonParser(std::string_view(
          reinterpret_cast<const char*>(payload_bytes->data()),
          payload_bytes->size())).Parse(&payload) ||
      header.type != JsonValue::Type::kObject ||
      payload.type != JsonValue::Type::kObject) {
    SetError(error, "token_json_invalid");
    return std::nullopt;
  }

  const std::string* algorithm = StringField(header, "alg");
  const std::string* type = StringField(header, "typ");
  const std::string* key_id = StringField(header, "kid");
  if (header.object.size() != 3 || algorithm == nullptr || *algorithm != "ES256" ||
      type == nullptr || *type != "gamblock-grant+jwt" || key_id == nullptr ||
      !ValidKeyId(*key_id)) {
    SetError(error, "token_header_invalid");
    return std::nullopt;
  }

  const auto public_key_der =
      PublicKeyDerForKid(trust_store_base64, *key_id);
  const std::string signing_input =
      compact_jws.substr(0, second_dot);
  if (!public_key_der ||
      !VerifyEs256(*public_key_der, signing_input, *signature)) {
    SetError(error, "token_signature_invalid");
    return std::nullopt;
  }

  const std::string* issuer = StringField(payload, "iss");
  const std::string* request_id = StringField(payload, "request_id");
  const std::string* token_id = StringField(payload, "jti");
  const std::string* device_id = StringField(payload, "device_id");
  const std::string* action = StringField(payload, "action");
  const auto grant_version = IntegerField(payload, "grant_version");
  const auto issued_at = IntegerField(payload, "iat");
  const auto not_before = IntegerField(payload, "nbf");
  const auto expires_at = IntegerField(payload, "exp");
  const JsonValue* confirmation = Field(payload, "cnf");
  const std::string* thumbprint = confirmation == nullptr
                                      ? nullptr
                                      : StringField(*confirmation, "jkt");
  if (issuer == nullptr || *issuer != "gamblock-ai-backend" ||
      !HasExactAudience(payload, "gamblock-protection-native") ||
      request_id == nullptr || request_id->empty() || request_id->size() > 128 ||
      token_id == nullptr || token_id->empty() || token_id->size() > 128 ||
      device_id == nullptr || device_id->empty() || device_id->size() > 256 ||
      action == nullptr || grant_version != 1 || !issued_at || !not_before ||
      !expires_at || confirmation == nullptr ||
      confirmation->type != JsonValue::Type::kObject || thumbprint == nullptr ||
      thumbprint->empty()) {
    SetError(error, "token_claims_invalid");
    return std::nullopt;
  }
  const auto decoded_thumbprint = Base64UrlDecode(*thumbprint);
  if (!decoded_thumbprint || decoded_thumbprint->size() != 32 ||
      expected_device_id.empty() || expected_jwk_thumbprint.empty() ||
      !ConstantTimeEqual(*device_id, expected_device_id) ||
      !ConstantTimeEqual(*thumbprint, expected_jwk_thumbprint) ||
      !ValidLifetime(*action, *issued_at, *not_before, *expires_at,
                     now_epoch_seconds)) {
    SetError(error, "token_binding_or_lifetime_invalid");
    return std::nullopt;
  }

  return VerifiedGrant{*action, *device_id, *token_id, *issued_at, *not_before,
                       *expires_at};
}

}  // namespace gamblock
