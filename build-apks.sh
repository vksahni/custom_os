#!/bin/bash
#
# Quick APK Build Script
# Builds Launcher and Settings APKs without requiring full Gradle installation
#

set -e

PROJECT_ROOT="/home/vishal/aosp"
LAUNCHER_DIR="$PROJECT_ROOT/launcher"
SETTINGS_DIR="$PROJECT_ROOT/settings"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}TeraVolt OS APK Builder${NC}"
echo "=================================="
echo ""

# Check if gradle is available
if command -v gradle &> /dev/null; then
    GRADLE_CMD="gradle"
elif [ -f "$PROJECT_ROOT/launcher/gradlew" ]; then
    GRADLE_CMD="$LAUNCHER_DIR/gradlew"
else
    echo -e "${YELLOW}Gradle not found. Installing Gradle wrapper...${NC}"
    
    # Download gradle wrapper
    GRADLE_VERSION="8.4"
    GRADLE_WRAPPER_JAR="$PROJECT_ROOT/gradle/wrapper/gradle-wrapper.jar"
    
    mkdir -p "$PROJECT_ROOT/gradle/wrapper"
    
    if command -v wget &> /dev/null; then
        wget -q -O "$GRADLE_WRAPPER_JAR" \
            "https://github.com/gradle/gradle/releases/download/v${GRADLE_VERSION}/gradle-${GRADLE_VERSION}-wrapper-sources.jar"
    fi
    
    GRADLE_CMD="gradle"
fi

# Build Launcher
echo -e "${BLUE}Building Launcher APK...${NC}"
cd "$LAUNCHER_DIR"

if [ -f "gradlew" ]; then
    ./gradlew clean assembleDebug
else
    $GRADLE_CMD clean assembleDebug
fi

LAUNCHER_APK="$LAUNCHER_DIR/build/outputs/apk/debug/launcher-debug.apk"
if [ -f "$LAUNCHER_APK" ]; then
    echo -e "${GREEN}✓ Launcher APK built: $LAUNCHER_APK${NC}"
    ls -lh "$LAUNCHER_APK"
else
    echo -e "${YELLOW}Note: APK not at expected location. Checking build directory...${NC}"
    find "$LAUNCHER_DIR/build" -name "*.apk" 2>/dev/null || echo "No APK found"
fi

echo ""

# Build Settings
echo -e "${BLUE}Building Settings APK...${NC}"
cd "$SETTINGS_DIR"

if [ -f "gradlew" ]; then
    ./gradlew clean assembleDebug
else
    $GRADLE_CMD clean assembleDebug
fi

SETTINGS_APK="$SETTINGS_DIR/build/outputs/apk/debug/settings-debug.apk"
if [ -f "$SETTINGS_APK" ]; then
    echo -e "${GREEN}✓ Settings APK built: $SETTINGS_APK${NC}"
    ls -lh "$SETTINGS_APK"
else
    echo -e "${YELLOW}Note: APK not at expected location. Checking build directory...${NC}"
    find "$SETTINGS_DIR/build" -name "*.apk" 2>/dev/null || echo "No APK found"
fi

echo ""
echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo "To install on device:"
echo "  adb install -r \"$LAUNCHER_APK\""
echo "  adb install -r \"$SETTINGS_APK\""
