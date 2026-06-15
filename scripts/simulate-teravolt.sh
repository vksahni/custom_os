#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROFILE="${1:-reference}"

declare -A SERVICE_STATUS=()

usage() {
  cat <<USAGE
Usage: $0 [profile]

Profiles:
  reference   Simulates the generic ARM64 development product.
  industrial  Simulates a stricter production-like profile.
USAGE
}

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "${ROOT_DIR}/${path}" ]] || fail "missing required file: ${path}"
}

require_dir() {
  local path="$1"
  [[ -d "${ROOT_DIR}/${path}" ]] || fail "missing required directory: ${path}"
}

start_service() {
  local name="$1"
  local dependency="${2:-}"

  if [[ -n "${dependency}" && "${SERVICE_STATUS[${dependency}]:-stopped}" != "running" ]]; then
    SERVICE_STATUS["${name}"]="blocked"
    log "service ${name}: blocked, dependency ${dependency} is not running"
    return
  fi

  SERVICE_STATUS["${name}"]="running"
  log "service ${name}: running"
}

print_properties() {
  local selinux_state="enforcing"
  local debug_state="enabled"

  if [[ "${PROFILE}" == "industrial" ]]; then
    debug_state="disabled"
  fi

  cat <<PROPS

Simulated Android properties
  ro.product.name=teravolt_arm64
  ro.product.brand=TeraVolt
  ro.product.model=TeraVolt OS ARM64 Reference
  ro.teravolt.os.name=TeraVoltOS
  ro.teravolt.os.profile=${PROFILE}
  ro.teravolt.security.selinux=${selinux_state}
  ro.teravolt.debug=${debug_state}
  ro.teravolt.hardware.serial=true
  ro.teravolt.hardware.can=true
  ro.teravolt.hardware.mqtt=true
  ro.teravolt.ai.edge=true
PROPS
}

print_interfaces() {
  cat <<INTERFACES

Simulated hardware interfaces
  uart0   present  /dev/ttyS0
  rs4850  present  /dev/ttyRS485-0
  can0    present  socketcan bitrate=500000
  eth0    present  dhcp
  gpio    present  restricted-service-access
INTERFACES
}

print_summary() {
  cat <<SUMMARY

Service summary
  init                 ${SERVICE_STATUS[init]:-stopped}
  servicemanager       ${SERVICE_STATUS[servicemanager]:-stopped}
  teravolt.serial      ${SERVICE_STATUS[teravolt.serial]:-stopped}
  teravolt.can         ${SERVICE_STATUS[teravolt.can]:-stopped}
  teravolt.mqtt        ${SERVICE_STATUS[teravolt.mqtt]:-stopped}
  teravolt.ai          ${SERVICE_STATUS[teravolt.ai]:-stopped}
  teravolt.monitor     ${SERVICE_STATUS[teravolt.monitor]:-stopped}
  teravolt.ota         ${SERVICE_STATUS[teravolt.ota]:-stopped}
  launcher             ${SERVICE_STATUS[launcher]:-stopped}
  settings             ${SERVICE_STATUS[settings]:-stopped}

Simulation result: boot-complete
SUMMARY
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

case "${PROFILE}" in
  reference|industrial) ;;
  *) fail "unknown profile '${PROFILE}'" ;;
esac

cd "${ROOT_DIR}"

require_dir "device/teravolt"
require_dir "vendor/teravolt"
require_dir "launcher"
require_dir "settings"
require_dir "services"
require_file "device/teravolt/AndroidProducts.mk"
require_file "device/teravolt/arm64/teravolt_arm64.mk"
require_file "vendor/teravolt/teravolt_vendor.mk"

log "TeraVolt OS simulation starting, profile=${PROFILE}"
log "stage bootloader: verified boot chain accepted"
log "stage kernel: ARM64 reference kernel initialized"
log "stage init: parsing product and vendor configuration"
SERVICE_STATUS["init"]="running"

start_service "servicemanager" "init"
start_service "teravolt.serial" "servicemanager"
start_service "teravolt.can" "servicemanager"
start_service "teravolt.mqtt" "servicemanager"
start_service "teravolt.ai" "servicemanager"
start_service "teravolt.monitor" "servicemanager"
start_service "teravolt.ota" "servicemanager"
start_service "launcher" "servicemanager"
start_service "settings" "servicemanager"

print_properties
print_interfaces
print_summary
