# TeraVolt AI

## Architecture Diagram

```text
Camera / Sensor Input
  └─ Preprocessing
       └─ Runtime Adapter
            ├─ TensorFlow Lite
            └─ ONNX Runtime
                 └─ Detection Results API
```

## Folder Structure

```text
ai/
├── README.md
└── docs/
```

## Complete Source Code

This workspace is reserved for edge inference models, runtime adapters, benchmark tools, and service integration.

## Build Instructions

Package runtime libraries per ABI and expose inference through the AI Inference Service rather than direct app access.

## Test Instructions

- Run model load tests.
- Run CPU and accelerator inference benchmarks.
- Verify memory limits on low-RAM devices.

## Git Commit Message

```text
Add TeraVolt AI workspace
```
