#include "grant_verifier.h"

#include <windows.h>
#include <bcrypt.h>

#include <cstdint>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "crypto_support.h"

namespace {

class AlgorithmHandle {
 public:
  ~AlgorithmHandle() {
    if (value_ != nullptr) BCryptCloseAlgorithmProvider(value_, 0);
  }
  BCRYPT_ALG_HANDLE* address() { return &value_; }

 private:
  BCRYPT_ALG_HANDLE value_ = nullptr;
};

class KeyHandle {
 public:
  ~KeyHandle() {
    if (value_ != nullptr) BCryptDestroyKey(value_);
  }
  BCRYPT_KEY_HANDLE* address() { return &value_; }
  BCRYPT_KEY_HANDLE get() const { return value_; }

 private:
  BCRYPT_KEY_HANDLE value_ = nullptr;
};

std::vector<unsigned char> Bytes(const std::string& value) {
  return std::vector<unsigned char>(value.begin(), value.end());
}

bool CreateTestKey(AlgorithmHandle* algorithm,
                   KeyHandle* key,
                   std::string* trust_store) {
  if (BCryptOpenAlgorithmProvider(algorithm->address(),
                                  BCRYPT_ECDSA_P256_ALGORITHM, nullptr, 0) !=
          0 ||
      BCryptGenerateKeyPair(*algorithm->address(), key->address(), 256, 0) !=
          0 ||
      BCryptFinalizeKeyPair(key->get(), 0) != 0) {
    return false;
  }
  DWORD blob_bytes = 0;
  if (BCryptExportKey(key->get(), nullptr, BCRYPT_ECCPUBLIC_BLOB, nullptr, 0,
                      &blob_bytes, 0) != 0) {
    return false;
  }
  std::vector<unsigned char> blob(blob_bytes);
  if (BCryptExportKey(key->get(), nullptr, BCRYPT_ECCPUBLIC_BLOB, blob.data(),
                      blob_bytes, &blob_bytes, 0) != 0 ||
      blob_bytes != sizeof(BCRYPT_ECCKEY_BLOB) + 64) {
    return false;
  }
  const auto* header =
      reinterpret_cast<const BCRYPT_ECCKEY_BLOB*>(blob.data());
  if (header->dwMagic != BCRYPT_ECDSA_PUBLIC_P256_MAGIC ||
      header->cbKey != 32) {
    return false;
  }

  // DER SubjectPublicKeyInfo for id-ecPublicKey + prime256v1 followed by the
  // uncompressed EC point from the exported CNG public blob.
  std::vector<unsigned char> der = {
      0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48,
      0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48,
      0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00, 0x04,
  };
  der.insert(der.end(), blob.begin() + sizeof(BCRYPT_ECCKEY_BLOB), blob.end());
  const std::string json =
      "{\"test-current\":\"" + gamblock::Base64Encode(der) + "\"}";
  *trust_store = gamblock::Base64Encode(Bytes(json));
  return true;
}

std::string SignToken(BCRYPT_KEY_HANDLE key,
                      const std::string& header,
                      const std::string& payload) {
  const std::string signing_input =
      gamblock::Base64UrlEncode(Bytes(header)) + "." +
      gamblock::Base64UrlEncode(Bytes(payload));
  const auto digest = gamblock::Sha256Digest(signing_input);
  if (!digest) return {};
  DWORD signature_bytes = 0;
  if (BCryptSignHash(key, nullptr, digest->data(),
                     static_cast<ULONG>(digest->size()), nullptr, 0,
                     &signature_bytes, 0) != 0 ||
      signature_bytes != 64) {
    return {};
  }
  std::vector<unsigned char> signature(signature_bytes);
  if (BCryptSignHash(key, nullptr, digest->data(),
                     static_cast<ULONG>(digest->size()), signature.data(),
                     signature_bytes, &signature_bytes, 0) != 0) {
    return {};
  }
  return signing_input + "." + gamblock::Base64UrlEncode(signature);
}

std::string Payload(const std::string& action,
                    std::int64_t now,
                    std::int64_t lifetime,
                    const std::string& thumbprint,
                    const std::string& device_id = "device-1",
                    bool audience_as_array = true) {
  std::ostringstream json;
  json << "{\"iss\":\"gamblock-ai-backend\","
       << "\"aud\":"
       << (audience_as_array
               ? "[\"gamblock-protection-native\"]"
               : "\"gamblock-protection-native\"")
       << ','
       << "\"request_id\":\"grant-request-1\","
       << "\"jti\":\"grant-1\","
       << "\"device_id\":\"" << device_id << "\","
       << "\"action\":\"" << action << "\","
       << "\"grant_version\":1,"
       << "\"iat\":" << now << ",\"nbf\":" << now
       << ",\"exp\":" << now + lifetime << ','
       << "\"cnf\":{\"jkt\":\"" << thumbprint << "\"}}";
  return json.str();
}

bool Expect(bool condition, const char* name) {
  if (condition) return true;
  std::cerr << "FAILED: " << name << '\n';
  return false;
}

}  // namespace

int main() {
  AlgorithmHandle algorithm;
  KeyHandle key;
  std::string trust_store;
  if (!CreateTestKey(&algorithm, &key, &trust_store)) return 2;

  constexpr std::int64_t now = 2000000000;
  const auto thumbprint_digest = gamblock::Sha256Digest("device-test-key");
  if (!thumbprint_digest) return 3;
  const std::string thumbprint =
      gamblock::Base64UrlEncode(*thumbprint_digest);
  const std::string header =
      "{\"alg\":\"ES256\",\"typ\":\"gamblock-grant+jwt\","
      "\"kid\":\"test-current\"}";

  int failures = 0;
  const std::string valid_pause =
      SignToken(key.get(), header,
                Payload("pause_protection", now, 15 * 60, thumbprint));
  failures += !Expect(
      gamblock::VerifyProtectionGrant(valid_pause, trust_store, "device-1",
                                      thumbprint, now)
          .has_value(),
      "valid 15-minute pause grant");

  const std::string valid_string_audience =
      SignToken(key.get(), header,
                Payload("pause_protection", now, 15 * 60, thumbprint,
                        "device-1", false));
  failures += !Expect(
      gamblock::VerifyProtectionGrant(valid_string_audience, trust_store,
                                      "device-1", thumbprint, now)
          .has_value(),
      "valid scalar audience grant");

  std::string extra_audience_payload =
      Payload("pause_protection", now, 15 * 60, thumbprint);
  const std::string exact_audience =
      "[\"gamblock-protection-native\"]";
  extra_audience_payload.replace(
      extra_audience_payload.find(exact_audience), exact_audience.size(),
      "[\"gamblock-protection-native\",\"unexpected\"]");
  const std::string extra_audience =
      SignToken(key.get(), header, extra_audience_payload);
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(extra_audience, trust_store,
                                       "device-1", thumbprint, now),
      "additional audience rejected");

  std::string tampered = valid_pause;
  const size_t first_dot = tampered.find('.');
  if (first_dot != std::string::npos && first_dot + 2 < tampered.size()) {
    tampered[first_dot + 1] = tampered[first_dot + 1] == 'A' ? 'B' : 'A';
  }
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(tampered, trust_store, "device-1",
                                       thumbprint, now),
      "tampered payload");
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(valid_pause, trust_store, "device-2",
                                       thumbprint, now),
      "wrong device binding");

  const std::string invalid_pause =
      SignToken(key.get(), header,
                Payload("pause_protection", now, 16 * 60, thumbprint));
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(invalid_pause, trust_store, "device-1",
                                       thumbprint, now),
      "unsupported pause duration");

  const std::string disabled =
      SignToken(key.get(), header,
                Payload("disable_protection", now, 10 * 60, thumbprint));
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(disabled, trust_store, "device-1",
                                       thumbprint, now),
      "removed disable action");

  const std::string emergency =
      SignToken(key.get(), header,
                Payload("emergency_access", now, 10 * 60, thumbprint));
  failures += !Expect(
      gamblock::VerifyProtectionGrant(emergency, trust_store, "device-1",
                                      thumbprint, now)
          .has_value(),
      "valid ten-minute emergency grant");
  const std::string excessive_emergency =
      SignToken(key.get(), header,
                Payload("emergency_access", now, 10 * 60 + 1, thumbprint));
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(excessive_emergency, trust_store,
                                       "device-1", thumbprint, now),
      "excessive emergency duration");

  const std::string wrong_type_header =
      "{\"alg\":\"ES256\",\"typ\":\"JWT\","
      "\"kid\":\"test-current\"}";
  const std::string wrong_type =
      SignToken(key.get(), wrong_type_header,
                Payload("pause_protection", now, 15 * 60, thumbprint));
  failures += !Expect(
      !gamblock::VerifyProtectionGrant(wrong_type, trust_store, "device-1",
                                       thumbprint, now),
      "wrong protected header type");

  failures += !Expect(
      !gamblock::VerifyProtectionGrant(valid_pause, "", "device-1",
                                       thumbprint, now),
      "empty trust store fails closed");
  return failures == 0 ? 0 : 1;
}
