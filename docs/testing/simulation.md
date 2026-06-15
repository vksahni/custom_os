# TeraVolt OS Host Simulation

## Architecture Diagram

```text
Host simulator
  ├─ validates repository structure
  ├─ reads product/vendor integration anchors
  ├─ simulates bootloader, kernel, init, servicemanager
  ├─ starts mocked TeraVolt services
  ├─ reports simulated Android properties
  └─ reports simulated hardware interfaces
```

## Folder Structure

```text
scripts/
└── simulate-teravolt.sh

docs/testing/
└── simulation.md
```

## Complete Source Code

The simulator source is [simulate-teravolt.sh](/home/vishal/aosp/scripts/simulate-teravolt.sh).

It is intentionally host-only. It does not boot Android, run ART, emulate a kernel, or launch QEMU. It gives us a fast control-plane check while the actual AOSP tree, kernel, and board configuration are still being added.

## Build Instructions

No build is required.

## Test Instructions

Run the default reference simulation:

```bash
./scripts/simulate-teravolt.sh
```

Run a stricter production-like profile:

```bash
./scripts/simulate-teravolt.sh industrial
```

Expected final line:

```text
Simulation result: boot-complete
```

## QEMU Full-System Preflight

QEMU needs bootable Android artifacts. Before attempting a full-system boot, run:

```bash
./scripts/qemu-preflight.sh
```

The minimum required artifacts are:

- `aosp/out/target/product/<product>/system.img`
- `aosp/out/target/product/<product>/ramdisk.img`
- `aosp/out/target/product/<product>/kernel-qemu2` or `boot.img`

If those files are missing, use the host simulator above and complete the AOSP sync/build before trying QEMU.

## Git Commit Message

```text
Add host-side TeraVolt OS simulation
```
