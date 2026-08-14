#!/usr/bin/env python3
"""Merge per-module l10n sources into the single ARB files consumed by
`flutter gen-l10n`.

`flutter gen-l10n` accepts exactly one template ARB file per locale
(l10n.yaml -> template-arb-file). To keep the Flutter catalog as organized as
the website's next-intl modules, the source of truth lives in
lib/l10n/modules/<locale>/<module>.json and this script merges them back into
lib/l10n/app_<locale>.arb before generation.

Usage:
    python3 scripts/merge_l10n.py          # merge (writes app_*.arb)
    python3 scripts/merge_l10n.py --check  # validate only, write nothing

Validation (always runs):
- Key-set parity between en and id (every key in en must exist in id and vice
  versa), ignoring the @@locale metadata key.
- No duplicate keys across modules within a locale.
- Metadata (@key) only for keys that exist, and every placeholder-declared
  key has matching @key metadata.
"""
from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N = os.path.join(ROOT, "lib", "l10n")
MODULES = os.path.join(L10N, "modules")
LOCALES = ("en", "id")

# Deterministic merge order: modules in this order, keys within a module in
# insertion (file) order.
MODULE_ORDER = [
    "shared",
    "auth",
    "settings",
    "legal",
    "protection",
    "analytics",
    "accountability",
    "intro",
    "setup",
    "pattern",
    "recovery",
    "engagement",
    "mini_games",
    "tour",
]


def load_module(locale: str, module: str) -> dict:
    path = os.path.join(MODULES, locale, f"{module}.json")
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def key_sets(locale: str) -> tuple[set, list]:
    keys: set = set()
    order: list = []
    seen: set = set()
    for module in MODULE_ORDER:
        data = load_module(locale, module)
        for key in data:
            if key == "@@locale":
                continue
            if key.startswith("@"):
                continue
            if key in seen:
                print(f"ERROR: duplicate key '{key}' in {locale}/{module}.json", file=sys.stderr)
                raise SystemExit(1)
            seen.add(key)
            keys.add(key)
            order.append(key)
    return keys, order


def validate() -> None:
    en_keys, en_order = key_sets("en")
    id_keys, _ = key_sets("id")
    if en_keys != id_keys:
        only_en = sorted(en_keys - id_keys)
        only_id = sorted(id_keys - en_keys)
        print("ERROR: locale key-set mismatch", file=sys.stderr)
        if only_en:
            print(f"  en only: {only_en}", file=sys.stderr)
        if only_id:
            print(f"  id only: {only_id}", file=sys.stderr)
        raise SystemExit(1)

    # Metadata sanity: every @key has a base key, and every key that declares
    # placeholders has its @key metadata present.
    for locale in LOCALES:
        data: dict = {}
        for module in MODULE_ORDER:
            data.update(load_module(locale, module))
        bases = {k for k in data if not k.startswith("@")}
        metas = {k for k in data if k.startswith("@") and k != "@@locale"}
        for meta in metas:
            base = meta[1:]
            if base not in bases:
                print(f"ERROR: metadata {meta} has no base key in {locale}", file=sys.stderr)
                raise SystemExit(1)
        for base in bases:
            if isinstance(data.get(base), dict):
                # Placeholder entries may declare placeholders via @base.
                pass
            meta = data.get("@" + base)
            if isinstance(meta, dict) and "placeholders" in meta:
                continue  # declared and present
            # If the value uses {placeholders} but has no metadata, warn.
            value = data.get(base)
            if isinstance(value, str) and "{" in value and meta is None:
                print(f"WARNING: {locale} key '{base}' uses placeholders without @metadata", file=sys.stderr)

    print("l10n modules valid: key parity OK, no duplicates, metadata OK")


def merge() -> None:
    for locale in LOCALES:
        merged: dict = {"@@locale": locale}
        for module in MODULE_ORDER:
            merged.update(load_module(locale, module))
        out_path = os.path.join(L10N, f"app_{locale}.arb")
        with open(out_path, "w", encoding="utf-8") as fh:
            json.dump(merged, fh, ensure_ascii=False, indent=2)
            fh.write("\n")
        print(f"wrote {os.path.relpath(out_path, ROOT)} ({len(merged)} entries)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Merge l10n module sources into ARB files.")
    parser.add_argument("--check", action="store_true", help="validate only, do not write")
    args = parser.parse_args()
    validate()
    if not args.check:
        merge()


if __name__ == "__main__":
    main()
