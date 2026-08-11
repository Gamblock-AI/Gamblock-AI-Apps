#ifndef GAMBLOCK_SERVICE_DEVICE_KEY_H_
#define GAMBLOCK_SERVICE_DEVICE_KEY_H_

#include <optional>
#include <string>

namespace gamblock {

struct GrantKeyEnrollment {
  std::string public_jwk;
  std::string jwk_thumbprint;
  std::string proof;
};

std::optional<GrantKeyEnrollment> CreateGrantKeyEnrollment(
    const std::string& device_id,
    const std::string& challenge_token,
    std::string* error = nullptr);
std::optional<std::string> ExistingGrantKeyThumbprint(
    std::string* error = nullptr);

}  // namespace gamblock

#endif  // GAMBLOCK_SERVICE_DEVICE_KEY_H_
