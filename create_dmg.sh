#!/bin/bash

# Olive DMG Creator Script
# This script creates a DMG installer for the Olive app

APP_NAME="Olive"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"
SOURCE_DIR="./build"
DMG_DIR="./dist"

echo "🔨 Creating DMG for ${APP_NAME} v${VERSION}..."

# Create directories if they don't exist
mkdir -p "${DMG_DIR}"
mkdir -p "${SOURCE_DIR}"

echo "📦 Step 1: Build the app in Xcode first"
echo "   - Open Olive.xcodeproj in Xcode"
echo "   - Select Product > Archive"
echo "   - Export the archive as 'Copy App'"
echo "   - Place the exported Olive.app in the ./build directory"
echo ""
read -p "Press Enter when you've placed Olive.app in ./build directory..."

# Check if app exists
if [ ! -d "${SOURCE_DIR}/${APP_NAME}.app" ]; then
    echo "❌ Error: ${APP_NAME}.app not found in ${SOURCE_DIR} directory"
    echo "Please build the app first and place it in the build directory."
    exit 1
fi

# Remove old DMG if it exists
if [ -f "${DMG_DIR}/${DMG_NAME}" ]; then
    echo "🗑️  Removing old DMG..."
    rm "${DMG_DIR}/${DMG_NAME}"
fi

# Create temporary DMG directory
TEMP_DMG_DIR="/tmp/${APP_NAME}_dmg"
rm -rf "${TEMP_DMG_DIR}"
mkdir -p "${TEMP_DMG_DIR}"

# Copy app to temp directory
echo "📋 Copying app to temp directory..."
cp -R "${SOURCE_DIR}/${APP_NAME}.app" "${TEMP_DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${TEMP_DMG_DIR}/Applications"

# Create DMG
echo "💿 Creating DMG..."
hdiutil create -volname "${VOLUME_NAME}" \
    -srcfolder "${TEMP_DMG_DIR}" \
    -ov -format UDZO \
    "${DMG_DIR}/${DMG_NAME}"

# Clean up
echo "🧹 Cleaning up..."
rm -rf "${TEMP_DMG_DIR}"

# Verify DMG was created
if [ -f "${DMG_DIR}/${DMG_NAME}" ]; then
    echo "✅ DMG created successfully: ${DMG_DIR}/${DMG_NAME}"
    echo "📊 Size: $(du -h "${DMG_DIR}/${DMG_NAME}" | cut -f1)"
    echo ""
    echo "📤 You can now upload ${DMG_NAME} to GitHub Releases"
else
    echo "❌ Error: DMG creation failed"
    exit 1
fi