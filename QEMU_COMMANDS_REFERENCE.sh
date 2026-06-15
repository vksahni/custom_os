#!/bin/bash
#
# QEMU Simulation - Quick Reference
# TeraVolt OS Boot and Test Commands
#

cat << 'COMMANDS'
╔════════════════════════════════════════════════════════════════════════════╗
║                     TeraVolt OS QEMU Simulation                           ║
║                         Quick Command Reference                           ║
╚════════════════════════════════════════════════════════════════════════════╝

┌─ BOOT QEMU ──────────────────────────────────────────────────────────────┐
│                                                                           │
│ Fastest (with existing build):                                          │
│   cd /home/vishal/aosp                                                  │
│   ./scripts/boot-qemu-fast.sh                                           │
│                                                                           │
│ Full Setup (build + boot):                                              │
│   cd /home/vishal/aosp                                                  │
│   ./scripts/qemu-setup.sh setup    # AOSP build                         │
│   ./scripts/qemu-setup.sh boot     # Start QEMU                         │
│                                                                           │
│ Manual QEMU (if images exist):                                          │
│   qemu-system-aarch64 \                                                 │
│     -machine virt \                                                      │
│     -cpu cortex-a57 \                                                    │
│     -m 2048 \                                                            │
│     -smp 4 \                                                             │
│     -nographic \                                                         │
│     -serial mon:stdio \                                                  │
│     -netdev user,id=net0 \                                               │
│     -device virtio-net-device,netdev=net0 \                             │
│     -enable-kvm                                                          │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ BUILD APPS ──────────────────────────────────────────────────────────────┐
│                                                                           │
│ Build Launcher APK:                                                      │
│   cd /home/vishal/aosp/launcher                                         │
│   ./gradlew assembleDebug                                               │
│   # Output: build/outputs/apk/debug/launcher-debug.apk                  │
│                                                                           │
│ Build Settings APK:                                                      │
│   cd /home/vishal/aosp/settings                                         │
│   ./gradlew assembleDebug                                               │
│   # Output: build/outputs/apk/debug/settings-debug.apk                  │
│                                                                           │
│ Build Both:                                                              │
│   cd /home/vishal/aosp                                                  │
│   (cd launcher && ./gradlew assembleDebug) && \                          │
│   (cd settings && ./gradlew assembleDebug)                              │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ ADB COMMANDS ────────────────────────────────────────────────────────────┐
│                                                                           │
│ Device Management:                                                       │
│   adb devices                  # List connected devices                 │
│   adb connect localhost:5037   # Connect to emulator                    │
│   adb disconnect               # Disconnect device                      │
│                                                                           │
│ App Installation:                                                        │
│   adb install -r launcher/build/outputs/apk/debug/launcher-debug.apk   │
│   adb install -r settings/build/outputs/apk/debug/settings-debug.apk   │
│   adb uninstall com.teravolt.launcher                                   │
│   adb uninstall com.teravolt.settings                                   │
│                                                                           │
│ Package Management:                                                      │
│   adb shell pm list packages              # List all packages           │
│   adb shell pm list packages | grep teravolt  # Filter TeraVolt        │
│   adb shell pm path com.teravolt.launcher # Get app path                │
│                                                                           │
│ Activity Launch:                                                         │
│   adb shell am start -n com.teravolt.launcher/.MainActivity            │
│   adb shell am start -n com.teravolt.settings/.SettingsActivity        │
│   adb shell am start -a android.intent.action.MAIN                     │
│                                                                           │
│ Debugging:                                                               │
│   adb logcat                            # View all logs                  │
│   adb logcat | grep teravolt            # Filter TeraVolt logs          │
│   adb logcat | grep com.teravolt        # Alternative filter             │
│   adb shell                             # Shell access                  │
│   adb shell getprop                     # System properties              │
│                                                                           │
│ File Transfer:                                                           │
│   adb push local_file /data/local/tmp/  # Push to device                │
│   adb pull /data/local/tmp/file local/  # Pull from device              │
│                                                                           │
│ Permissions:                                                             │
│   adb shell pm list permissions                # All permissions        │
│   adb shell pm grant <package> <permission>    # Grant permission       │
│   adb shell pm revoke <package> <permission>   # Revoke permission      │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ QEMU CONSOLE COMMANDS ───────────────────────────────────────────────────┐
│                                                                           │
│ In QEMU Terminal (during execution):                                    │
│                                                                           │
│   Ctrl+A C     → Enter QEMU monitor                                      │
│   quit         → Exit QEMU                                               │
│   reboot       → Reboot system                                           │
│   info version → QEMU version info                                       │
│   info block   → Block device info                                       │
│   help         → QEMU help                                               │
│                                                                           │
│   Ctrl+C       → Exit QEMU (from Linux prompt)                           │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ AOSP BUILD COMMANDS ─────────────────────────────────────────────────────┐
│                                                                           │
│ Setup Environment:                                                       │
│   cd /home/vishal/aosp/aosp                                             │
│   source build/envsetup.sh                                              │
│                                                                           │
│ Select Build Target:                                                     │
│   lunch generic_arm64-eng        # Engineering build for QEMU           │
│   lunch generic_arm64-userdebug  # Debug build                          │
│                                                                           │
│ Build:                                                                   │
│   m                               # Build all                            │
│   m -j$(nproc)                   # Build with all CPU cores             │
│   m systemimage                  # Build system partition only           │
│   m -j4                          # Build with 4 parallel jobs            │
│                                                                           │
│ Sync AOSP Repositories:                                                  │
│   repo sync -c -j4 --fail-fast   # Resume sync with 4 jobs             │
│   repo sync -c -j1 --fail-fast   # Resume sync with 1 job (slow)       │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ MONITORING ──────────────────────────────────────────────────────────────┐
│                                                                           │
│ Check AOSP Sync Progress:                                                │
│   ps aux | grep "repo sync"     # Check if sync is running              │
│   du -sh /home/vishal/aosp/aosp # Total download size                   │
│   ls -lh /home/vishal/aosp/aosp/.repo/project-objects | wc -l # Count  │
│                                                                           │
│ Check Disk Space:                                                        │
│   df -h /home/vishal/aosp       # Available space                        │
│   du -sh /home/vishal/aosp/*    # Directory sizes                        │
│                                                                           │
│ Check System Resources:                                                  │
│   free -h                        # RAM usage                             │
│   nproc                          # CPU count                             │
│   top -b -n 1 | head -20        # CPU/process stats                     │
│                                                                           │
│ QEMU Process Info:                                                       │
│   ps aux | grep qemu             # QEMU process                          │
│   pgrep -a qemu                  # QEMU info                             │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─ TROUBLESHOOTING ─────────────────────────────────────────────────────────┐
│                                                                           │
│ QEMU won't start:                                                        │
│   qemu-system-aarch64 --help | grep machine  # Check machine types     │
│   qemu-system-aarch64 --version             # Check QEMU version        │
│                                                                           │
│ Apps won't install:                                                      │
│   adb uninstall com.teravolt.launcher       # Uninstall first           │
│   adb install -r launcher/build/outputs/apk/debug/launcher-debug.apk   │
│                                                                           │
│ adb connection lost:                                                     │
│   adb kill-server                           # Kill daemon               │
│   adb start-server                          # Restart daemon            │
│   adb connect localhost:5037                # Reconnect                 │
│                                                                           │
│ Build fails:                                                             │
│   m clean                                   # Clean build               │
│   m -j1                                    # Single-threaded build      │
│   source build/envsetup.sh                  # Reset environment         │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

╔════════════════════════════════════════════════════════════════════════════╗
║                      QUICK START (Copy & Paste)                           ║
╚════════════════════════════════════════════════════════════════════════════╝

1. Boot QEMU (when AOSP build is ready):
   cd /home/vishal/aosp && ./scripts/boot-qemu-fast.sh

2. In another terminal, install and test apps:
   adb install -r /home/vishal/aosp/launcher/build/outputs/apk/debug/launcher-debug.apk
   adb install -r /home/vishal/aosp/settings/build/outputs/apk/debug/settings-debug.apk
   adb shell am start -n com.teravolt.launcher/.MainActivity

3. View logs:
   adb logcat | grep -i teravolt

COMMANDS
