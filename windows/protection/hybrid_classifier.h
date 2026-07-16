#ifndef GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_
#define GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_

#include <map>
#include <string>
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
};

class HybridClassifier {
 public:
  static constexpr const char* kContractVersion = "hybrid-v1";

  bool Load(const std::string& model_path,
            const std::string& rules_path,
            std::string* error);
  ClassificationDecision Classify(const ClassificationInput& raw) const;

  const std::string& model_version() const { return model_version_; }
  const std::string& ruleset_version() const { return ruleset_version_; }
  bool loaded() const { return loaded_; }

 private:
  bool loaded_ = false;
  double bias_ = -3.2;
  double threshold_ = 0.72;
  double strong_score_ = 0.95;
  double medium_score_ = 0.65;
  std::string model_version_ = "dummy-lr-v1";
  std::string ruleset_version_ = "dummy-rules-v1";
  std::map<std::string, double> weights_;
  std::vector<std::string> strong_patterns_;
  std::vector<std::string> medium_patterns_;
};

}  // namespace gamblock

#endif  // GAMBLOCK_PROTECTION_HYBRID_CLASSIFIER_H_
