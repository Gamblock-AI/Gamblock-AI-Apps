#ifndef GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_
#define GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_

#include <string>
#include <unordered_map>
#include <vector>

namespace gamblock {

struct ClassificationInput {
  std::string url;
  std::string title;
  std::vector<std::string> headings;
  std::vector<std::string> anchor_texts;
};

struct ClassificationDecision {
  bool block = false;
  double rule_score = 0.0;
  double model_score = 0.0;
  std::string reason_code = "below_threshold";
  std::string model_version;
  std::string ruleset_version;
  double preprocessing_duration_ms = 0.0;
  double rule_duration_ms = 0.0;
  double inference_duration_ms = 0.0;
  double decision_duration_ms = 0.0;
};

struct UrlFeatureSpec {
  std::string name;
  double offset = 0.0;
  double scale = 1.0;
  double weight = 0.0;
};

class HybridClassifier {
public:
  static constexpr const char *kContractVersion = "hybrid-v2";

  bool Load(const std::string &model_path, const std::string &rules_path,
            std::string *error);
  ClassificationDecision Classify(const ClassificationInput &raw) const;

  const std::string &model_version() const { return model_version_; }
  const std::string &ruleset_version() const { return ruleset_version_; }
  bool loaded() const { return loaded_; }

private:
  bool loaded_ = false;
  double bias_ = 0.0;
  double ml_weight_ = 0.75;
  double rule_weight_ = 0.25;
  double threshold_ = 0.4;
  double rule_match_score_ = 1.0;
  std::string model_version_ = "gamblock-lr-bfafb725511a";
  std::string ruleset_version_ = "gambling-keywords-b4f2932a7647";
  std::unordered_map<std::string, double> unigram_weights_;
  std::unordered_map<std::string, double> bigram_weights_;
  std::vector<UrlFeatureSpec> url_features_;
  std::vector<std::string> rule_keywords_;
  std::vector<std::string> normalized_rule_keywords_;
};

} // namespace gamblock

#endif // GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_
