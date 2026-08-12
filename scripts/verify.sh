#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# l10n sources are per-module under lib/l10n/modules/<locale>/*.json; validate
# key parity/metadata before analysis so a stale or broken catalog fails fast.
python3 scripts/merge_l10n.py --check

flutter analyze
