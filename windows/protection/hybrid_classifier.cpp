#include "hybrid_classifier.h"

#include <algorithm>
#include <cmath>
#include <cctype>
#include <fstream>
#include <iterator>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <unordered_map>

namespace gamblock {
namespace {

std::string ReadFile(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) {
    throw std::runtime_error("artifact_not_found");
  }
  return std::string(std::istreambuf_iterator<char>(input),
                     std::istreambuf_iterator<char>());
}

std::string JsonString(const std::string& json, const std::string& key) {
  const std::regex pattern("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
  std::smatch match;
  if (!std::regex_search(json, match, pattern)) {
    throw std::runtime_error("artifact_field_missing:" + key);
  }
  return match[1].str();
}

double JsonNumber(const std::string& json,
                  const std::string& key,
                  double fallback) {
  const std::regex pattern("\"" + key +
                           "\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)");
  std::smatch match;
  return std::regex_search(json, match, pattern)
             ? std::stod(match[1].str())
             : fallback;
}

std::string ObjectBody(const std::string& json, const std::string& key) {
  const auto key_position = json.find("\"" + key + "\"");
  if (key_position == std::string::npos) {
    throw std::runtime_error("artifact_object_missing:" + key);
  }
  const auto opening = json.find('{', key_position);
  if (opening == std::string::npos) {
    throw std::runtime_error("artifact_object_invalid:" + key);
  }
  int depth = 0;
  for (size_t index = opening; index < json.size(); ++index) {
    if (json[index] == '{') {
      ++depth;
    } else if (json[index] == '}' && --depth == 0) {
      return json.substr(opening + 1, index - opening - 1);
    }
  }
  throw std::runtime_error("artifact_object_unclosed:" + key);
}

std::string ArrayBody(const std::string& json, const std::string& key) {
  const auto key_position = json.find("\"" + key + "\"");
  if (key_position == std::string::npos) {
    throw std::runtime_error("artifact_array_missing:" + key);
  }
  const auto opening = json.find('[', key_position);
  const auto closing = json.find(']', opening);
  if (opening == std::string::npos || closing == std::string::npos) {
    throw std::runtime_error("artifact_array_invalid:" + key);
  }
  return json.substr(opening + 1, closing - opening - 1);
}

std::map<std::string, double> ParseWeights(const std::string& json) {
  const std::string body = ObjectBody(json, "weights");
  const std::regex entry(
      "\"([^\"]+)\"\\s*:\\s*(-?[0-9]+(?:\\.[0-9]+)?)");
  std::map<std::string, double> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end;
       it != end; ++it) {
    values[it->str(1)] = std::stod(it->str(2));
  }
  if (values.empty()) {
    throw std::runtime_error("artifact_weights_empty");
  }
  return values;
}

std::vector<std::string> ParseStrings(const std::string& json,
                                      const std::string& key) {
  const std::string body = ArrayBody(json, key);
  const std::regex entry("\"([^\"]+)\"");
  std::vector<std::string> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end;
       it != end; ++it) {
    values.push_back(it->str(1));
  }
  return values;
}

std::string LowerAndBound(std::string value, size_t limit) {
  if (value.size() > limit) {
    value.resize(limit);
  }
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char character) {
                   return static_cast<char>(std::tolower(character));
                 });
  return value;
}

std::vector<std::string> Tokens(const std::string& value) {
  std::vector<std::string> tokens;
  std::string current;
  for (const unsigned char character : value) {
    if (std::isalnum(character) || character >= 128) {
      current.push_back(static_cast<char>(character));
    } else if (!current.empty()) {
      tokens.push_back(current);
      current.clear();
    }
  }
  if (!current.empty()) {
    tokens.push_back(current);
  }
  return tokens;
}

}  // namespace

bool HybridClassifier::Load(const std::string& model_path,
                            const std::string& rules_path,
                            std::string* error) {
  try {
    const std::string model = ReadFile(model_path);
    const std::string rules = ReadFile(rules_path);
    if (JsonString(model, "contract_version") != kContractVersion ||
        JsonString(rules, "contract_version") != kContractVersion) {
      throw std::runtime_error("artifact_contract_mismatch");
    }
    bias_ = JsonNumber(model, "bias", -3.2);
    threshold_ = JsonNumber(model, "threshold", 0.72);
    strong_score_ = JsonNumber(rules, "strong_score", 0.95);
    medium_score_ = JsonNumber(rules, "medium_score", 0.65);
    model_version_ = JsonString(model, "version");
    ruleset_version_ = JsonString(rules, "version");
    weights_ = ParseWeights(model);
    strong_patterns_ = ParseStrings(rules, "strong_url_patterns");
    medium_patterns_ = ParseStrings(rules, "medium_url_patterns");
    loaded_ = true;
    return true;
  } catch (const std::exception& exception) {
    loaded_ = false;
    if (error != nullptr) {
      *error = exception.what();
    }
    return false;
  }
}

ClassificationDecision HybridClassifier::Classify(
    const ClassificationInput& raw) const {
  ClassificationDecision decision;
  decision.model_version = model_version_;
  decision.ruleset_version = ruleset_version_;
  if (!loaded_) {
    decision.reason_code = "artifact_invalid";
    return decision;
  }

  const std::string url = LowerAndBound(raw.url, 2048);
  for (const auto& pattern : strong_patterns_) {
    if (url.find(pattern) != std::string::npos) {
      decision.rule_score = strong_score_;
      break;
    }
  }
  if (decision.rule_score == 0.0) {
    for (const auto& pattern : medium_patterns_) {
      if (url.find(pattern) != std::string::npos) {
        decision.rule_score = medium_score_;
        break;
      }
    }
  }

  std::ostringstream document;
  document << LowerAndBound(raw.title, 512) << ' ';
  for (size_t index = 0;
       index < std::min<size_t>(raw.headings.size(), 32); ++index) {
    document << LowerAndBound(raw.headings[index], 256) << ' ';
  }
  for (size_t index = 0;
       index < std::min<size_t>(raw.anchor_texts.size(), 64); ++index) {
    document << LowerAndBound(raw.anchor_texts[index], 256) << ' ';
  }
  std::unordered_map<std::string, int> counts;
  for (const auto& token : Tokens(document.str())) {
    counts[token] = std::min(3, counts[token] + 1);
  }
  double linear = bias_;
  for (const auto& [token, count] : counts) {
    const auto weight = weights_.find(token);
    if (weight != weights_.end()) {
      linear += weight->second * count;
    }
  }
  decision.model_score = 1.0 / (1.0 + std::exp(-linear));
  decision.block = decision.rule_score >= 0.95 ||
                   decision.model_score >= threshold_ ||
                   (decision.rule_score >= 0.55 &&
                    decision.model_score >= 0.55);
  if (decision.rule_score >= 0.95) {
    decision.reason_code = "strong_url_rule";
  } else if (decision.model_score >= threshold_) {
    decision.reason_code = "dummy_lr_threshold";
  } else if (decision.block) {
    decision.reason_code = "hybrid_combination";
  }
  return decision;
}

}  // namespace gamblock
