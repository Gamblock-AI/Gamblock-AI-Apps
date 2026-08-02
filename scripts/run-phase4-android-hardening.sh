#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --device SERIAL --run-id ID --device-alias ALIAS --output FILE --acknowledge-disposable-device" >&2
}

serial=""
output=""
run_id=""
device_alias=""
acknowledged="false"
package_name="com.gamblock.gamblock_ai_apps"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) serial="${2:-}"; shift 2 ;;
    --run-id) run_id="${2:-}"; shift 2 ;;
    --device-alias) device_alias="${2:-}"; shift 2 ;;
    --output) output="${2:-}"; shift 2 ;;
    --package) package_name="${2:-}"; shift 2 ;;
    --acknowledge-disposable-device) acknowledged="true"; shift ;;
    *) usage; exit 2 ;;
  esac
done
if [[ -z "$serial" || -z "$output" || "$acknowledged" != "true" ]] ||
   [[ ! "$run_id" =~ ^[A-Za-z0-9_-]{1,64}$ ]] ||
   [[ ! "$device_alias" =~ ^[A-Za-z0-9_-]{1,64}$ ]]; then
  usage
  exit 2
fi

adb_cmd=(adb -s "$serial")
"${adb_cmd[@]}" get-state >/dev/null
package_pid() {
  "${adb_cmd[@]}" shell pidof "$package_name" 2>/dev/null | tr -d '\r\n ' || true
}

before="$("${adb_cmd[@]}" shell settings get secure enabled_accessibility_services | tr -d '\r')"
enabled_before="false"
if [[ "$before" == *"$package_name"* ]]; then enabled_before="true"; fi
pid_before="$(package_pid)"
if [[ -z "$pid_before" ]]; then
  echo "Gamblock process must be running before the scenario" >&2
  exit 2
fi

scenario_started=$SECONDS
"${adb_cmd[@]}" shell am kill "$package_name"
replacement_process_observed="false"
deadline=$((SECONDS + 20))
while (( SECONDS < deadline )); do
  current_pid="$(package_pid)"
  if [[ -n "$current_pid" && "$current_pid" != "$pid_before" ]]; then
    replacement_process_observed="true"
    break
  fi
  sleep 1
done
after_kill="$("${adb_cmd[@]}" shell settings get secure enabled_accessibility_services | tr -d '\r')"
enabled_after_kill="false"
if [[ "$after_kill" == *"$package_name"* ]]; then enabled_after_kill="true"; fi

"${adb_cmd[@]}" shell am force-stop "$package_name"
sleep 2
process_absent_after_force_stop="false"
if [[ -z "$(package_pid)" ]]; then process_absent_after_force_stop="true"; fi
"${adb_cmd[@]}" shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 >/dev/null
process_after_launch="false"
deadline=$((SECONDS + 20))
while (( SECONDS < deadline )); do
  if [[ -n "$(package_pid)" ]]; then
    process_after_launch="true"
    break
  fi
  sleep 1
done
after_restart="$("${adb_cmd[@]}" shell settings get secure enabled_accessibility_services | tr -d '\r')"
enabled_after_restart="false"
if [[ "$after_restart" == *"$package_name"* ]]; then enabled_after_restart="true"; fi

passed="false"
if [[ "$enabled_before" == "true" &&
      "$enabled_after_kill" == "true" &&
      "$enabled_after_restart" == "true" &&
      "$replacement_process_observed" == "true" &&
      "$process_absent_after_force_stop" == "true" &&
      "$process_after_launch" == "true" ]]; then
  passed="true"
fi
recovery_within_seconds=$((SECONDS - scenario_started))
mkdir -p "$(dirname "$output")"
printf '%s\n' \
  "{" \
  "  \"schema_version\": 1," \
  "  \"report_kind\": \"phase4_resilience_run\"," \
  "  \"platform\": \"android\"," \
  "  \"run_id\": \"$run_id\"," \
  "  \"device_alias\": \"$device_alias\"," \
  "  \"host_identifier_emitted\": false," \
  "  \"unsafe_critical_process_api_used\": false," \
  "  \"scenario_results\": [" \
  "    {" \
  "      \"scenario\": \"ordinary_process_kill\"," \
  "      \"attempted\": true," \
  "      \"passed\": $passed," \
  "      \"device_recoverable\": $process_after_launch," \
  "      \"protection_recovered\": $replacement_process_observed," \
  "      \"unsafe_behavior_observed\": false," \
  "      \"evidence_reference\": \"android_process_kill\"," \
  "      \"recovery_within_seconds\": $recovery_within_seconds" \
  "    }" \
  "  ]," \
  "  \"review\": {\"approved\": false, \"reviewer\": null, \"reviewed_at\": null}" \
  "}" >"$output"
echo "Android resilience evidence written to $output"
if [[ "$passed" != "true" ]]; then
  exit 3
fi
