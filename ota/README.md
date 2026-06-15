# TeraVolt OTA

## Architecture Diagram

```text
Update Server
  └─ Signed metadata
       └─ OTA client
            ├─ Product check
            ├─ Signature check
            ├─ Rollback check
            └─ Android update_engine
```

## Folder Structure

```text
ota/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for update metadata policy, signing procedures, client integration, and rollback validation.

## Build Instructions

Use Android `ota_from_target_files` after target files are produced by the platform build.

## Test Instructions

- Reject unsigned packages.
- Reject older rollback indexes.
- Verify successful A/B update where supported.

## Git Commit Message

```text
Add TeraVolt OTA workspace
```
