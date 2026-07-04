#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

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
