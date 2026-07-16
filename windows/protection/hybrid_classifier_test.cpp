#include "hybrid_classifier.h"

#include <cassert>
#include <filesystem>
#include <iostream>

int main(int argc, char** argv) {
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
  assert(explicit_url.reason_code == "strong_url_rule");

  const auto dom_only = classifier.Classify({
      "https://dynamic.invalid/",
      "Bonus jackpot hari ini",
      {"Main slot gacor dan casino"},
      {"Deposit sekarang", "Taruhan langsung"},
  });
  assert(dom_only.block);

  const auto benign = classifier.Classify({
      "https://kampus.ac.id/penelitian",
      "Portal penelitian universitas",
      {"Pendidikan dan beasiswa"},
      {"Jurnal research"},
  });
  assert(!benign.block);

  const auto empty = classifier.Classify({"", "", {}, {}});
  assert(!empty.block);
  std::cout << "hybrid-v1 fixtures passed\n";
  return 0;
}
