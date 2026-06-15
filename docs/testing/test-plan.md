# TeraVolt OS Test Plan

## Architecture Diagram

```text
Host Validation
  ├─ script syntax
  ├─ tree layout
  └─ build target selection

Device Validation
  ├─ boot and init
  ├─ display and input
  ├─ networking
  ├─ serial/CAN interfaces
  ├─ privileged services
  ├─ AI inference smoke tests
  └─ OTA verification
```

## Host Tests

```bash
./scripts/validate-tree.sh
bash -n scripts/*.sh
./scripts/simulate-teravolt.sh
./scripts/simulate-teravolt.sh industrial
```

## Device Smoke Tests

```bash
adb wait-for-device
adb shell getprop ro.product.name
adb shell getprop ro.teravolt.os.name
adb shell getenforce
adb shell ip addr
adb shell service list | grep -i teravolt
```

## Hardware Tests

- UART loopback test.
- RS485 transmit/receive test.
- CAN interface bring-up with `ip link set can0 up type can bitrate 500000`.
- DroneCAN node discovery.
- MQTT broker connectivity test.
- Thermal and power telemetry check.

## OTA Tests

- Reject unsigned package.
- Reject package for different product.
- Reject rollback version.
- Accept signed update with matching product and newer rollback index.

## Git Commit Message

```text
Add initial TeraVolt OS validation plan
```
