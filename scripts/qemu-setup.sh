#!/usr/bin/env bash
#
# TeraVolt OS QEMU Setup and Boot Script
# Builds Android images and boots on QEMU ARM64 emulator
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AOSP_ROOT="$PROJECT_ROOT/aosp"
BUILD_OUT="$AOSP_ROOT/out"
LAUNCHER_APK="$PROJECT_ROOT/launcher/build/outputs/apk/debug/launcher-debug.apk"
SETTINGS_APK="$PROJECT_ROOT/settings/build/outputs/apk/debug/settings-debug.apk"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check requirements
check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v qemu-system-aarch64 &> /dev/null; then
        print_error "QEMU ARM64 not found. Install with: sudo apt-get install qemu-system-arm"
        exit 1
    fi
    print_success "QEMU ARM64 found"
    
    if ! command -v java &> /dev/null; then
        print_error "Java not found. Install with: sudo apt-get install default-jdk"
        exit 1
    fi
    print_success "Java found"
    
    if [ ! -d "$AOSP_ROOT" ]; then
        print_error "AOSP root not found at $AOSP_ROOT"
        exit 1
    fi
    print_success "AOSP root found"
}

# Initialize AOSP environment
init_aosp_env() {
    print_info "Initializing AOSP build environment..."
    cd "$AOSP_ROOT"
    
    # Source the build environment
    if [ ! -f "build/envsetup.sh" ]; then
        print_error "build/envsetup.sh not found"
        exit 1
    fi
    
    source build/envsetup.sh > /dev/null 2>&1
    print_success "AOSP environment initialized"
}

# Complete AOSP sync
sync_aosp() {
    print_info "Checking AOSP sync status..."
    cd "$AOSP_ROOT"
    
    # Try to resume sync
    export PATH="$HOME/bin:$PATH"
    print_info "Resuming repository sync (this may take 30-60 minutes)..."
    repo sync -c -j4 --fail-fast || {
        print_warning "Sync encountered issues. Retrying with single job..."
        repo sync -c -j1 --fail-fast || print_warning "Some repos may not have synced. Continuing with available code..."
    }
    
    print_success "AOSP sync complete (or at least attempted)"
}

# Build AOSP for QEMU
build_aosp_for_qemu() {
    print_info "Building AOSP for QEMU ARM64..."
    cd "$AOSP_ROOT"
    
    # Initialize build environment if not already done
    source build/envsetup.sh > /dev/null 2>&1 || true
    
    # Select build target (use generic ARM64 QEMU target)
    print_info "Building generic ARM64 image for QEMU..."
    
    # Use lunch command to select target
    lunch generic_arm64-eng || {
        print_warning "generic_arm64-eng not available, trying qemu_arm64..."
        lunch qemu_arm64-eng || {
            print_warning "Specific QEMU target not available, listing available targets..."
            lunch --list | head -20
            print_error "Please select a valid QEMU target manually"
            return 1
        }
    }
    
    # Build the system image
    print_info "Building system image (this may take 20-40 minutes on first build)..."
    m -j$(nproc) || {
        print_error "Build failed. Check the output above for errors."
        return 1
    }
    
    print_success "AOSP build complete"
}

# Check if APKs are built
check_apks() {
    print_info "Checking if Launcher and Settings APKs are built..."
    
    if [ ! -f "$LAUNCHER_APK" ]; then
        print_warning "Launcher APK not found at $LAUNCHER_APK"
        print_info "Building Launcher APK..."
        cd "$PROJECT_ROOT/launcher"
        ./gradlew assembleDebug || print_error "Launcher build failed"
    else
        print_success "Launcher APK found"
    fi
    
    if [ ! -f "$SETTINGS_APK" ]; then
        print_warning "Settings APK not found at $SETTINGS_APK"
        print_info "Building Settings APK..."
        cd "$PROJECT_ROOT/settings"
        ./gradlew assembleDebug || print_error "Settings build failed"
    else
        print_success "Settings APK found"
    fi
}

# Boot QEMU with Android
boot_qemu() {
    print_info "Preparing QEMU boot..."

    "$PROJECT_ROOT/scripts/qemu-preflight.sh"
    
    # Check if build artifacts exist
    if [ ! -f "$BUILD_OUT/target/product/generic_arm64/system.img" ] && \
       [ ! -f "$BUILD_OUT/target/product/qemu_arm64/system.img" ]; then
        print_error "System image not found. Need to build AOSP first."
        return 1
    fi
    
    # Find the correct build product directory
    PRODUCT_DIR=""
    if [ -d "$BUILD_OUT/target/product/generic_arm64" ]; then
        PRODUCT_DIR="$BUILD_OUT/target/product/generic_arm64"
    elif [ -d "$BUILD_OUT/target/product/qemu_arm64" ]; then
        PRODUCT_DIR="$BUILD_OUT/target/product/qemu_arm64"
    else
        print_error "No suitable product build directory found"
        ls "$BUILD_OUT/target/product/" 2>/dev/null || true
        return 1
    fi
    
    print_success "Using product directory: $PRODUCT_DIR"

    KVM_FLAG=""
    if [ -e "/dev/kvm" ] && [ -r "/dev/kvm" ]; then
        KVM_FLAG="-enable-kvm"
    else
        print_warning "KVM is not available; QEMU will use slower software emulation"
    fi
    
    # QEMU parameters for ARM64 Android
    print_info "Booting QEMU ARM64 with Android..."
    
    qemu-system-aarch64 \
        -machine virt \
        -cpu cortex-a57 \
        -smp 4 \
        -m 2048 \
        -kernel "$PRODUCT_DIR/kernel-qemu2" \
        -initrd "$PRODUCT_DIR/ramdisk.img" \
        -append "console=ttyAMA0 androidboot.hardware=goldfish androidboot.serialno=TERAVOLTQEMU" \
        -drive if=none,id=system,format=raw,readonly=on,file="$PRODUCT_DIR/system.img" \
        -device virtio-blk-device,drive=system \
        -drive if=none,id=userdata,format=raw,file="$PRODUCT_DIR/userdata.img" \
        -device virtio-blk-device,drive=userdata \
        -nographic \
        -serial mon:stdio \
        -netdev user,id=net0 \
        -device virtio-net-device,netdev=net0 \
        $KVM_FLAG
}

# Boot QEMU (alternative method using simple parameters)
boot_qemu_simple() {
    print_warning "Simple QEMU boot is disabled because it cannot boot Android without kernel and image artifacts."
    boot_qemu
}

# Print menu
print_menu() {
    echo ""
    echo "===================================="
    echo "  TeraVolt OS QEMU Simulation Menu"
    echo "===================================="
    echo "1. Check requirements"
    echo "2. Complete AOSP sync"
    echo "3. Build AOSP for QEMU"
    echo "4. Build Launcher and Settings APKs"
    echo "5. Full setup and boot (steps 1-3)"
    echo "6. Boot QEMU with existing build"
    echo "7. Install APKs to running QEMU"
    echo "0. Exit"
    echo "===================================="
}

# Main execution
main() {
    print_info "TeraVolt OS QEMU Simulation Setup"
    print_info "Project Root: $PROJECT_ROOT"
    print_info "AOSP Root: $AOSP_ROOT"
    echo ""
    
    if [ $# -eq 0 ]; then
        # Interactive menu
        while true; do
            print_menu
            read -p "Enter your choice [0-7]: " choice
            
            case $choice in
                1)
                    check_requirements
                    ;;
                2)
                    init_aosp_env
                    sync_aosp
                    ;;
                3)
                    init_aosp_env
                    build_aosp_for_qemu
                    ;;
                4)
                    check_apks
                    ;;
                5)
                    check_requirements
                    init_aosp_env
                    sync_aosp
                    build_aosp_for_qemu
                    check_apks
                    print_success "Build complete! Run 'boot' to start QEMU."
                    ;;
                6)
                    boot_qemu_simple
                    ;;
                7)
                    print_info "To install APKs, use: adb install -r <apk-path>"
                    echo "Launcher: adb install -r $LAUNCHER_APK"
                    echo "Settings: adb install -r $SETTINGS_APK"
                    ;;
                0)
                    print_info "Exiting"
                    exit 0
                    ;;
                *)
                    print_error "Invalid choice"
                    ;;
            esac
        done
    else
        # Command line argument
        case $1 in
            check)
                check_requirements
                ;;
            sync)
                init_aosp_env
                sync_aosp
                ;;
            build)
                init_aosp_env
                build_aosp_for_qemu
                ;;
            apks)
                check_apks
                ;;
            setup)
                check_requirements
                init_aosp_env
                sync_aosp
                build_aosp_for_qemu
                check_apks
                ;;
            boot)
                boot_qemu
                ;;
            *)
                print_error "Unknown command: $1"
                echo "Usage: $0 [check|sync|build|apks|setup|boot]"
                exit 1
                ;;
        esac
    fi
}

main "$@"
