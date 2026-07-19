#include "protection_service.h"

#include <filesystem>
#include <fstream>

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

bool ProtectionService::UpdateArtifacts(const std::string& base_url) {
  if (base_url.empty()) return LoadArtifacts();
  const auto model_release = HttpGet(base_url, "/v1/releases/model/latest");
  const auto rules_release = HttpGet(base_url, "/v1/releases/ruleset/latest");
  if (!model_release || !rules_release) return true;

  const std::string model_metadata(model_release->begin(), model_release->end());
  const std::string rules_metadata(rules_release->begin(), rules_release->end());
  const std::string model_contract =
      JsonString(model_metadata, "contract_version").value_or("");
  const std::string rules_contract =
      JsonString(rules_metadata, "contract_version").value_or("");
  const std::string platform = JsonString(model_metadata, "platform").value_or("");
  if (model_contract != HybridClassifier::kContractVersion ||
      rules_contract != HybridClassifier::kContractVersion ||
      (platform != "windows" && platform != "all")) return false;

  const std::string model_url =
      JsonString(model_metadata, "download_url").value_or("");
  const std::string rules_url =
      JsonString(rules_metadata, "download_url").value_or("");
  if (model_url.empty() || rules_url.empty()) return false;
  const auto model = HttpGet(base_url, model_url);
  const auto rules = HttpGet(base_url, rules_url);
  const std::string model_sha = JsonString(model_metadata, "sha256").value_or("");
  const std::string rules_sha = JsonString(rules_metadata, "sha256").value_or("");
  if (!model || !rules || Sha256Bytes(*model) != model_sha ||
      Sha256Bytes(*rules) != rules_sha ||
      JsonString(std::string(model->begin(), model->end()), "contract_version")
              .value_or("") != HybridClassifier::kContractVersion ||
      JsonString(std::string(rules->begin(), rules->end()), "contract_version")
              .value_or("") != HybridClassifier::kContractVersion) return false;

  const auto bundled = ExecutableDirectory() / L"data" / L"flutter_assets" /
                       L"assets" / L"protection";
  const auto fixture = bundled / L"hybrid-v2-fixtures.json";
  const std::string fixture_sha = Sha256File(fixture);
  if (fixture_sha.empty()) return false;

  const auto root = DataDirectory();
  const auto stage = root / L"protection.next";
  const auto active = root / L"protection";
  const auto previous = root / L"protection.previous";
  std::error_code error;
  std::filesystem::remove_all(stage, error);
  std::filesystem::create_directories(stage, error);
  if (error) return false;
  {
    std::ofstream output(stage / L"model.json", std::ios::binary | std::ios::trunc);
    output.write(reinterpret_cast<const char*>(model->data()),
                 static_cast<std::streamsize>(model->size()));
  }
  {
    std::ofstream output(stage / L"rules.json", std::ios::binary | std::ios::trunc);
    output.write(reinterpret_cast<const char*>(rules->data()),
                 static_cast<std::streamsize>(rules->size()));
  }
  std::filesystem::copy_file(fixture, stage / L"hybrid-v2-fixtures.json",
                             std::filesystem::copy_options::overwrite_existing,
                             error);
  if (error) return false;

  const std::string model_version =
      JsonString(model_metadata, "version").value_or("unknown");
  const std::string rules_version =
      JsonString(rules_metadata, "version").value_or("unknown");
  std::ofstream manifest(stage / L"manifest.json", std::ios::trunc);
  manifest << "{\n"
           << "  \"contract_version\": \"hybrid-v2\",\n"
           << "  \"model\": {\"version\": \"" << EscapeJson(model_version)
           << "\", \"path\": \"model.json\", \"sha256\": \"" << model_sha
           << "\"},\n"
           << "  \"ruleset\": {\"version\": \"" << EscapeJson(rules_version)
           << "\", \"path\": \"rules.json\", \"sha256\": \"" << rules_sha
           << "\"},\n"
           << "  \"fixtures\": {\"path\": \"hybrid-v2-fixtures.json\", "
              "\"sha256\": \"" << fixture_sha << "\"}\n"
           << "}\n";
  manifest.close();

  const auto verified = VerifiedArtifactPair(stage);
  HybridClassifier candidate;
  std::string candidate_error;
  if (!verified ||
      !candidate.Load(Narrow(verified->first.wstring()),
                      Narrow(verified->second.wstring()), &candidate_error) ||
      !candidate.Classify({"https://contoh-judi.invalid/slot-gacor", "", {}, {}})
           .block ||
      candidate.Classify({"https://kampus.ac.id/penelitian",
                          "Portal penelitian universitas",
                          {"Pendidikan dan beasiswa"}, {"Jurnal research"}})
          .block) {
    std::filesystem::remove_all(stage, error);
    return false;
  }
  std::filesystem::remove_all(previous, error);
  error.clear();
  if (std::filesystem::exists(active)) {
    std::filesystem::rename(active, previous, error);
    if (error) return false;
  }
  std::filesystem::rename(stage, active, error);
  if (error) {
    if (std::filesystem::exists(previous)) {
      std::error_code restore_error;
      std::filesystem::rename(previous, active, restore_error);
    }
    return false;
  }
  if (!LoadArtifacts()) {
    std::filesystem::remove_all(active, error);
    if (std::filesystem::exists(previous)) std::filesystem::rename(previous, active, error);
    LoadArtifacts();
    return false;
  }
  std::filesystem::remove_all(previous, error);
  IncrementAggregate("model_updated");
  IncrementAggregate("ruleset_updated");
  return true;
}

}  // namespace gamblock
