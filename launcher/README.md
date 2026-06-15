# TeraVolt Launcher

## Architecture Diagram

```text
Launcher Activity
  ├─ Industrial dashboard
  ├─ Widget host
  ├─ Device monitor panels
  ├─ Quick controls
  └─ Binder clients for TeraVolt services
```

## Folder Structure

```text
launcher/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for the launcher implementation. The first production implementation should be an Android app module using Kotlin or Java, Jetpack-compatible UI where allowed by the target branch, and privileged service clients hidden behind repository interfaces.

## Build Instructions

Integrate the final app under `vendor/teravolt/packages/apps/TeraVoltLauncher` and add it to `PRODUCT_PACKAGES`.

## Test Instructions

- Verify it is the default home activity.
- Verify dashboard panels remain responsive when hardware services are unavailable.
- Verify widget binding permissions.

## Git Commit Message

```text
Add TeraVolt Launcher workspace
```
