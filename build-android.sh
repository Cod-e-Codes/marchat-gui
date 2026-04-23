#!/bin/bash
# build-android.sh - Build Android APK for marchat GUI using Fyne
set -e

APP_NAME="marchat-gui"
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_FILE="$SCRIPT_DIR/assets/marchat-transparent.png"
APP_ID="com.codecodes.marchat"
REQUIRED_GO="1.23"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_go() {
    if ! command -v go >/dev/null 2>&1; then
        print_error "Go not found. Please install Go $REQUIRED_GO or later."
    fi

    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if [[ "$(printf '%s\n' "$REQUIRED_GO" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_GO" ]]; then
        print_error "Go $REQUIRED_GO or later is required. Found $GO_VERSION"
    fi
    print_status "Go version $GO_VERSION detected"
}

check_fyne() {
    if ! command -v fyne >/dev/null 2>&1; then
        print_status "Fyne CLI not found. Installing..."
        go install fyne.io/fyne/v2/cmd/fyne@latest
    fi
}

check_android_sdk() {
    if [ -z "$ANDROID_HOME" ]; then
        if [ -d "$HOME/Android/Sdk" ]; then
            export ANDROID_HOME="$HOME/Android/Sdk"
        else
            print_error "ANDROID_HOME not set and no Android SDK found at ~/Android/Sdk"
        fi
    fi
    export PATH="$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

    if ! command -v sdkmanager >/dev/null 2>&1; then
        print_error "sdkmanager not found in ANDROID_HOME. Please install Android SDK tools."
    fi

    # Install latest stable NDK (r28c)
    if ! command -v ndk-build >/dev/null 2>&1; then
        print_status "Installing NDK r28c..."
        yes | sdkmanager --install "ndk;28.2.13676358"
        export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/28.2.13676358"
    fi
}

build_apk() {
    print_status "Building Android APK..."
    cd "$SCRIPT_DIR"

    if [ -f "$ICON_FILE" ]; then
        fyne package -os android -icon "$ICON_FILE" -name "$APP_NAME" -app-id "$APP_ID" -release -version "$VERSION"
    else
        fyne package -os android -name "$APP_NAME" -app-id "$APP_ID" -release -version "$VERSION"
    fi

    print_status "APK built successfully!"
    ls -lh *.apk
}

### MAIN ###
print_status "Checking environment..."
check_go
check_fyne
check_android_sdk

build_apk
