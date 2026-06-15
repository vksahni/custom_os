# TeraVolt OS Architecture Overview

## Architecture Diagram

```text
Applications
  ├─ TeraVolt Launcher
  ├─ TeraVolt Settings
  └─ Domain Apps
        │
        ▼
Privileged Platform Services
  ├─ MQTT Manager
  ├─ DroneCAN Manager
  ├─ Serial Manager
  ├─ AI Inference Manager
  ├─ Device Monitor
  └─ OTA Manager
        │ Binder / AIDL / permissions
        ▼
Android Framework + Native HAL Boundary
  ├─ SystemServer integration
  ├─ SELinux domains and neverallow-safe policy
  ├─ Init services and sysprops
  └─ Vendor HALs and native daemons
        │
        ▼
Linux Kernel + Hardware
  ├─ CAN / UART / RS485 / GPIO / I2C / SPI / Ethernet
  ├─ Device tree overlays
  ├─ Kernel modules
  └─ Board boot chain
```

## Component Boundaries

TeraVolt OS keeps user-facing apps separate from privileged hardware services. Apps call stable Binder APIs. Services own hardware access and enforce permissions. Native daemons are used only where direct kernel or realtime-ish I/O behavior is required.

## Platform Integration Model

1. `device/teravolt/<board>` defines the Android product, partitions, properties, init files, kernel command line, and board-specific packages.
2. `vendor/teravolt` contains privileged packages, overlays, permissions, SELinux policy, and service allowlists.
3. `services/` contains platform service source before it is imported into `vendor/teravolt/packages/services`.
4. `launcher/` and `settings/` are built as privileged or system apps depending on the board profile.
5. `ota/` owns update signing policy, package verification, rollback requirements, and update client behavior.

## Security Model

TeraVolt OS defaults to least privilege:

- SELinux enforcing on production builds.
- Privileged permissions are explicitly allowlisted.
- Device services expose Binder APIs instead of raw device node access.
- OTA packages are signed and verified before install.
- Rollback protection is required for production boards with supported bootloaders.
- Debug transports are disabled in production product variants unless a device owner policy enables them.

## Runtime Profiles

```text
teravolt_arm64-userdebug
  Development ARM64 reference profile.

teravolt_rpi4-userdebug
  Raspberry Pi bring-up profile once board support is added.

teravolt_industrial-user
  Production profile with locked debugging, signed OTA, enforcing SELinux,
  restricted apps, and hardware service policy.
```
