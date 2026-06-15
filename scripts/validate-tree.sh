#!/usr/bin/env bash
set -euo pipefail

readonly REQUIRED_DIRS=(
  "aosp"
  "kernel"
  "device/teravolt"
  "vendor/teravolt"
  "launcher"
  "settings"
  "services"
  "ota"
  "ai"
  "mqtt"
  "dronecan"
  "apps"
  "docs"
  "scripts"
  "tests"
)

readonly REQUIRED_FILES=(
  "README.md"
  "docs/architecture/overview.md"
  "docs/bringup/source-to-boot.md"
  "docs/security/security-model.md"
  "docs/testing/test-plan.md"
)

failures=0

for dir in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "${dir}" ]]; then
    echo "missing directory: ${dir}" >&2
    failures=$((failures + 1))
  fi
done

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "missing file: ${file}" >&2
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  echo "tree validation failed: ${failures} issue(s)" >&2
  exit 1
fi

echo "tree validation passed"
