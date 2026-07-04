#!/bin/bash
# Usage: Scripts/build-app.sh [--keep-cache]
#   --keep-cache   Skip deleting .build/ after a successful build, for faster incremental rebuilds.
#                   Omit it (the default) to remove the compiler cache once the app is packaged.
set -euo pipefail

cd "$(dirname "$0")/.."

KEEP_CACHE=false
if [[ "${1:-}" == "--keep-cache" ]]; then
    KEEP_CACHE=true
fi

APP_NAME="FXConvert"
BUILD_CONFIG="release"

swift build -c "$BUILD_CONFIG"

APP_BUNDLE="$APP_NAME.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp ".build/$BUILD_CONFIG/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

touch "$APP_BUNDLE"

echo "Built $APP_BUNDLE"

if [[ "$KEEP_CACHE" == false ]]; then
    rm -rf .build
    echo "Removed .build (pass --keep-cache to keep it for faster rebuilds)"
fi
