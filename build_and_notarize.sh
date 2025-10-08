#!/bin/bash

# Build, sign, and notarize Claw app for distribution
set -e

APP_NAME="Claw"
SCHEME="Claw"
BUNDLE_ID="jamesRochabrun.Claw"
TEAM_ID="CQ45U4X9K3"
IDENTITY="Developer ID Application: James Rochabrun (CQ45U4X9K3)"
VERSION="1.0.2"

echo "🔨 Building ${APP_NAME} for distribution..."

# Clean and build
rm -rf build/
xcodebuild clean -scheme "${SCHEME}"
xcodebuild archive \
  -scheme "${SCHEME}" \
  -archivePath "build/${APP_NAME}.xcarchive" \
  CODE_SIGN_IDENTITY="${IDENTITY}" \
  DEVELOPMENT_TEAM="${TEAM_ID}"

# Export the archive
xcodebuild -exportArchive \
  -archivePath "build/${APP_NAME}.xcarchive" \
  -exportPath "build/" \
  -exportOptionsPlist ExportOptions.plist

APP_PATH="build/${APP_NAME}.app"

if [ ! -d "${APP_PATH}" ]; then
  echo "❌ Error: App not found at ${APP_PATH}"
  exit 1
fi

echo "✅ App built and signed successfully"

# Create a ZIP for notarization
echo "📦 Creating ZIP for notarization..."
ditto -c -k --keepParent "${APP_PATH}" "build/${APP_NAME}.zip"

# Notarize
echo "📤 Submitting for notarization..."
xcrun notarytool submit "build/${APP_NAME}.zip" \
  --team-id "${TEAM_ID}" \
  --wait

# Staple the notarization ticket
echo "📎 Stapling notarization ticket..."
xcrun stapler staple "${APP_PATH}"

echo "✅ App notarized successfully!"
echo "App ready at: ${APP_PATH}"