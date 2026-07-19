#!/usr/bin/env python3
"""Export the supported scikit-learn ONNX pipeline to Hybrid-v2 JSON.

The Android Accessibility Service and Windows LocalSystem service deliberately
share a small, dependency-free linear runtime. This exporter reads the ONNX
graph through `protoc --decode_raw`, verifies the expected scaler/vectorizer/
classifier layout, and emits the exact float32 weights used by that runtime.

It never unpickles the companion `.pkl` file.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import subprocess
import tempfile
from pathlib import Path


FEATURE_NAMES = [
    "url_length",
    "url_digit_count",
    "url_dot_count",
    "url_slash_count",
    "url_hyphen_count",
    "url_question_count",
    "url_equal_count",
    "url_keyword_count",
    "url_has_number",
    "url_has_https",
    "url_is_valid",
    "domain_length",
    "subdomain_length",
    "suffix_length",
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


MINIMAL_ONNX_PROTO = r'''
syntax = "proto2";
package onnx;
message ModelProto { optional GraphProto graph = 7; }
message GraphProto { repeated NodeProto node = 1; }
message NodeProto {
  repeated string input = 1;
  repeated string output = 2;
  optional string name = 3;
  optional string op_type = 4;
  repeated AttributeProto attribute = 5;
  optional string domain = 7;
}
message AttributeProto {
  optional string name = 1;
  optional float f = 2;
  optional int64 i = 3;
  optional bytes s = 4;
  repeated float floats = 7 [packed = true];
  repeated int64 ints = 8 [packed = true];
  repeated bytes strings = 9;
  optional int32 type = 20;
}
'''


def decode_model(path: Path) -> list[str]:
    with tempfile.TemporaryDirectory(prefix="gamblock-onnx-") as directory:
        schema = Path(directory) / "onnx_minimal.proto"
        schema.write_text(MINIMAL_ONNX_PROTO, encoding="utf-8")
        result = subprocess.run(
            [
                "protoc",
                f"--proto_path={directory}",
                "--decode=onnx.ModelProto",
                str(schema),
            ],
            input=path.read_bytes(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
    return result.stdout.decode("utf-8").splitlines()


def node(lines: list[str], op_type: str) -> list[str]:
    marker = f'    op_type: "{op_type}"'
    target = next(index for index, line in enumerate(lines) if line == marker)
    start = target
    while start >= 0 and lines[start] != "  node {":
        start -= 1
    if start < 0:
        raise ValueError(f"node start missing: {op_type}")
    end = target
    while end < len(lines) and lines[end] != "  }":
        end += 1
    if end == len(lines):
        raise ValueError(f"node end missing: {op_type}")
    return lines[start : end + 1]


def attributes(node_lines: list[str]) -> dict[str, list[str]]:
    values: dict[str, list[str]] = {}
    index = 0
    while index < len(node_lines):
        if node_lines[index] != "    attribute {":
            index += 1
            continue
        end = index + 1
        while end < len(node_lines) and node_lines[end] != "    }":
            end += 1
        block = node_lines[index + 1 : end]
        name_line = next(
            (line for line in block if line.startswith('      name: "')), None
        )
        if name_line is None:
            raise ValueError("attribute name missing")
        name = ast.literal_eval(name_line.split(": ", 1)[1])
        values[name] = block
        index = end + 1
    return values


def repeated(block: list[str], field: int) -> list[str]:
    names = {7: "floats", 8: "ints", 9: "strings"}
    prefix = f"      {names[field]}: "
    return [line[len(prefix) :] for line in block if line.startswith(prefix)]


def floats(block: list[str]) -> list[float]:
    return [float(value) for value in repeated(block, 7)]


def integers(block: list[str]) -> list[int]:
    return [int(value) for value in repeated(block, 8)]


def strings(block: list[str]) -> list[str]:
    return [ast.literal_eval(value) for value in repeated(block, 9)]


def close(left: float, right: float, tolerance: float = 1e-6) -> bool:
    return abs(left - right) <= tolerance


def export_model(onnx_path: Path, metadata_path: Path) -> dict[str, object]:
    lines = decode_model(onnx_path)
    scaler = attributes(node(lines, "Scaler"))
    vectorizer = attributes(node(lines, "TfIdfVectorizer"))
    classifier = attributes(node(lines, "LinearClassifier"))

    offsets = floats(scaler["offset"])
    scales = floats(scaler["scale"])
    pool = strings(vectorizer["pool_strings"])
    ngram_counts = integers(vectorizer["ngram_counts"])
    indexes = integers(vectorizer["ngram_indexes"])
    coefficients = floats(classifier["coefficients"])
    intercepts = floats(classifier["intercepts"])

    if len(offsets) != len(FEATURE_NAMES) or len(scales) != len(FEATURE_NAMES):
        raise ValueError("unexpected URL scaler width")
    if ngram_counts != [0, 5664]:
        raise ValueError(f"unexpected ngram offsets: {ngram_counts}")
    unigram_count = ngram_counts[1]
    bigram_pool = len(pool) - unigram_count
    if bigram_pool < 0 or bigram_pool % 2 != 0:
        raise ValueError("invalid vectorizer pool")
    bigram_count = bigram_pool // 2
    if unigram_count + bigram_count != len(indexes):
        raise ValueError("ngram index count does not match pool")

    feature_width = len(indexes) + len(FEATURE_NAMES)
    if len(coefficients) != feature_width * 2 or len(intercepts) != 2:
        raise ValueError("unexpected binary classifier dimensions")
    negative = coefficients[:feature_width]
    positive = coefficients[feature_width:]
    if not all(close(left, -right) for left, right in zip(negative, positive)):
        raise ValueError("binary class coefficients are not symmetric")
    if not close(intercepts[0], -intercepts[1]):
        raise ValueError("binary class intercepts are not symmetric")

    unigram_weights: dict[str, float] = {}
    for position in range(unigram_count):
        unigram_weights[pool[position]] = positive[indexes[position]]
    bigram_weights: dict[str, float] = {}
    for position in range(bigram_count):
        pool_offset = unigram_count + position * 2
        feature_index = indexes[unigram_count + position]
        bigram_weights[f"{pool[pool_offset]} {pool[pool_offset + 1]}"] = positive[
            feature_index
        ]

    supplied = json.loads(metadata_path.read_text(encoding="utf-8"))
    metadata_features = supplied.get("url_features", supplied.get("url_feature_columns"))
    if metadata_features != FEATURE_NAMES:
        raise ValueError("metadata URL feature order differs from the ONNX contract")
    hybrid = supplied.get("hybrid_configuration", supplied)

    return {
        "contract_version": "hybrid-v2",
        "version": f"gamblock-lr-{sha256(onnx_path)[:12]}",
        "kind": "sklearn_logistic_regression_bow_url",
        "trained": True,
        "evaluated": False,
        "source_onnx_sha256": sha256(onnx_path),
        "source_metadata_sha256": sha256(metadata_path),
        "preprocessing": {
            "text_normalization": "lowercase_ascii_alphanumeric_underscore",
            "ngram_range": [1, 2],
            "bow_mode": "term_frequency",
            "url_feature_contract": "gamblock-url-v1",
        },
        "bias": intercepts[1],
        "ml_weight": float(hybrid["ml_weight"]),
        "rule_weight": float(hybrid["rule_weight"]),
        "threshold": float(hybrid["threshold"]),
        "unigram_weights": dict(sorted(unigram_weights.items())),
        "bigram_weights": dict(sorted(bigram_weights.items())),
        "url_features": [
            {
                "name": name,
                "offset": offsets[index],
                "scale": scales[index],
                "weight": positive[len(indexes) + index],
            }
            for index, name in enumerate(FEATURE_NAMES)
        ],
        "reported_metrics_unverified": supplied.get(
            "evaluation_metrics", supplied.get("metrics", {})
        ),
    }


def export_rules(keywords_path: Path) -> dict[str, object]:
    keywords = json.loads(keywords_path.read_text(encoding="utf-8"))
    if not isinstance(keywords, list) or not keywords:
        raise ValueError("keyword list is empty")
    normalized = sorted({str(keyword).strip().lower() for keyword in keywords})
    return {
        "contract_version": "hybrid-v2",
        "version": f"gambling-keywords-{sha256(keywords_path)[:12]}",
        "source_sha256": sha256(keywords_path),
        "match_surface": "url_and_dom",
        "match_score": 1.0,
        "keywords": normalized,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--onnx", required=True, type=Path)
    parser.add_argument("--metadata", required=True, type=Path)
    parser.add_argument("--keywords", required=True, type=Path)
    parser.add_argument("--model-output", required=True, type=Path)
    parser.add_argument("--rules-output", required=True, type=Path)
    args = parser.parse_args()

    model = export_model(args.onnx, args.metadata)
    rules = export_rules(args.keywords)
    args.model_output.write_text(
        json.dumps(model, ensure_ascii=True, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    args.rules_output.write_text(
        json.dumps(rules, ensure_ascii=True, indent=2) + "\n", encoding="utf-8"
    )
    print(
        json.dumps(
            {
                "model": model["version"],
                "unigrams": len(model["unigram_weights"]),
                "bigrams": len(model["bigram_weights"]),
                "rules": rules["version"],
            }
        )
    )


if __name__ == "__main__":
    main()
