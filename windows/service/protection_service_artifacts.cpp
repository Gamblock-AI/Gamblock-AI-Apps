#include "protection_service.h"

#include <filesystem>

#include "service_support.h"

namespace gamblock {

bool ProtectionService::LoadArtifacts() {
  const auto installed = DataDirectory() / L"protection";
  const auto bundled = ExecutableDirectory() / L"data" / L"flutter_assets" /
                       L"assets" / L"protection";
  std::lock_guard lock(state_mutex_);
  const auto load_verified = [this](const std::filesystem::path& directory) {
    const auto artifacts = VerifiedArtifactPair(directory);
    if (!artifacts ||
        !classifier_.Load(Narrow(artifacts->first.wstring()),
                          Narrow(artifacts->second.wstring()),
                          &artifact_error_)) return false;
    const auto positive = classifier_.Classify({
        "https://contoh-judi.invalid/slot-gacor", "", {}, {}});
    const auto negative = classifier_.Classify({
        "https://kampus.ac.id/penelitian", "Portal penelitian universitas",
        {"Pendidikan dan beasiswa"}, {"Jurnal research"},
    });
    return positive.block && !negative.block;
  };
  return load_verified(installed) || load_verified(bundled);
}

}  // namespace gamblock
