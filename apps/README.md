# TeraVolt Apps

## Architecture Diagram

```text
System Apps
  ├─ Launcher
  ├─ Settings
  └─ Domain-specific applications
```

## Folder Structure

```text
apps/
├── README.md
└── docs/
```

## Complete Source Code

Additional production applications belong here during development and move into `vendor/teravolt/packages/apps` for platform builds.

## Build Instructions

Add platform-integrated apps to `PRODUCT_PACKAGES` once their manifests, permissions, and SELinux interactions are reviewed.

## Test Instructions

- Verify install location and signing certificate.
- Verify no privileged permission is requested without an allowlist entry.

## Git Commit Message

```text
Add TeraVolt apps workspace
```
