#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly AOSP_DIR="${ROOT_DIR}/aosp"
readonly MANIFEST_URL="${AOSP_MANIFEST_URL:-https://android.googlesource.com/platform/manifest}"
readonly BRANCH="${AOSP_BRANCH:-android-15.0.0_r1}"
readonly JOBS="${AOSP_SYNC_JOBS:-$(nproc)}"

usage() {
  cat <<USAGE
Usage: AOSP_BRANCH=<branch> AOSP_SYNC_JOBS=<jobs> $0

Defaults:
  AOSP_MANIFEST_URL=${MANIFEST_URL}
  AOSP_BRANCH=${BRANCH}
  AOSP_SYNC_JOBS=${JOBS}
USAGE
}

require_tool() {
  local tool="$1"
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "error: required tool '${tool}' was not found in PATH" >&2
    exit 1
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_tool repo
require_tool git

mkdir -p "${AOSP_DIR}"
cd "${AOSP_DIR}"

if [[ ! -d .repo ]]; then
  repo init -u "${MANIFEST_URL}" -b "${BRANCH}"
else
  echo "info: existing repo checkout detected at ${AOSP_DIR}"
fi

repo sync -c -j"${JOBS}" --fail-fast

echo "AOSP sync complete: ${AOSP_DIR}"
