# TeraVolt DroneCAN

## Architecture Diagram

```text
CAN Interface
  └─ DroneCAN Adapter
       └─ DroneCAN Service Binder API
            └─ Apps and automation logic
```

## Folder Structure

```text
dronecan/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for DroneCAN protocol adapters, node discovery, message definitions, and service integration.

## Build Instructions

Native DroneCAN components should be built as vendor modules and accessed through the DroneCAN Service.

## Test Instructions

- Bring up CAN interface.
- Discover DroneCAN nodes.
- Validate message publish/subscribe behavior.

## Git Commit Message

```text
Add TeraVolt DroneCAN workspace
```
