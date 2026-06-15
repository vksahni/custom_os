# TeraVolt OS

TeraVolt OS is an Android-based embedded operating system built from the Android Open Source Project (AOSP). It is designed for industrial automation, IoT devices, drone ground stations, smart agriculture, Raspberry Pi and ARM platforms, and AI edge computing.

The goal of TeraVolt OS is to provide a secure, lightweight, modular, and production-ready Android platform for embedded and industrial use cases. It combines the Android runtime and application ecosystem with hardware-focused platform services for serial communication, CAN Bus, DroneCAN, MQTT, device monitoring, OTA updates, and edge AI inference.

This repository is the orchestration layer around AOSP. It keeps upstream Android source under `aosp/`, board and product definitions under `device/`, partner/vendor integration under `vendor/`, and independently testable application/service modules in top-level workspaces before they are wired into the platform build.

## Architecture Diagram

```text
┌────────────────────────────────────────────────────────────────────┐
│                          TeraVolt OS                                │
├────────────────────────────────────────────────────────────────────┤
│ User Experience                                                     │
│  ├─ TeraVolt Launcher: industrial dashboard, widgets, controls       │
│  └─ TeraVolt Settings: serial, CAN, MQTT, AI, OTA, network tools     │
├────────────────────────────────────────────────────────────────────┤
│ System Services                                                     │
│  ├─ MQTT Service        ├─ DroneCAN Service     ├─ OTA Service       │
│  ├─ Serial Port Service ├─ AI Inference Service └─ Device Monitor    │
├────────────────────────────────────────────────────────────────────┤
│ Android Platform                                                    │
│  ├─ AOSP Frameworks / ART / Binder / HAL / SELinux                  │
│  ├─ TeraVolt product makefiles and Soong namespaces                  │
│  └─ Privileged apps, permissions, overlays, init rc, sysprops        │
├────────────────────────────────────────────────────────────────────┤
│ Hardware Integration                                                │
│  ├─ Linux kernel, DTB/DTBO, vendor boot, modules                     │
│  ├─ UART / RS485 / Modbus / CAN / DroneCAN / Ethernet                │
│  └─ STM32 / ESP32 / Arduino / Raspberry Pi expansion interfaces      │
└────────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```text
teravolt-os/
├── aosp/                 # Synced Android Open Source Project tree
├── kernel/               # Kernel manifests, configs, patches, modules
├── device/teravolt/      # Android product and board definitions
├── vendor/teravolt/      # Vendor packages, overlays, privapp permissions
├── launcher/             # TeraVolt Launcher source workspace
├── settings/             # TeraVolt Settings source workspace
├── services/             # Platform service source workspace
├── ota/                  # OTA tooling and update policy
├── ai/                   # Edge inference models and runtime integration
├── mqtt/                 # MQTT integration notes and client components
├── dronecan/             # DroneCAN integration notes and adapters
├── apps/                 # Additional system/user applications
├── docs/                 # Architecture, bring-up, security, testing
├── scripts/              # Host automation for sync, build, validation
└── tests/                # Host and device test procedures
```

## Build Instructions

1. Install host prerequisites:

   ```bash
   sudo apt-get update
   sudo apt-get install -y git-core gnupg flex bison build-essential zip curl \
     zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev \
     libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig python3
   ```

2. Install Google's `repo` launcher somewhere in `PATH`.

3. Sync AOSP:

   ```bash
   ./scripts/sync-aosp.sh
   ```

4. Add or update board-specific kernel/device files under `kernel/` and `device/teravolt/`.

5. Build a target product:

   ```bash
   ./scripts/build-aosp.sh teravolt_arm64-userdebug
   ```

The initial product files are scaffolding. A bootable image requires a real BoardConfig, kernel artifacts, bootloader flow, partition layout, and device tree for the chosen board.

## Test Instructions

```bash
./scripts/validate-tree.sh
bash -n scripts/*.sh
./scripts/simulate-teravolt.sh
```

After a target boots, run the staged procedures in `docs/testing/test-plan.md`.

## Git Commit Message

```text
Initialize TeraVolt OS AOSP orchestration scaffold
```
