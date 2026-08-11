#ifndef GAMBLOCK_SERVICE_GRANT_VERIFIER_H_
#define GAMBLOCK_SERVICE_GRANT_VERIFIER_H_

#include <cstdint>
#include <optional>
#include <string>

namespace gamblock {

struct VerifiedGrant {
  std::string action;
  std::string device_id;
  std::string token_id;
  std::int64_t issued_at = 0;
  std::int64_t not_before = 0;
  std::int64_t expires_at = 0;
};

// The trust store is base64(JSON), where the JSON is a map from a key id to a
// base64 DER SubjectPublicKeyInfo containing an EC P-256 public key.
std::optional<VerifiedGrant> VerifyProtectionGrant(
    const std::string& compact_jws,
    const std::string& trust_store_base64,
    const std::string& expected_device_id,
    const std::string& expected_jwk_thumbprint,
    std::int64_t now_epoch_seconds,
    std::string* error = nullptr);

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_GRANT_VERIFIER_H_
