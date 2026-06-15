# TeraVolt MQTT

## Architecture Diagram

```text
Apps
  └─ MQTT Service Binder API
       └─ MQTT Client
            └─ Broker / TLS / device identity
```

## Folder Structure

```text
mqtt/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for MQTT schemas, client policy, broker configuration examples, and service integration.

## Build Instructions

MQTT client code should be packaged inside the MQTT Service, not exposed as duplicated app code.

## Test Instructions

- Verify TLS broker connection.
- Verify reconnect behavior.
- Verify credentials are stored through Android keystore-backed storage.

## Git Commit Message

```text
Add TeraVolt MQTT workspace
```
