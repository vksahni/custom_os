# TeraVolt Settings

## Architecture Diagram

```text
Settings UI
  ├─ Device information
  ├─ Serial configuration
  ├─ CAN configuration
  ├─ MQTT configuration
  ├─ Network tools
  ├─ AI settings
  └─ OTA settings
```

## Folder Structure

```text
settings/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for the TeraVolt Settings implementation. Configuration writes must go through privileged platform services or DeviceConfig/sysprops with explicit SELinux policy.

## Build Instructions

Integrate the final app under `vendor/teravolt/packages/apps/TeraVoltSettings` and add it to `PRODUCT_PACKAGES`.

## Test Instructions

- Verify each settings page handles missing hardware gracefully.
- Verify configuration changes persist after reboot.
- Verify unauthorized apps cannot call privileged settings APIs.

## Git Commit Message

```text
Add TeraVolt Settings workspace
```
