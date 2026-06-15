# TeraVolt Services

## Architecture Diagram

```text
Apps
  │ Binder / permissions
  ▼
TeraVolt Services
  ├─ MQTT Service
  ├─ DroneCAN Service
  ├─ Serial Port Service
  ├─ AI Inference Service
  ├─ Device Monitoring Service
  └─ OTA Update Service
       │
       ▼
Native daemons / HAL / kernel interfaces
```

## Folder Structure

```text
services/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for platform services. Stable APIs should be specified in AIDL before implementation. Hardware-facing logic must be isolated from app-facing Binder permissions.

## Build Instructions

Import service modules under `vendor/teravolt/packages/services` or the appropriate AOSP framework location after API ownership is finalized.

## Test Instructions

- Verify service startup order from init/SystemServer.
- Verify permission enforcement through Binder calls.
- Verify hardware errors do not crash SystemServer.

## Git Commit Message

```text
Add TeraVolt Services workspace
```
