#include "hybrid_classifier.h"

#include <cassert>
#include <filesystem>
#include <iostream>

int main(int argc, char **argv) {
  if (argc != 3) {
    std::cerr << "usage: hybrid_classifier_test <model> <rules>\n";
    return 2;
  }
  gamblock::HybridClassifier classifier;
  std::string error;
  assert(classifier.Load(argv[1], argv[2], &error));

  const auto explicit_url = classifier.Classify({
      "https://contoh-judi.invalid/slot-gacor",
      "",
      {},
      {},
  });
  assert(explicit_url.block);
  assert(explicit_url.reason_code == "hybrid_keyword_match");
  assert(explicit_url.preprocessing_duration_ms >= 0.0);
  assert(explicit_url.rule_duration_ms >= 0.0);
  assert(explicit_url.inference_duration_ms >= 0.0);
  assert(explicit_url.decision_duration_ms >= 0.0);

  const auto dom_only = classifier.Classify({
      "https://dynamic.invalid/",
      "Bonus jackpot hari ini",
      {"Main slot gacor dan casino"},
      {"Deposit sekarang", "Taruhan langsung"},
  });
  assert(dom_only.block);

  const auto dom_model_only = classifier.Classify({
      "https://dynamic.invalid/",
      "Academic Information Portal",
      {"Lottery gaming and prize information", "Trusted alternative games"},
      {"View the numbers guide", "Login for prediction information",
       "Download the trusted APK", "Live chat support"},
  });
  assert(dom_model_only.block);
  assert(dom_model_only.rule_score == 0.0);
  assert(dom_model_only.model_score > 0.5);
  assert(dom_model_only.reason_code == "model_threshold");

  const auto benign = classifier.Classify({
      "https://kampus.ac.id/penelitian",
      "Portal penelitian universitas",
      {"Pendidikan dan beasiswa"},
      {"Jurnal research"},
  });
  assert(!benign.block);

  const auto empty = classifier.Classify({"", "", {}, {}});
  assert(!empty.block);
  std::cout << "hybrid-v2 fixtures passed\n";
  return 0;
}
