#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
DMG_STAGING="$BUILD_DIR/dmg"
DMG_OUTPUT="$BUILD_DIR/TinyMD.dmg"

echo "==> Generating Xcode project..."
cd "$PROJECT_DIR"
xcodegen generate

echo "==> Building Release..."
xcodebuild -project TinyMD.xcodeproj -scheme TinyMD -configuration Release build

# Find the built app
APP_PATH=$(xcodebuild -project TinyMD.xcodeproj -scheme TinyMD -configuration Release -showBuildSettings 2>/dev/null | grep " BUILT_PRODUCTS_DIR" | awk '{print $3}')
APP_PATH="$APP_PATH/TinyMD.app"

echo "==> Packaging DMG..."
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

rm -f "$DMG_OUTPUT"
hdiutil create -volname "TinyMD" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_OUTPUT"

rm -rf "$DMG_STAGING"

echo ""
echo "==> Done! DMG created at:"
echo "    $DMG_OUTPUT"
echo "    Size: $(du -h "$DMG_OUTPUT" | cut -f1)"
