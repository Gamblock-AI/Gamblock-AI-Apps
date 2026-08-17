#include "native_protection_codec.h"

#include <windows.h>

#include <array>
#include <cstdint>
#include <regex>
#include <sstream>
#include <variant>

namespace gamblock::native_bridge {
namespace {

std::string SerializeValue(const flutter::EncodableValue& value) {
  if (std::holds_alternative<std::monostate>(value)) return "null";
  if (const auto* boolean = std::get_if<bool>(&value)) return *boolean ? "true" : "false";
  if (const auto* number = std::get_if<int32_t>(&value)) return std::to_string(*number);
  if (const auto* number = std::get_if<int64_t>(&value)) return std::to_string(*number);
  if (const auto* number = std::get_if<double>(&value)) return std::to_string(*number);
  if (const auto* string = std::get_if<std::string>(&value)) {
    return "\"" + EscapeJson(*string) + "\"";
  }
  if (const auto* list = std::get_if<flutter::EncodableList>(&value)) {
    return SerializeList(*list);
  }
  if (const auto* map = std::get_if<flutter::EncodableMap>(&value)) {
    return SerializeMap(*map);
  }
  return "null";
}

}  // namespace

std::wstring ExecutableDirectory() {
  std::array<wchar_t, MAX_PATH> path{};
  GetModuleFileNameW(nullptr, path.data(), static_cast<DWORD>(path.size()));
  std::wstring value(path.data());
  const auto separator = value.find_last_of(L"\\/");
  return separator == std::wstring::npos ? L"." : value.substr(0, separator);
}

std::string EscapeJson(const std::string& value) {
  std::ostringstream output;
  for (const char character : value) {
    if (character == '\\' || character == '"') output << '\\';
    output << character;
  }
  return output.str();
}

std::string JsonString(const std::string& json,
                       const std::string& key,
                       const std::string& fallback) {
  const std::regex pattern("\"" + key +
                           "\"\\s*:\\s*\"((?:\\\\.|[^\"])*)\"");
  std::smatch match;
  if (!std::regex_search(json, match, pattern)) return fallback;
  std::string decoded;
  decoded.reserve(match[1].length());
  bool escaped = false;
  for (const char character : match[1].str()) {
    if (escaped) {
      switch (character) {
        case 'n': decoded.push_back('\n'); break;
        case 'r': decoded.push_back('\r'); break;
        case 't': decoded.push_back('\t'); break;
        default: decoded.push_back(character); break;
      }
      escaped = false;
    } else if (character == '\\') {
      escaped = true;
    } else {
      decoded.push_back(character);
    }
  }
  return escaped ? fallback : decoded;
}

bool JsonBool(const std::string& json, const std::string& key, bool fallback) {
  const std::regex pattern("\"" + key + "\"\\s*:\\s*(true|false)");
  std::smatch match;
  return std::regex_search(json, match, pattern) ? match[1].str() == "true" : fallback;
}

int JsonInt(const std::string& json, const std::string& key, int fallback) {
  const std::regex pattern("\"" + key + "\"\\s*:\\s*([0-9]+)");
  std::smatch match;
  return std::regex_search(json, match, pattern) ? std::stoi(match[1].str()) : fallback;
}

flutter::EncodableMap SnapshotMap(const std::string& json) {
  flutter::EncodableMap snapshot{
      {flutter::EncodableValue("platform"),
       flutter::EncodableValue(JsonString(json, "platform", "windows"))},
      {flutter::EncodableValue("status"),
       flutter::EncodableValue(JsonString(json, "status", "degraded"))},
      {flutter::EncodableValue("service_running"),
       flutter::EncodableValue(JsonBool(json, "service_running"))},
      {flutter::EncodableValue("sensor_status"),
       flutter::EncodableValue(JsonString(json, "sensor_status", "disconnected"))},
      {flutter::EncodableValue("permission_status"),
       flutter::EncodableValue(JsonString(json, "permission_status", "unknown"))},
      {flutter::EncodableValue("supports_controlled_removal"),
       flutter::EncodableValue(
           JsonBool(json, "supports_controlled_removal", false))},
      {flutter::EncodableValue("model_version"),
       flutter::EncodableValue(JsonString(
           json, "model_version", "gamblock-lr-bfafb725511a"))},
      {flutter::EncodableValue("ruleset_version"),
       flutter::EncodableValue(JsonString(
           json, "ruleset_version", "gambling-keywords-b4f2932a7647"))},
  };
  const std::string degraded_reason = JsonString(json, "degraded_reason_code");
  if (!degraded_reason.empty()) {
    snapshot[flutter::EncodableValue("degraded_reason_code")] =
        flutter::EncodableValue(degraded_reason);
  }
  return snapshot;
}

flutter::EncodableMap SelfTestMap(const std::string& json) {
  return {
      {flutter::EncodableValue("passed"), flutter::EncodableValue(JsonBool(json, "passed"))},
      {flutter::EncodableValue("reason_code"), flutter::EncodableValue(JsonString(json, "reason_code"))},
      {flutter::EncodableValue("model_version"), flutter::EncodableValue(JsonString(json, "model_version"))},
      {flutter::EncodableValue("ruleset_version"), flutter::EncodableValue(JsonString(json, "ruleset_version"))},
  };
}

flutter::EncodableList AggregateItems(const std::string& json) {
  flutter::EncodableList items;
  const auto items_position = json.find("\"items\"");
  const auto opening = json.find('[', items_position);
  const auto closing = json.rfind(']');
  if (opening == std::string::npos || closing == std::string::npos) return items;
  const std::string body = json.substr(opening + 1, closing - opening - 1);
  const std::regex object("\\{[^\\}]*\\}");
  for (std::sregex_iterator it(body.begin(), body.end(), object), end;
       it != end; ++it) {
    const std::string value = it->str();
    items.emplace_back(flutter::EncodableMap{
        {flutter::EncodableValue("key"), flutter::EncodableValue(JsonString(value, "key"))},
        {flutter::EncodableValue("date"), flutter::EncodableValue(JsonString(value, "date"))},
        {flutter::EncodableValue("event_type"), flutter::EncodableValue(JsonString(value, "event_type"))},
        {flutter::EncodableValue("count"), flutter::EncodableValue(JsonInt(value, "count"))},
    });
  }
  return items;
}

std::string SerializeMap(const flutter::EncodableMap& map) {
  std::ostringstream output;
  output << '{';
  bool first = true;
  for (const auto& [key, value] : map) {
    const auto* key_string = std::get_if<std::string>(&key);
    if (key_string == nullptr) continue;
    if (!first) output << ',';
    first = false;
    output << '"' << EscapeJson(*key_string) << "\":" << SerializeValue(value);
  }
  output << '}';
  return output.str();
}

std::string SerializeList(const flutter::EncodableList& list) {
  std::ostringstream output;
  output << '[';
  for (size_t index = 0; index < list.size(); ++index) {
    if (index > 0) output << ',';
    output << SerializeValue(list[index]);
  }
  output << ']';
  return output.str();
}

const flutter::EncodableMap* Arguments(
    const flutter::MethodCall<flutter::EncodableValue>& call) {
  return call.arguments()
             ? std::get_if<flutter::EncodableMap>(call.arguments())
             : nullptr;
}

const flutter::EncodableValue* FindArgument(
    const flutter::EncodableMap* arguments,
    const std::string& key) {
  if (arguments == nullptr) return nullptr;
  const auto found = arguments->find(flutter::EncodableValue(key));
  return found == arguments->end() ? nullptr : &found->second;
}

}  // namespace gamblock::native_bridge
