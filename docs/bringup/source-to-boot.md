# Source Synchronization to Bootable Image

## Architecture Diagram

```text
Host Workstation
  ├─ scripts/sync-aosp.sh
  │    └─ aosp/ upstream source checkout
  ├─ device/teravolt/<board>
  │    └─ product makefiles, BoardConfig, init, fstab
  ├─ kernel/
  │    └─ kernel source, defconfig, DTB/DTBO, modules
  ├─ vendor/teravolt/
  │    └─ packages, overlays, privapp permissions, SELinux
  └─ scripts/build-aosp.sh
       └─ out/target/product/<board>/*.img
```

## Bring-Up Stages

1. Sync a known Android platform branch.
2. Define a reference product under `device/teravolt`.
3. Add board-specific kernel and boot image requirements.
4. Add vendor overlays and privileged app allowlists.
5. Boot `userdebug` with permissive-only temporary policy during early hardware enablement.
6. Convert all policy to enforcing before production.
7. Add OTA signing and rollback validation.
8. Add CTS/VTS/GTS-equivalent internal gates where applicable.

## Minimum Board Inputs

- CPU architecture and ABI list.
- Bootloader requirements.
- Kernel image format and load addresses.
- Device tree and overlay strategy.
- Partition layout.
- Verified Boot capabilities.
- Display, input, network, storage, and serial console paths.
- CAN/UART/RS485 adapters and kernel driver names.

## Build Instructions

```bash
./scripts/sync-aosp.sh
./scripts/build-aosp.sh teravolt_arm64-userdebug
```

## Test Instructions

1. Confirm `out/target/product/<board>/system.img` exists.
2. Flash or boot according to board vendor instructions.
3. Capture serial console from first boot.
4. Verify `adb shell getprop ro.teravolt.os.name`.
5. Verify SELinux state with `adb shell getenforce`.
6. Run smoke tests from `docs/testing/test-plan.md`.

## Git Commit Message

```text
Document TeraVolt OS source sync and board bring-up flow
```
