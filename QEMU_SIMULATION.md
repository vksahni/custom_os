# TeraVolt OS QEMU Simulation Guide

## Overview

This guide helps you prepare TeraVolt OS for a QEMU ARM64 emulator. A full QEMU boot requires built Android images; a bare `qemu-system-aarch64` invocation is not enough to boot Android.

## Prerequisites

```bash
# Verify requirements
- QEMU ARM64: qemu-system-aarch64 ✓
- Android Build System: aosp/build/envsetup.sh
- Java/Gradle: for building APKs ✓
- Git and Repo: for source management ✓
```

## Quick Start Options

### Option 1: Preflight + Full Build + QEMU Boot

```bash
cd /home/vishal/aosp
./scripts/qemu-preflight.sh

# If preflight reports missing AOSP sources, complete sync first:
cd /home/vishal/aosp/aosp
repo sync -c -j4 --fail-fast

# Build after sync:
cd /home/vishal/aosp
./scripts/qemu-setup.sh build

# Then boot QEMU only after preflight passes:
./scripts/qemu-setup.sh boot
```

**Time Estimate:** 1-2 hours (includes AOSP sync and build)

### Option 2: Skip Build, Use Emulator FastBoot

If you want to test the apps faster without a full AOSP build:

```bash
# Use Android emulator directly (if available)
emulator -avd arm64-v8a -no-snapshot-load &

# Then install APKs
adb install -r launcher/build/outputs/apk/debug/launcher-debug.apk
adb install -r settings/build/outputs/apk/debug/settings-debug.apk

# Set launcher as home app
adb shell am start com.teravolt.launcher/.MainActivity
```

### Option 3: Manual QEMU Boot with Custom Images

```bash
# Boot QEMU only after system.img, ramdisk.img, and kernel-qemu2 exist.
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -m 2048 \
    -smp 4 \
    -nographic \
    -serial mon:stdio \
    -kernel aosp/out/target/product/<product>/kernel-qemu2 \
    -initrd aosp/out/target/product/<product>/ramdisk.img \
    -drive if=none,id=system,format=raw,readonly=on,file=aosp/out/target/product/<product>/system.img \
    -device virtio-blk-device,drive=system \
    -drive if=none,id=userdata,format=raw,file=aosp/out/target/product/<product>/userdata.img \
    -device virtio-blk-device,drive=userdata \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0
```

## QEMU Setup Details

### System Requirements

| Resource | Requirement |
|----------|-------------|
| Disk Space | 50-100GB (AOSP build) |
| RAM | 4-8GB recommended |
| CPU Cores | 4+ (parallel build) |
| Network | For AOSP sync |
| Bandwidth | 5-10GB for AOSP |

**Your System:** 
- Disk: 398GB available ✓
- CPU: 16 cores ✓
- RAM: 8GB+ (check with `free -h`)

### QEMU Boot Parameters Explained

```bash
qemu-system-aarch64                    # ARM64 emulator
  -machine virt                         # Virtual machine type
  -cpu cortex-a57                       # ARM Cortex-A57 processor
  -m 2048                               # 2GB RAM
  -smp 4                                # 4 virtual CPUs
  -nographic                            # No GUI, serial console only
  -serial mon:stdio                     # Serial console to terminal
  -netdev user,id=net0                  # User-mode networking
  -device virtio-net-device,netdev=net0 # Virtio network device
```

### Expected QEMU Output

When booting, you should see:

```
Linux version 6.x.x-android (root@teravolt)...
[    0.000000] Booting paravirtualized kernel on QEMU
[    0.000000] tsc: Detected X MHz processor
...
[   10.000000] boot_complete
```

Then the Android boot loader, kernel, and finally the launcher app.

## Building AOSP for QEMU

### Step 1: Initialize Environment

```bash
cd /home/vishal/aosp/aosp
source build/envsetup.sh
```

### Step 2: Select Target

```bash
# List available targets
lunch

# Select one of these for QEMU:
# - generic_arm64-eng (generic ARM64 engineering build)
# - qemu_arm64-eng (QEMU-optimized ARM64)
# - generic_arm64-user (production build)
```

### Step 3: Build System

```bash
# Full build (20-40 minutes)
m -j$(nproc)

# Or specific target
m systemimage -j$(nproc)

# Or incremental (after first build)
m -j$(nproc)
```

### Step 4: Verify Build Output

```bash
ls -la out/target/product/generic_arm64/
# Expected files:
# - system.img (system partition)
# - userdata.img (data partition)
# - ramdisk.img (RAM disk)
# - kernel-qemu2 or boot.img (kernel)
# - dtb (device tree)
```

## Installing Launcher + Settings Apps

### Method 1: Via ADB (Recommended)

```bash
# Ensure QEMU is booted and adb is connected
adb devices

# Install Launcher
adb install -r launcher/build/outputs/apk/debug/launcher-debug.apk

# Install Settings
adb install -r settings/build/outputs/apk/debug/settings-debug.apk

# Set Launcher as default home app
adb shell pm set-home-activity com.teravolt.launcher/.MainActivity

# Or through UI: Settings > Apps > Default apps > Home app
```

### Method 2: Via System Build Integration

Build apps into system image:

```bash
# In AOSP build directory
cd aosp

# Add to build target's .mk file
echo "PRODUCT_PACKAGES += TeraVoltLauncher TeraVoltSettings" >> \
    build/target/product/generic_arm64.mk

# Rebuild
m -j$(nproc)
```

## Interacting with QEMU Console

### Basic Console Commands

```bash
# After boot, type these at the console:

# List installed packages
pm list packages | grep teravolt

# Set Launcher as home app
am set-default-home com.teravolt.launcher/.MainActivity

# Launch Launcher
am start com.teravolt.launcher/.MainActivity

# Launch Settings
am start com.teravolt.settings/.SettingsActivity

# Check logcat output
logcat | grep teravolt

# View system logs
dumpsys

# Reboot
reboot
```

### Ctrl+C to Exit QEMU

Press **Ctrl+A** then **C** to access QEMU console, or **Ctrl+C** to terminate.

## Troubleshooting

### Issue: "System.img not found"

**Solution:**
```bash
# Build is incomplete. Run full build:
cd aosp
source build/envsetup.sh
lunch generic_arm64-eng
m -j$(nproc)
```

### Issue: QEMU won't boot

**Solution:**
```bash
# Try with fewer CPUs
qemu-system-aarch64 -machine virt -cpu cortex-a57 -m 2048 -smp 2 -nographic

# Check if images are valid
file out/target/product/generic_arm64/system.img
```

### Issue: "Cannot connect to QEMU via adb"

**Solution:**
```bash
# Enable network in QEMU boot
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -m 2048 \
    -smp 4 \
    -nographic \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0 \
    -serial mon:stdio

# Then connect adb
adb connect localhost:5037
```

### Issue: APK install fails

**Solution:**
```bash
# Check app permissions
adb shell pm list permissions | grep teravolt

# Grant permissions manually
adb shell pm grant com.teravolt.launcher android.permission.INTERNET

# Uninstall first if updating
adb uninstall com.teravolt.launcher
adb install launcher/build/outputs/apk/debug/launcher-debug.apk
```

## Performance Tips

### Optimize QEMU Speed

```bash
# Enable KVM (if available)
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -enable-kvm \
    ...

# Reduce RAM for faster boot
-m 1024  # 1GB instead of 2GB

# Reduce CPUs for faster boot
-smp 2   # 2 CPUs instead of 4
```

### Speed up Build

```bash
# Parallel build with all cores
m -j$(nproc)

# Incremental build (after first)
m -j$(nproc) TARGET_PRODUCT=generic_arm64
```

## Testing the Apps

### Launcher App Testing

```bash
# Launch app
adb shell am start -n com.teravolt.launcher/.MainActivity

# Navigate tabs (tap on tab icons)
# - Dashboard: Check system metrics display
# - Device Info: Verify device data
# - Quick Controls: Test button interactions

# Check logs
adb logcat | grep LauncherViewModel
```

### Settings App Testing

```bash
# Launch app
adb shell am start -n com.teravolt.settings/.SettingsActivity

# Test preference categories:
# 1. Device Information (view-only)
# 2. Serial Configuration (toggle, baud rate)
# 3. CAN Configuration (toggle, bitrate)
# 4. MQTT Configuration (toggle, broker address, port)
# 5. AI Configuration (toggle, model selection)
# 6. OTA Configuration (auto-check toggle, check button)
# 7. Network Tools

# Verify preferences are saved
adb shell pm get-config-app com.teravolt.settings
```

## Next Steps After Testing

1. **Service Integration**
   - Connect to TeraVolt Binder services
   - Replace mock data with real service calls

2. **Widget Support**
   - Implement dashboard widget provider
   - Add home screen widgets

3. **Production Build**
   - Build release APKs (signed)
   - Integrate into full AOSP build system

4. **Device Testing**
   - Build for actual ARM64 device
   - Test on real hardware

## References

- [QEMU ARM64 Documentation](https://wiki.qemu.org/Documentation)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
- [AOSP Build Guide](https://source.android.com/docs/setup/build/building)
- [AOSP for QEMU](https://android.googlesource.com/platform/build/+/refs/heads/main/target/board/generic_arm64)

## Additional Resources

### AOSP Repos in Use

- `platform/system/core` - Android core system
- `platform/frameworks/base` - Android framework
- `device/generic` - Generic device configurations
- Your custom `device/teravolt` - TeraVolt-specific board configs

### Build Artifacts

After successful build:

```
out/target/product/generic_arm64/
├── system.img          # System partition
├── userdata.img        # User data partition
├── ramdisk.img         # Initial RAM disk
├── boot.img            # Boot image
├── kernel-qemu2        # QEMU kernel
└── ...
```

### Useful Commands Reference

```bash
# Environment
export PATH="$HOME/bin:$PATH"
source build/envsetup.sh

# Building
m                  # Build all
m systemimage      # Build system only
m -j$(nproc)      # Parallel build

# Testing
adb install -r <apk>
adb shell am start <package>/.Activity
adb logcat

# QEMU
qemu-system-aarch64 [options]
```

---

**Quick Start Command:**
```bash
cd /home/vishal/aosp
./scripts/qemu-setup.sh setup && ./scripts/qemu-setup.sh boot
```

**Expected Time:** 1-2 hours for full build
**APK Size:** ~2-5 MB each (Launcher, Settings)
**System Image Size:** ~1-2 GB
