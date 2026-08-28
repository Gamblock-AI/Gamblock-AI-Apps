#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 enable|disable|clear|export --device SERIAL [options]" >&2
  echo "Enable options: --run-id ID --device-alias ALIAS --scenario NAME" >&2
  echo "Export option: --output FILE" >&2
}

valid_scenario() {
  case "$1" in
    warm_foreground_online|warm_foreground_offline|warm_background_online|warm_background_offline|cold_foreground_online|cold_foreground_offline|cold_background_online|cold_background_offline) return 0 ;;
    *) return 1 ;;
  esac
}

action="${1:-}"
if [[ -z "$action" ]]; then
  usage
  exit 2
fi
shift

serial=""
run_id=""
device_alias=""
scenario=""
output=""
package_name="com.gamblock.gamblock_ai_apps"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) serial="${2:-}"; shift 2 ;;
    --run-id) run_id="${2:-}"; shift 2 ;;
    --device-alias) device_alias="${2:-}"; shift 2 ;;
    --scenario) scenario="${2:-}"; shift 2 ;;
    --output) output="${2:-}"; shift 2 ;;
    --package) package_name="${2:-}"; shift 2 ;;
    *) usage; exit 2 ;;
  esac
done

if [[ -z "$serial" ]]; then
  usage
  exit 2
fi
adb_cmd=(adb -s "$serial")
"${adb_cmd[@]}" get-state >/dev/null

case "$action" in
  enable)
    if [[ ! "$run_id" =~ ^[A-Za-z0-9_-]{1,64}$ ]] ||
       [[ ! "$device_alias" =~ ^[A-Za-z0-9_-]{1,64}$ ]] ||
       [[ ! "$scenario" =~ ^[A-Za-z0-9_-]{1,64}$ ]]; then
      echo "run ID, device alias, and scenario must be opaque safe labels" >&2
      exit 2
    fi
    if ! valid_scenario "$scenario"; then
      echo "scenario must be one of warm/cold + foreground/background + online/offline" >&2
      exit 2
    fi
    temp_file="$(mktemp)"
    trap 'rm -f "$temp_file"' EXIT
    printf '{"enabled":true,"run_id":"%s","device_alias":"%s","scenario":"%s"}\n' \
      "$run_id" "$device_alias" "$scenario" >"$temp_file"
    "${adb_cmd[@]}" push "$temp_file" /data/local/tmp/gamblock-phase4-config.json >/dev/null
    "${adb_cmd[@]}" shell run-as "$package_name" mkdir -p files/phase4-evidence
    "${adb_cmd[@]}" shell run-as "$package_name" cp \
      /data/local/tmp/gamblock-phase4-config.json files/phase4-evidence/config.json
    "${adb_cmd[@]}" shell rm /data/local/tmp/gamblock-phase4-config.json
    echo "Android Phase 4 evidence mode enabled for $scenario"
    ;;
  disable)
    "${adb_cmd[@]}" shell run-as "$package_name" rm -f files/phase4-evidence/config.json
    echo "Android Phase 4 evidence mode disabled"
    ;;
  clear)
    "${adb_cmd[@]}" shell run-as "$package_name" rm -f files/phase4-evidence/latency.jsonl
    echo "Android Phase 4 latency evidence cleared"
    ;;
  export)
    if [[ -z "$output" ]]; then
      usage
      exit 2
    fi
    "${adb_cmd[@]}" exec-out run-as "$package_name" \
      cat files/phase4-evidence/latency.jsonl >"$output"
    echo "Android Phase 4 evidence exported to $output"
    ;;
  *) usage; exit 2 ;;
esac
