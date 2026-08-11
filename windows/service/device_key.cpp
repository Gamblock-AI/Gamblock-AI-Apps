#include "device_key.h"

#include <windows.h>
#include <bcrypt.h>
#include <ncrypt.h>

#include <cstring>
#include <vector>

#include "crypto_support.h"

namespace gamblock {
namespace {

constexpr wchar_t kGrantKeyName[] = L"GamblockAIProtectionDeviceKeyV1";
constexpr size_t kMaximumDeviceIdBytes = 256;
constexpr size_t kMaximumChallengeBytes = 4096;

void SetError(std::string* error, const char* value) {
  if (error != nullptr) *error = value;
}

class ProviderHandle {
 public:
  ~ProviderHandle() {
    if (value_ != 0) NCryptFreeObject(value_);
  }
  NCRYPT_PROV_HANDLE* address() { return &value_; }
  NCRYPT_PROV_HANDLE get() const { return value_; }

 private:
  NCRYPT_PROV_HANDLE value_ = 0;
};

class KeyHandle {
 public:
  ~KeyHandle() {
    if (value_ != 0) NCryptFreeObject(value_);
  }
  NCRYPT_KEY_HANDLE* address() { return &value_; }
  NCRYPT_KEY_HANDLE get() const { return value_; }

 private:
  NCRYPT_KEY_HANDLE value_ = 0;
};

bool OpenProvider(ProviderHandle* provider) {
  return NCryptOpenStorageProvider(provider->address(),
                                   MS_KEY_STORAGE_PROVIDER, 0) == ERROR_SUCCESS;
}

bool ValidateNonExportableKey(NCRYPT_KEY_HANDLE key) {
  DWORD export_policy = 0;
  DWORD bytes = 0;
  return NCryptGetProperty(key, NCRYPT_EXPORT_POLICY_PROPERTY,
                           reinterpret_cast<PBYTE>(&export_policy),
                           sizeof(export_policy), &bytes,
                           NCRYPT_SILENT_FLAG) == ERROR_SUCCESS &&
         bytes == sizeof(export_policy) && export_policy == 0;
}

bool OpenExistingKey(ProviderHandle* provider, KeyHandle* key) {
  return OpenProvider(provider) &&
         NCryptOpenKey(provider->get(), key->address(), kGrantKeyName, 0,
                       NCRYPT_MACHINE_KEY_FLAG | NCRYPT_SILENT_FLAG) ==
             ERROR_SUCCESS &&
         ValidateNonExportableKey(key->get());
}

bool OpenOrCreateKey(ProviderHandle* provider, KeyHandle* key) {
  if (!OpenProvider(provider)) return false;
  SECURITY_STATUS status = NCryptOpenKey(
      provider->get(), key->address(), kGrantKeyName, 0,
      NCRYPT_MACHINE_KEY_FLAG | NCRYPT_SILENT_FLAG);
  if (status == ERROR_SUCCESS) return ValidateNonExportableKey(key->get());
  if (status != NTE_BAD_KEYSET) return false;

  status = NCryptCreatePersistedKey(
      provider->get(), key->address(), NCRYPT_ECDSA_P256_ALGORITHM,
      kGrantKeyName, 0, NCRYPT_MACHINE_KEY_FLAG | NCRYPT_SILENT_FLAG);
  if (status != ERROR_SUCCESS) return false;
  DWORD export_policy = 0;
  if (NCryptSetProperty(key->get(), NCRYPT_EXPORT_POLICY_PROPERTY,
                        reinterpret_cast<PBYTE>(&export_policy),
                        sizeof(export_policy), NCRYPT_PERSIST_FLAG) !=
          ERROR_SUCCESS ||
      NCryptFinalizeKey(key->get(), NCRYPT_SILENT_FLAG) != ERROR_SUCCESS) {
    return false;
  }
  return ValidateNonExportableKey(key->get());
}

struct PublicKeyMaterial {
  std::string public_jwk;
  std::string thumbprint;
};

std::optional<PublicKeyMaterial> PublicMaterial(NCRYPT_KEY_HANDLE key) {
  DWORD blob_bytes = 0;
  if (NCryptExportKey(key, 0, BCRYPT_ECCPUBLIC_BLOB, nullptr, nullptr, 0,
                     &blob_bytes, NCRYPT_SILENT_FLAG) != ERROR_SUCCESS ||
      blob_bytes != sizeof(BCRYPT_ECCKEY_BLOB) + 64) {
    return std::nullopt;
  }
  std::vector<unsigned char> blob(blob_bytes);
  if (NCryptExportKey(key, 0, BCRYPT_ECCPUBLIC_BLOB, nullptr, blob.data(),
                     blob_bytes, &blob_bytes, NCRYPT_SILENT_FLAG) !=
      ERROR_SUCCESS) {
    return std::nullopt;
  }
  const auto* header =
      reinterpret_cast<const BCRYPT_ECCKEY_BLOB*>(blob.data());
  if (header->dwMagic != BCRYPT_ECDSA_PUBLIC_P256_MAGIC ||
      header->cbKey != 32) {
    return std::nullopt;
  }
  const auto coordinate_start = blob.begin() + sizeof(BCRYPT_ECCKEY_BLOB);
  const std::vector<unsigned char> x(coordinate_start,
                                     coordinate_start + 32);
  const std::vector<unsigned char> y(coordinate_start + 32,
                                     coordinate_start + 64);
  const std::string jwk =
      "{\"crv\":\"P-256\",\"kty\":\"EC\",\"x\":\"" +
      Base64UrlEncode(x) + "\",\"y\":\"" + Base64UrlEncode(y) + "\"}";
  const auto digest = Sha256Digest(jwk);
  if (!digest || digest->size() != 32) return std::nullopt;
  return PublicKeyMaterial{jwk, Base64UrlEncode(*digest)};
}

std::optional<std::vector<unsigned char>> SignHash(NCRYPT_KEY_HANDLE key,
                                                   const std::string& value) {
  const auto digest = Sha256Digest(value);
  if (!digest || digest->size() != 32) return std::nullopt;
  DWORD signature_bytes = 0;
  if (NCryptSignHash(key, nullptr, digest->data(),
                     static_cast<DWORD>(digest->size()), nullptr, 0,
                     &signature_bytes, NCRYPT_SILENT_FLAG) != ERROR_SUCCESS ||
      signature_bytes != 64) {
    return std::nullopt;
  }
  std::vector<unsigned char> signature(signature_bytes);
  if (NCryptSignHash(key, nullptr, digest->data(),
                     static_cast<DWORD>(digest->size()), signature.data(),
                     signature_bytes, &signature_bytes,
                     NCRYPT_SILENT_FLAG) != ERROR_SUCCESS ||
      signature_bytes != static_cast<DWORD>(signature.size())) {
    return std::nullopt;
  }
  return signature;
}

}  // namespace

std::optional<GrantKeyEnrollment> CreateGrantKeyEnrollment(
    const std::string& device_id,
    const std::string& challenge_token,
    std::string* error) {
  if (device_id.empty() || device_id.size() > kMaximumDeviceIdBytes ||
      challenge_token.empty() ||
      challenge_token.size() > kMaximumChallengeBytes) {
    SetError(error, "enrollment_input_invalid");
    return std::nullopt;
  }
  ProviderHandle provider;
  KeyHandle key;
  if (!OpenOrCreateKey(&provider, &key)) {
    SetError(error, "device_key_unavailable");
    return std::nullopt;
  }
  const auto public_material = PublicMaterial(key.get());
  const std::string proof_input =
      "gamblock-device-key-v1\n" + device_id + "\n" + challenge_token;
  const auto signature = SignHash(key.get(), proof_input);
  if (!public_material || !signature) {
    SetError(error, "device_key_proof_failed");
    return std::nullopt;
  }
  return GrantKeyEnrollment{public_material->public_jwk,
                            public_material->thumbprint,
                            Base64UrlEncode(*signature)};
}

std::optional<std::string> ExistingGrantKeyThumbprint(std::string* error) {
  ProviderHandle provider;
  KeyHandle key;
  if (!OpenExistingKey(&provider, &key)) {
    SetError(error, "device_key_unavailable");
    return std::nullopt;
  }
  const auto public_material = PublicMaterial(key.get());
  if (!public_material) {
    SetError(error, "device_key_public_material_invalid");
    return std::nullopt;
  }
  return public_material->thumbprint;
}

}  // namespace gamblock
