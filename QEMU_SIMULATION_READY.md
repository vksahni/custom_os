# QEMU Simulation Readiness

## Current Status

TeraVolt OS is not ready for full Android QEMU boot from the current folder state.

## Architecture Diagram

```text
Current repository
  ├─ partial AOSP checkout
  ├─ TeraVolt product/vendor scaffold
  ├─ Launcher and Settings source
  ├─ host-side service simulator
  └─ QEMU preflight

Required for QEMU full boot
  ├─ complete AOSP checkout
  ├─ QEMU-capable product build
  ├─ system.img
  ├─ ramdisk.img
  ├─ kernel-qemu2 or boot.img
  └─ optional APKs or system-integrated apps
```

## Folder Analysis Summary

Present:

- `qemu-system-aarch64`
- `aosp/build/envsetup.sh`
- `device/teravolt/arm64/teravolt_arm64.mk`
- `device/teravolt/arm64/BoardConfig.mk`
- `vendor/teravolt/teravolt_vendor.mk`
- Launcher and Settings source files
- Host simulator: `scripts/simulate-teravolt.sh`
- QEMU preflight: `scripts/qemu-preflight.sh`

Missing:

- `aosp/frameworks`
- `aosp/packages`
- `aosp/prebuilts`
- `aosp/out/target/product/<product>/system.img`
- `aosp/out/target/product/<product>/ramdisk.img`
- `aosp/out/target/product/<product>/kernel-qemu2` or `boot.img`
- Built Launcher and Settings APKs

## Build Instructions

Complete source sync:

```bash
cd /home/vishal/aosp/aosp
repo sync -c -j4 --fail-fast
```

Build a QEMU-capable Android target after sync:

```bash
cd /home/vishal/aosp/aosp
source build/envsetup.sh
lunch sdk_phone_arm64-trunk_staging-eng
m -j$(nproc)
```

The exact lunch target depends on the synced AOSP branch.

## Test Instructions

Run host simulation now:

```bash
cd /home/vishal/aosp
./scripts/simulate-teravolt.sh industrial
```

Check QEMU readiness:

```bash
cd /home/vishal/aosp
./scripts/qemu-preflight.sh
```

Boot QEMU only after preflight passes:

```bash
./scripts/qemu-setup.sh boot
```

## Git Commit Message

```text
Correct QEMU readiness documentation
```
