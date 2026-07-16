#include "service_support.h"

#include <bcrypt.h>
#include <shlobj.h>
#include <wincrypt.h>

#include <algorithm>
#include <array>
#include <cstdio>
#include <fstream>
#include <iomanip>
#include <regex>
#include <sstream>

#include "../protection/hybrid_classifier.h"

namespace gamblock {
namespace {

std::optional<std::pair<std::string, std::string>> ManifestEntry(
    const std::string& manifest,
    const std::string& section) {
  const std::regex pattern(
      "\"" + section +
      "\"\\s*:\\s*\\{[^\\}]*\"path\"\\s*:\\s*\"([^\"]+)\""
      "[^\\}]*\"sha256\"\\s*:\\s*\"([a-fA-F0-9]{64})\"");
  std::smatch match;
  if (!std::regex_search(manifest, match, pattern)) return std::nullopt;
  return std::make_pair(match[1].str(), match[2].str());
}

bool ParseUtcExpiry(const std::string& value, FILETIME* output) {
  SYSTEMTIME system_time{};
  int milliseconds = 0;
  const int parsed = sscanf_s(
      value.c_str(), "%hu-%hu-%huT%hu:%hu:%hu.%d", &system_time.wYear,
      &system_time.wMonth, &system_time.wDay, &system_time.wHour,
      &system_time.wMinute, &system_time.wSecond, &milliseconds);
  if (parsed < 6) return false;
  system_time.wMilliseconds = static_cast<WORD>(std::clamp(milliseconds, 0, 999));
  return SystemTimeToFileTime(&system_time, output) != FALSE;
}

}  // namespace

std::filesystem::path ExecutableDirectory() {
  std::array<wchar_t, MAX_PATH> path{};
  GetModuleFileNameW(nullptr, path.data(), static_cast<DWORD>(path.size()));
  return std::filesystem::path(path.data()).parent_path();
}

std::filesystem::path DataDirectory() {
  std::array<wchar_t, MAX_PATH> path{};
  if (SHGetFolderPathW(nullptr, CSIDL_COMMON_APPDATA, nullptr,
                      SHGFP_TYPE_CURRENT, path.data()) != S_OK) {
    return ExecutableDirectory();
  }
  const auto directory = std::filesystem::path(path.data()) / L"GamblockAI";
  std::error_code error;
  std::filesystem::create_directories(directory, error);
  return directory;
}

std::optional<std::string> ReadTextFile(const std::filesystem::path& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) return std::nullopt;
  return std::string(std::istreambuf_iterator<char>(input),
                     std::istreambuf_iterator<char>());
}

std::string Hex(const std::vector<unsigned char>& bytes) {
  std::ostringstream output;
  output << std::hex << std::setfill('0');
  for (const auto byte : bytes) output << std::setw(2) << static_cast<int>(byte);
  return output.str();
}

std::string Sha256File(const std::filesystem::path& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) return {};
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
    if (algorithm) BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  std::vector<unsigned char> object(object_bytes);
  std::vector<unsigned char> digest(digest_bytes);
  if (BCryptCreateHash(algorithm, &hash, object.data(), object_bytes, nullptr,
                       0, 0) != 0) {
    BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  std::array<unsigned char, 8192> buffer{};
  while (input) {
    input.read(reinterpret_cast<char*>(buffer.data()),
               static_cast<std::streamsize>(buffer.size()));
    const auto count = input.gcount();
    if (count > 0 && BCryptHashData(hash, buffer.data(),
                                    static_cast<ULONG>(count), 0) != 0) {
      BCryptDestroyHash(hash);
      BCryptCloseAlgorithmProvider(algorithm, 0);
      return {};
    }
  }
  if (BCryptFinishHash(hash, digest.data(), digest_bytes, 0) != 0) {
    BCryptDestroyHash(hash);
    BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  BCryptDestroyHash(hash);
  BCryptCloseAlgorithmProvider(algorithm, 0);
  return Hex(digest);
}

std::string Sha256Bytes(const std::vector<unsigned char>& bytes) {
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
    if (algorithm) BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  std::vector<unsigned char> object(object_bytes);
  std::vector<unsigned char> digest(digest_bytes);
  if (BCryptCreateHash(algorithm, &hash, object.data(), object_bytes, nullptr,
                       0, 0) != 0 ||
      BCryptHashData(hash, const_cast<PUCHAR>(bytes.data()),
                     static_cast<ULONG>(bytes.size()), 0) != 0 ||
      BCryptFinishHash(hash, digest.data(), digest_bytes, 0) != 0) {
    if (hash) BCryptDestroyHash(hash);
    BCryptCloseAlgorithmProvider(algorithm, 0);
    return {};
  }
  BCryptDestroyHash(hash);
  BCryptCloseAlgorithmProvider(algorithm, 0);
  return Hex(digest);
}

std::string Narrow(const std::wstring& value) {
  if (value.empty()) return {};
  const int size = WideCharToMultiByte(CP_UTF8, 0, value.c_str(),
                                       static_cast<int>(value.size()), nullptr,
                                       0, nullptr, nullptr);
  std::string output(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()),
                      output.data(), size, nullptr, nullptr);
  return output;
}

std::wstring Widen(const std::string& value) {
  if (value.empty()) return {};
  const int size = MultiByteToWideChar(CP_UTF8, 0, value.c_str(),
                                       static_cast<int>(value.size()), nullptr,
                                       0);
  std::wstring output(size, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()),
                      output.data(), size);
  return output;
}

std::optional<std::pair<std::filesystem::path, std::filesystem::path>>
VerifiedArtifactPair(const std::filesystem::path& directory) {
  const auto manifest = ReadTextFile(directory / L"manifest.json");
  if (!manifest ||
      JsonString(*manifest, "contract_version").value_or("") !=
          HybridClassifier::kContractVersion) return std::nullopt;
  const auto model = ManifestEntry(*manifest, "model");
  const auto rules = ManifestEntry(*manifest, "ruleset");
  const auto fixtures = ManifestEntry(*manifest, "fixtures");
  if (!model || !rules || !fixtures) return std::nullopt;
  const auto safePath = [&directory](const std::string& relative)
      -> std::optional<std::filesystem::path> {
    const std::filesystem::path value = Widen(relative);
    if (value.is_absolute() || value.filename() != value) return std::nullopt;
    return directory / value;
  };
  const auto model_path = safePath(model->first);
  const auto rules_path = safePath(rules->first);
  const auto fixtures_path = safePath(fixtures->first);
  if (!model_path || !rules_path || !fixtures_path ||
      Sha256File(*model_path) != model->second ||
      Sha256File(*rules_path) != rules->second ||
      Sha256File(*fixtures_path) != fixtures->second) return std::nullopt;
  return std::make_pair(*model_path, *rules_path);
}

std::vector<unsigned char> RandomBytes(size_t count) {
  std::vector<unsigned char> bytes(count);
  if (BCryptGenRandom(nullptr, bytes.data(), static_cast<ULONG>(bytes.size()),
                      BCRYPT_USE_SYSTEM_PREFERRED_RNG) != 0) return {};
  return bytes;
}

bool WriteProtected(const std::filesystem::path& path,
                    const std::string& cleartext) {
  DATA_BLOB input{static_cast<DWORD>(cleartext.size()),
                  reinterpret_cast<BYTE*>(const_cast<char*>(cleartext.data()))};
  DATA_BLOB output{};
  if (!CryptProtectData(&input, L"Gamblock local protection state", nullptr,
                        nullptr, nullptr, CRYPTPROTECT_LOCAL_MACHINE, &output)) {
    return false;
  }
  std::ofstream file(path, std::ios::binary | std::ios::trunc);
  file.write(reinterpret_cast<const char*>(output.pbData), output.cbData);
  LocalFree(output.pbData);
  return file.good();
}

std::optional<std::string> ReadProtected(const std::filesystem::path& path) {
  std::ifstream file(path, std::ios::binary);
  if (!file) return std::nullopt;
  std::vector<BYTE> bytes(std::istreambuf_iterator<char>(file),
                          std::istreambuf_iterator<char>());
  DATA_BLOB input{static_cast<DWORD>(bytes.size()), bytes.data()};
  DATA_BLOB output{};
  if (!CryptUnprotectData(&input, nullptr, nullptr, nullptr, nullptr,
                          CRYPTPROTECT_LOCAL_MACHINE, &output)) return std::nullopt;
  std::string cleartext(reinterpret_cast<char*>(output.pbData), output.cbData);
  LocalFree(output.pbData);
  return cleartext;
}

bool IsFuture(const std::string& expiry) {
  FILETIME parsed{};
  FILETIME now{};
  GetSystemTimeAsFileTime(&now);
  return ParseUtcExpiry(expiry, &parsed) && CompareFileTime(&parsed, &now) > 0;
}

}  // namespace gamblock
