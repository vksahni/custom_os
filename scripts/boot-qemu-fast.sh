#!/bin/bash
#
# Fast QEMU Emulator Boot Script for TeraVolt OS
# Alternative: Use Android Emulator if available
#

PROJECT_ROOT="/home/vishal/aosp"
LAUNCHER_APK="$PROJECT_ROOT/launcher/build/outputs/apk/debug/launcher-debug.apk"
SETTINGS_APK="$PROJECT_ROOT/settings/build/outputs/apk/debug/settings-debug.apk"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}===================================="
echo "  TeraVolt OS - QEMU Boot Tool"
echo "====================================${NC}"
echo ""

# Check if Android emulator is available
if command -v emulator &> /dev/null; then
    echo -e "${GREEN}✓ Android Emulator found${NC}"
    
    # Try to find available AVDs
    AVDS=$(emulator -list-avds 2>/dev/null | head -1)
    
    if [ -z "$AVDS" ]; then
        echo -e "${YELLOW}No AVDs found. Android Emulator available but no virtual devices.${NC}"
    else
        echo -e "${GREEN}Available AVD: $AVDS${NC}"
        
        read -p "Boot Android Emulator? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Launching Android Emulator with $AVDS..."
            
            # Launch emulator
            emulator -avd "$AVDS" -no-snapshot-load &
            
            # Wait for emulator to boot
            echo "Waiting for emulator to boot (30 seconds)..."
            sleep 30
            
            # Wait for adb
            echo "Waiting for ADB connection..."
            for i in {1..30}; do
                if adb devices | grep -q "emulator-"; then
                    echo -e "${GREEN}✓ ADB connected${NC}"
                    break
                fi
                sleep 1
            done
            
            # Install APKs
            echo ""
            echo -e "${BLUE}Installing apps...${NC}"
            
            if [ -f "$LAUNCHER_APK" ]; then
                echo "Installing Launcher..."
                adb install -r "$LAUNCHER_APK"
            fi
            
            if [ -f "$SETTINGS_APK" ]; then
                echo "Installing Settings..."
                adb install -r "$SETTINGS_APK"
            fi
            
            # Set launcher as default
            echo ""
            echo "Setting Launcher as default home app..."
            adb shell am set-default-home com.teravolt.launcher/.MainActivity 2>/dev/null || \
                adb shell cmd package set-home-activity com.teravolt.launcher/.MainActivity
            
            # Launch app
            echo ""
            echo -e "${GREEN}Launching TeraVolt Launcher...${NC}"
            adb shell am start -n com.teravolt.launcher/.MainActivity
            
            echo ""
            echo -e "${GREEN}✓ Emulator running with TeraVolt apps!${NC}"
            echo "Use 'adb' commands to interact with the emulator."
            echo "Kill emulator with: killall emulator"
            
            exit 0
        fi
    fi
fi

# If we get here, use QEMU
echo ""
echo -e "${BLUE}Preparing QEMU ARM64 Boot...${NC}"
echo ""

if [ -x "$PROJECT_ROOT/scripts/qemu-preflight.sh" ]; then
    "$PROJECT_ROOT/scripts/qemu-preflight.sh" || exit 1
fi

AOSP_ROOT="$PROJECT_ROOT/aosp"
BUILD_OUT="$AOSP_ROOT/out"

# Find system image
SYSTEM_IMG=""
if [ -f "$BUILD_OUT/target/product/generic_arm64/system.img" ]; then
    SYSTEM_IMG="$BUILD_OUT/target/product/generic_arm64/system.img"
elif [ -f "$BUILD_OUT/target/product/qemu_arm64/system.img" ]; then
    SYSTEM_IMG="$BUILD_OUT/target/product/qemu_arm64/system.img"
else
    echo -e "${YELLOW}System image not found in:${NC}"
    echo "  $BUILD_OUT/target/product/generic_arm64/system.img"
    echo "  $BUILD_OUT/target/product/qemu_arm64/system.img"
    echo ""
    echo "Please run: cd $PROJECT_ROOT && ./scripts/qemu-setup.sh build"
    exit 1
fi

echo -e "${GREEN}✓ Found system image: $SYSTEM_IMG${NC}"
echo ""

# Check QEMU
if ! command -v qemu-system-aarch64 &> /dev/null; then
    echo -e "${YELLOW}QEMU ARM64 not found. Install with:${NC}"
    echo "  sudo apt-get install qemu-system-arm"
    exit 1
fi

QEMU_VERSION=$(qemu-system-aarch64 --version | head -1)
echo -e "${GREEN}✓ QEMU found: $QEMU_VERSION${NC}"
echo ""

# Prepare QEMU command
echo -e "${BLUE}QEMU Configuration:${NC}"
echo "  Machine: virt"
echo "  CPU: cortex-a57"
echo "  Memory: 2048 MB"
echo "  Cores: 4"
echo "  Networking: User mode (NAT)"
echo ""

# Check for KVM support
if [ -e "/dev/kvm" ] && [ -r "/dev/kvm" ]; then
    echo -e "${GREEN}✓ KVM acceleration available${NC}"
    KVM_FLAG="-enable-kvm"
else
    echo -e "${YELLOW}⚠ KVM not available, using software emulation (slower)${NC}"
    KVM_FLAG=""
fi

echo ""
echo -e "${BLUE}Starting QEMU...${NC}"
echo "(Press Ctrl+A then C for QEMU console, Ctrl+C to exit)"
echo ""

# Boot QEMU
qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -m 2048 \
    -smp 4 \
    -nographic \
    -serial mon:stdio \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0 \
    $KVM_FLAG

echo ""
echo -e "${BLUE}QEMU terminated${NC}"
echo ""

# Cleanup
echo "Cleaning up..."
if adb devices | grep -q "emulator-\|localhost"; then
    echo "Disconnecting ADB..."
    adb disconnect
fi

echo -e "${GREEN}Done${NC}"
