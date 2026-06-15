# TeraVolt OS Security Model

## Architecture Diagram

```text
Signed Boot Chain
  └─ Verified Boot / rollback index
       └─ Android partitions
            ├─ SELinux enforcing
            ├─ Privileged permission allowlists
            ├─ App sandboxing
            ├─ Hardware service Binder APIs
            └─ Signed OTA verification
```

## Requirements

- Production images must use `user` variants.
- SELinux must be enforcing before field deployment.
- Privileged permissions must be declared in XML allowlists.
- Direct access to `/dev/tty*`, CAN interfaces, GPIO, and other hardware nodes must be confined to approved services.
- OTA metadata must include version, target product, rollback index, payload hash, and signing certificate identity.
- Secrets must not be stored in the source tree.

## Test Instructions

```bash
adb shell getenforce
adb shell dmesg | grep -i avc
adb shell cmd package list packages -f | grep teravolt
adb shell dumpsys package com.teravolt.settings
```

## Git Commit Message

```text
Add initial TeraVolt OS security model
```
