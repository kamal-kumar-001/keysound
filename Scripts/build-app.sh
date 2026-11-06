#!/bin/bash

set -e

APP_NAME="KeySound"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
SHAREABLE_DMG="$PWD/$APP_NAME.dmg"

echo "=== Building $APP_NAME ==="

killall KeySound 2>/dev/null || true

mkdir -p "$BUILD_DIR"
mkdir -p .build/module-cache

DEVELOPER_DIR_PATH="$(xcode-select -p 2>/dev/null || true)"

if [[ "$DEVELOPER_DIR_PATH" == */Xcode.app/Contents/Developer ]]; then
    echo "Compiling via swift build..."
    swift build -c release
    cp ".build/release/$APP_NAME" "$BUILD_DIR/$APP_NAME"
else
    echo "Compiling via swiftc with Command Line Tools..."
    swiftc \
        -module-cache-path .build/module-cache \
        Sources/KeySound/*.swift \
        Sources/KeySound/Models/*.swift \
        Sources/KeySound/Services/*.swift \
        Sources/KeySound/Views/*.swift \
        -O \
        -o "$BUILD_DIR/$APP_NAME" \
        -framework AppKit \
        -framework SwiftUI \
        -framework ApplicationServices \
        -framework Carbon \
        -framework AVFoundation \
        -framework AudioToolbox
fi

echo "Creating app bundle..."

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Generate App Icon
ICONSET_DIR=".build/KeySound.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

echo "Generating app icon..."
swiftc \
    -module-cache-path .build/module-cache \
    Scripts/create-app-icon.swift \
    -o .build/create-app-icon \
    -framework AppKit \
    -framework ImageIO

.build/create-app-icon "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/KeySound.icns"

cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>KeySound</string>
    <key>CFBundleExecutable</key>
    <string>KeySound</string>
    <key>CFBundleIdentifier</key>
    <string>com.kamal.KeySound</string>
    <key>CFBundleName</key>
    <string>KeySound</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>KeySound</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 KeySound</string>
</dict>
</plist>
EOF

echo "✓ Build complete: $APP_DIR"

if command -v hdiutil >/dev/null 2>&1; then
    DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
    DMG_STAGE=".build/dmg-stage"
    rm -rf "$DMG_STAGE" "$DMG_PATH" "$SHAREABLE_DMG"
    mkdir -p "$DMG_STAGE"
    cp -R "$APP_DIR" "$DMG_STAGE/"
    cp "$APP_DIR/Contents/Resources/KeySound.icns" "$DMG_STAGE/.VolumeIcon.icns"
    ln -s /Applications "$DMG_STAGE/Applications"
    echo "Creating shareable DMG..."
    hdiutil create \
        -volname "$APP_NAME" \
        -srcfolder "$DMG_STAGE" \
        -ov \
        -format UDZO \
        "$DMG_PATH" >/dev/null

    cp "$DMG_PATH" "$SHAREABLE_DMG"
    echo "✓ DMG created: $SHAREABLE_DMG"
fi
