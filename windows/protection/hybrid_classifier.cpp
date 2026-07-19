#include "hybrid_classifier.h"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <fstream>
#include <iterator>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <unordered_map>

namespace gamblock {
namespace {

constexpr const char *kNumber = "-?[0-9]+[0-9.eE+-]*";

std::string ReadFile(const std::string &path) {
  std::ifstream input(path, std::ios::binary);
  if (!input)
    throw std::runtime_error("artifact_not_found");
  return std::string(std::istreambuf_iterator<char>(input),
                     std::istreambuf_iterator<char>());
}

std::string JsonString(const std::string &json, const std::string &key) {
  const std::regex pattern("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
  std::smatch match;
  if (!std::regex_search(json, match, pattern)) {
    throw std::runtime_error("artifact_field_missing:" + key);
  }
  return match[1].str();
}

double JsonNumber(const std::string &json, const std::string &key,
                  double fallback) {
  const std::regex pattern("\"" + key + "\"\\s*:\\s*(" + kNumber + ")");
  std::smatch match;
  return std::regex_search(json, match, pattern) ? std::stod(match[1].str())
                                                 : fallback;
}

std::string ObjectBody(const std::string &json, const std::string &key) {
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

std::string ArrayBody(const std::string &json, const std::string &key) {
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

std::unordered_map<std::string, double> ParseWeights(const std::string &json,
                                                     const std::string &key) {
  const std::string body = ObjectBody(json, key);
  const std::regex entry("\"([^\"]+)\"\\s*:\\s*(" + std::string(kNumber) + ")");
  std::unordered_map<std::string, double> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end; it != end;
       ++it) {
    values[it->str(1)] = std::stod(it->str(2));
  }
  if (values.empty())
    throw std::runtime_error("artifact_weights_empty:" + key);
  return values;
}

std::vector<std::string> ParseStrings(const std::string &json,
                                      const std::string &key) {
  const std::string body = ArrayBody(json, key);
  const std::regex entry("\"([^\"]+)\"");
  std::vector<std::string> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end; it != end;
       ++it) {
    values.push_back(it->str(1));
  }
  return values;
}

std::vector<UrlFeatureSpec> ParseUrlFeatures(const std::string &json) {
  const std::string body = ArrayBody(json, "url_features");
  const std::string number = kNumber;
  const std::regex entry("\\{\\s*\"name\"\\s*:\\s*\"([^\"]+)\"\\s*,\\s*"
                         "\"offset\"\\s*:\\s*(" +
                         number +
                         ")\\s*,\\s*"
                         "\"scale\"\\s*:\\s*(" +
                         number +
                         ")\\s*,\\s*"
                         "\"weight\"\\s*:\\s*(" +
                         number + ")\\s*\\}");
  std::vector<UrlFeatureSpec> values;
  for (std::sregex_iterator it(body.begin(), body.end(), entry), end; it != end;
       ++it) {
    values.push_back({it->str(1), std::stod(it->str(2)), std::stod(it->str(3)),
                      std::stod(it->str(4))});
  }
  if (values.size() != 14) {
    throw std::runtime_error("artifact_url_features_invalid");
  }
  return values;
}

std::string LowerAndBound(std::string value, size_t limit) {
  if (value.size() > limit)
    value.resize(limit);
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char character) {
                   return static_cast<char>(std::tolower(character));
                 });
  return value;
}

std::vector<std::string> Tokens(const std::string &value) {
  std::vector<std::string> tokens;
  std::string current;
  for (const unsigned char character : value) {
    if (std::isalnum(character) || character == '_') {
      current.push_back(static_cast<char>(std::tolower(character)));
    } else if (!current.empty()) {
      tokens.push_back(current);
      current.clear();
    }
  }
  if (!current.empty())
    tokens.push_back(current);
  return tokens;
}

std::string NormalizeForRules(const std::string &value) {
  std::ostringstream output;
  bool separator = true;
  for (const unsigned char character : value) {
    if (std::isalnum(character) || character == '_') {
      output << static_cast<char>(std::tolower(character));
      separator = false;
    } else if (!separator) {
      output << ' ';
      separator = true;
    }
  }
  std::string result = output.str();
  while (!result.empty() && result.back() == ' ')
    result.pop_back();
  return result;
}

bool ContainsPhrase(const std::string &haystack, const std::string &needle) {
  return !needle.empty() &&
         (" " + haystack + " ").find(" " + needle + " ") != std::string::npos;
}

std::unordered_map<std::string, double> UrlFeatureValues(const std::string &url,
                                                         int keyword_count) {
  const std::string lower = LowerAndBound(url, 2048);
  std::smatch match;
  const std::regex url_pattern("^(https?)://([^/?#]+)");
  const bool parsed = std::regex_search(lower, match, url_pattern);
  const std::string scheme = parsed ? match[1].str() : "";
  std::string host = parsed ? match[2].str() : "";
  const auto at = host.rfind('@');
  if (at != std::string::npos)
    host = host.substr(at + 1);
  const auto port = host.find(':');
  if (port != std::string::npos)
    host = host.substr(0, port);
  while (!host.empty() && host.back() == '.')
    host.pop_back();

  std::vector<std::string> labels;
  std::stringstream host_stream(host);
  std::string label;
  while (std::getline(host_stream, label, '.')) {
    if (!label.empty())
      labels.push_back(label);
  }
  const std::string suffix = labels.empty() ? "" : labels.back();
  std::string subdomain;
  if (labels.size() > 2) {
    for (size_t index = 0; index + 2 < labels.size(); ++index) {
      if (!subdomain.empty())
        subdomain += '.';
      subdomain += labels[index];
    }
  }
  const auto count = [&url](char value) {
    return static_cast<double>(std::count(url.begin(), url.end(), value));
  };
  const auto digit_count = static_cast<double>(
      std::count_if(url.begin(), url.end(),
                    [](unsigned char value) { return std::isdigit(value); }));
  return {{"url_length", static_cast<double>(url.size())},
          {"url_digit_count", digit_count},
          {"url_dot_count", count('.')},
          {"url_slash_count", count('/')},
          {"url_hyphen_count", count('-')},
          {"url_question_count", count('?')},
          {"url_equal_count", count('=')},
          {"url_keyword_count", static_cast<double>(keyword_count)},
          {"url_has_number", digit_count > 0.0 ? 1.0 : 0.0},
          {"url_has_https", scheme == "https" ? 1.0 : 0.0},
          {"url_is_valid", parsed && !host.empty() ? 1.0 : 0.0},
          {"domain_length", static_cast<double>(host.size())},
          {"subdomain_length", static_cast<double>(subdomain.size())},
          {"suffix_length", static_cast<double>(suffix.size())}};
}

} // namespace

bool HybridClassifier::Load(const std::string &model_path,
                            const std::string &rules_path, std::string *error) {
  try {
    const std::string model = ReadFile(model_path);
    const std::string rules = ReadFile(rules_path);
    if (JsonString(model, "contract_version") != kContractVersion ||
        JsonString(rules, "contract_version") != kContractVersion) {
      throw std::runtime_error("artifact_contract_mismatch");
    }
    bias_ = JsonNumber(model, "bias", 0.0);
    ml_weight_ = JsonNumber(model, "ml_weight", 0.75);
    rule_weight_ = JsonNumber(model, "rule_weight", 0.25);
    threshold_ = JsonNumber(model, "threshold", 0.4);
    rule_match_score_ = JsonNumber(rules, "match_score", 1.0);
    model_version_ = JsonString(model, "version");
    ruleset_version_ = JsonString(rules, "version");
    unigram_weights_ = ParseWeights(model, "unigram_weights");
    bigram_weights_ = ParseWeights(model, "bigram_weights");
    url_features_ = ParseUrlFeatures(model);
    rule_keywords_ = ParseStrings(rules, "keywords");
    if (rule_keywords_.empty())
      throw std::runtime_error("artifact_rules_empty");
    loaded_ = true;
    return true;
  } catch (const std::exception &exception) {
    loaded_ = false;
    if (error != nullptr)
      *error = exception.what();
    return false;
  }
}

ClassificationDecision
HybridClassifier::Classify(const ClassificationInput &raw) const {
  ClassificationDecision decision;
  decision.model_version = model_version_;
  decision.ruleset_version = ruleset_version_;
  if (!loaded_) {
    decision.reason_code = "artifact_invalid";
    return decision;
  }

  const std::string url = LowerAndBound(raw.url, 2048);
  const std::string normalized_url = NormalizeForRules(url);
  int url_keyword_count = 0;
  for (const auto &keyword : rule_keywords_) {
    if (ContainsPhrase(normalized_url, NormalizeForRules(keyword))) {
      ++url_keyword_count;
    }
  }

  std::ostringstream document;
  document << LowerAndBound(raw.title, 512) << ' ';
  for (size_t index = 0; index < std::min<size_t>(raw.headings.size(), 32);
       ++index) {
    document << LowerAndBound(raw.headings[index], 256) << ' ';
  }
  for (size_t index = 0; index < std::min<size_t>(raw.anchor_texts.size(), 64);
       ++index) {
    document << LowerAndBound(raw.anchor_texts[index], 256) << ' ';
  }
  const std::string document_text = document.str();
  const std::string rule_input =
      normalized_url + " " + NormalizeForRules(document_text);
  for (const auto &keyword : rule_keywords_) {
    if (ContainsPhrase(rule_input, NormalizeForRules(keyword))) {
      decision.rule_score = rule_match_score_;
      break;
    }
  }

  const auto tokens = Tokens(document_text);
  std::unordered_map<std::string, int> unigrams;
  std::unordered_map<std::string, int> bigrams;
  for (size_t index = 0; index < tokens.size(); ++index) {
    ++unigrams[tokens[index]];
    if (index > 0)
      ++bigrams[tokens[index - 1] + " " + tokens[index]];
  }
  double linear = bias_;
  for (const auto &[token, count] : unigrams) {
    const auto weight = unigram_weights_.find(token);
    if (weight != unigram_weights_.end())
      linear += weight->second * count;
  }
  for (const auto &[token, count] : bigrams) {
    const auto weight = bigram_weights_.find(token);
    if (weight != bigram_weights_.end())
      linear += weight->second * count;
  }
  const auto feature_values = UrlFeatureValues(url, url_keyword_count);
  for (const auto &feature : url_features_) {
    const auto value = feature_values.find(feature.name);
    const double raw_value =
        value == feature_values.end() ? 0.0 : value->second;
    linear += ((raw_value - feature.offset) * feature.scale) * feature.weight;
  }

  decision.model_score = 1.0 / (1.0 + std::exp(-linear));
  const double hybrid_score =
      ml_weight_ * decision.model_score + rule_weight_ * decision.rule_score;
  decision.block = hybrid_score >= threshold_;
  if (decision.block && decision.rule_score > 0.0) {
    decision.reason_code = "hybrid_keyword_match";
  } else if (decision.block) {
    decision.reason_code = "model_threshold";
  }
  return decision;
}

} // namespace gamblock
