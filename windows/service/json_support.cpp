#include "service_support.h"

#include <algorithm>
#include <cmath>
#include <iomanip>
#include <regex>
#include <sstream>

namespace gamblock {

std::string EscapeJson(const std::string& value) {
  std::ostringstream escaped;
  for (const char character : value) {
    switch (character) {
      case '\\': escaped << "\\\\"; break;
      case '"': escaped << "\\\""; break;
      case '\n': escaped << "\\n"; break;
      case '\r': escaped << "\\r"; break;
      default: escaped << character; break;
    }
  }
  return escaped.str();
}

std::optional<std::string> JsonString(const std::string& json,
                                      const std::string& key) {
  const std::regex pattern("\"" + key +
                           "\"\\s*:\\s*\"((?:\\\\.|[^\"])*)\"");
  std::smatch match;
  if (!std::regex_search(json, match, pattern)) return std::nullopt;

  std::string decoded;
  decoded.reserve(match[1].length());
  bool escaped = false;
  for (const char character : match[1].str()) {
    if (escaped) {
      decoded.push_back(character == 'n' ? '\n' : character);
      escaped = false;
    } else if (character == '\\') {
      escaped = true;
    } else {
      decoded.push_back(character);
    }
  }
  return decoded;
}

std::optional<double> JsonNumber(const std::string& json,
                                 const std::string& key) {
  const std::regex pattern(
      "\"" + key +
      "\"\\s*:\\s*([+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?)");
  std::smatch match;
  if (!std::regex_search(json, match, pattern)) return std::nullopt;
  try {
    const double value = std::stod(match[1].str());
    return std::isfinite(value) ? std::optional<double>(value) : std::nullopt;
  } catch (...) {
    return std::nullopt;
  }
}

std::vector<std::string> JsonStringArray(const std::string& json,
                                         const std::string& key,
                                         size_t maximum_items,
                                         size_t maximum_item_bytes) {
  const auto key_position = json.find("\"" + key + "\"");
  if (key_position == std::string::npos) return {};
  const auto opening = json.find('[', key_position);
  const auto closing = json.find(']', opening);
  if (opening == std::string::npos || closing == std::string::npos) return {};

  const std::regex entry("\"((?:\\\\.|[^\"])*)\"");
  const std::string body = json.substr(opening + 1, closing - opening - 1);
  std::vector<std::string> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end;
       it != end && values.size() < maximum_items; ++it) {
    std::string value = it->str(1);
    if (value.size() > maximum_item_bytes) value.resize(maximum_item_bytes);
    values.push_back(std::move(value));
  }
  return values;
}

std::string RequestId(const std::string& command) {
  return JsonString(command, "request_id").value_or("");
}

std::string UtcDate() {
  SYSTEMTIME time{};
  GetSystemTime(&time);
  std::ostringstream value;
  value << std::setfill('0') << std::setw(4) << time.wYear << '-'
        << std::setw(2) << time.wMonth << '-' << std::setw(2) << time.wDay;
  return value.str();
}

bool ConstantTimeEqual(const std::string& left, const std::string& right) {
  size_t difference = left.size() ^ right.size();
  const size_t maximum = std::max(left.size(), right.size());
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

}  // namespace gamblock
