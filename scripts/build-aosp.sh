#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly AOSP_DIR="${ROOT_DIR}/aosp"
readonly PRODUCT="${1:-teravolt_arm64-userdebug}"

usage() {
  cat <<USAGE
Usage: $0 [product-variant]

Example:
  $0 teravolt_arm64-userdebug
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "${AOSP_DIR}/build/envsetup.sh" ]]; then
  echo "error: AOSP tree is not synced at ${AOSP_DIR}" >&2
  echo "run: ./scripts/sync-aosp.sh" >&2
  exit 1
fi

cd "${AOSP_DIR}"

# shellcheck source=/dev/null
source build/envsetup.sh
lunch "${PRODUCT}"
m
