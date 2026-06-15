#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly AOSP_DIR="${ROOT_DIR}/aosp"
readonly OUT_DIR="${AOSP_DIR}/out/target/product"

readonly PRODUCTS=(
  "generic_arm64"
  "qemu_arm64"
  "sdk_phone_arm64"
  "aosp_arm64"
)

pass_count=0
fail_count=0
warn_count=0

pass() {
  printf '[PASS] %s\n' "$*"
  pass_count=$((pass_count + 1))
}

fail() {
  printf '[FAIL] %s\n' "$*"
  fail_count=$((fail_count + 1))
}

warn() {
  printf '[WARN] %s\n' "$*"
  warn_count=$((warn_count + 1))
}

info() {
  printf '[INFO] %s\n' "$*"
}

check_file() {
  local label="$1"
  local path="$2"

  if [[ -f "${path}" ]]; then
    pass "${label}: ${path}"
  else
    fail "${label}: missing ${path}"
  fi
}

check_dir() {
  local label="$1"
  local path="$2"

  if [[ -d "${path}" ]]; then
    pass "${label}: ${path}"
  else
    fail "${label}: missing ${path}"
  fi
}

find_product_dir() {
  local product
  for product in "${PRODUCTS[@]}"; do
    if [[ -d "${OUT_DIR}/${product}" ]]; then
      printf '%s\n' "${OUT_DIR}/${product}"
      return 0
    fi
  done
  return 1
}

print_qemu_command() {
  local product_dir="$1"
  local kernel="${product_dir}/kernel-qemu2"
  local ramdisk="${product_dir}/ramdisk.img"
  local system="${product_dir}/system.img"
  local userdata="${product_dir}/userdata.img"
  local vendor="${product_dir}/vendor.img"

  cat <<COMMAND

Suggested QEMU command after images exist:

qemu-system-aarch64 \\
  -machine virt \\
  -cpu cortex-a57 \\
  -m 4096 \\
  -smp 4 \\
  -nographic \\
  -serial mon:stdio \\
  -kernel "${kernel}" \\
  -initrd "${ramdisk}" \\
  -append "console=ttyAMA0 androidboot.hardware=goldfish androidboot.serialno=TERAVOLTQEMU" \\
  -drive if=none,id=system,format=raw,readonly=on,file="${system}" \\
  -device virtio-blk-device,drive=system \\
  -drive if=none,id=userdata,format=raw,file="${userdata}" \\
  -device virtio-blk-device,drive=userdata \\
  -drive if=none,id=vendor,format=raw,readonly=on,file="${vendor}" \\
  -device virtio-blk-device,drive=vendor \\
  -netdev user,id=net0,hostfwd=tcp::5555-:5555 \\
  -device virtio-net-device,netdev=net0
COMMAND
}

main() {
  cd "${ROOT_DIR}"

  info "TeraVolt OS QEMU preflight"
  info "Project root: ${ROOT_DIR}"

  if command -v qemu-system-aarch64 >/dev/null 2>&1; then
    pass "qemu-system-aarch64: $(qemu-system-aarch64 --version | head -1)"
  else
    fail "qemu-system-aarch64 is not installed"
  fi

  check_dir "AOSP directory" "${AOSP_DIR}"
  check_file "AOSP build environment" "${AOSP_DIR}/build/envsetup.sh"
  check_file "TeraVolt product makefile" "${ROOT_DIR}/device/teravolt/arm64/teravolt_arm64.mk"
  check_file "TeraVolt BoardConfig" "${ROOT_DIR}/device/teravolt/arm64/BoardConfig.mk"
  check_file "TeraVolt vendor makefile" "${ROOT_DIR}/vendor/teravolt/teravolt_vendor.mk"

  if [[ -d "${AOSP_DIR}/frameworks" ]]; then
    pass "AOSP frameworks source present"
  else
    fail "AOSP frameworks source missing; repo sync is incomplete"
  fi

  if [[ -d "${AOSP_DIR}/packages" ]]; then
    pass "AOSP packages source present"
  else
    fail "AOSP packages source missing; repo sync is incomplete"
  fi

  if [[ -d "${AOSP_DIR}/prebuilts" ]]; then
    pass "AOSP prebuilts present"
  else
    fail "AOSP prebuilts missing; build toolchain is incomplete"
  fi

  if [[ -d "${OUT_DIR}" ]]; then
    pass "AOSP product output directory present"
  else
    fail "AOSP product output directory missing; no Android image has been built"
  fi

  local product_dir=""
  if product_dir="$(find_product_dir)"; then
    pass "candidate product output: ${product_dir}"
    check_file "system image" "${product_dir}/system.img"
    check_file "ramdisk image" "${product_dir}/ramdisk.img"
    if [[ -f "${product_dir}/kernel-qemu2" || -f "${product_dir}/boot.img" ]]; then
      pass "kernel or boot image present in ${product_dir}"
    else
      fail "kernel-qemu2 or boot.img missing in ${product_dir}"
    fi
    if [[ -f "${product_dir}/userdata.img" ]]; then
      pass "userdata image: ${product_dir}/userdata.img"
    else
      warn "userdata image missing; it can be created during a proper AOSP build"
    fi
    if [[ -f "${product_dir}/vendor.img" ]]; then
      pass "vendor image: ${product_dir}/vendor.img"
    else
      warn "vendor image missing; some targets may not require a separate vendor image"
    fi
    print_qemu_command "${product_dir}"
  else
    fail "no supported QEMU product output found under ${OUT_DIR}"
  fi

  if [[ -f "${ROOT_DIR}/launcher/build/outputs/apk/debug/launcher-debug.apk" ]]; then
    pass "launcher APK built"
  else
    warn "launcher APK not built"
  fi

  if [[ -f "${ROOT_DIR}/settings/build/outputs/apk/debug/settings-debug.apk" ]]; then
    pass "settings APK built"
  else
    warn "settings APK not built"
  fi

  cat <<SUMMARY

Summary:
  pass: ${pass_count}
  warn: ${warn_count}
  fail: ${fail_count}
SUMMARY

  if (( fail_count > 0 )); then
    cat <<NEXT

QEMU full-system simulation is not ready.
Required next steps:
  1. Complete AOSP sync: cd ${AOSP_DIR} && repo sync -c -j4 --fail-fast
  2. Build a QEMU-capable product from AOSP.
  3. Re-run: ${ROOT_DIR}/scripts/qemu-preflight.sh
  4. Boot only after system.img, ramdisk.img, and kernel-qemu2 or boot.img exist.
NEXT
    exit 1
  fi

  info "QEMU full-system simulation prerequisites are present"
}

main "$@"
