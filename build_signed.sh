#!/bin/bash

# Build and sign Claw app for distribution (without notarization for now)
set -e

APP_NAME="Claw"
SCHEME="Claw"
TEAM_ID="YOUR_TEAM_ID"
IDENTITY="Developer ID Application: James Rochabrun (YOUR_TEAM_ID)"

echo "🔨 Building ${APP_NAME} for distribution..."

# Check Xcode path
XCODE_PATH=$(xcode-select -p)
if [[ "$XCODE_PATH" == *"CommandLineTools"* ]]; then
  echo "⚠️  Warning: xcode-select is pointing to Command Line Tools"
  echo "Please run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

# Clean and build
rm -rf build/
xcodebuild clean -scheme "${SCHEME}"
xcodebuild archive \
  -scheme "${SCHEME}" \
  -archivePath "build/${APP_NAME}.xcarchive" \
  -configuration Release \
  DEVELOPMENT_TEAM="${TEAM_ID}" \
  CODE_SIGN_STYLE=Automatic

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

# Verify signing
echo "🔍 Verifying code signature..."
codesign -vvv --deep --strict "${APP_PATH}"

echo "✅ App built and signed successfully"
echo "App ready at: ${APP_PATH}"
echo ""
echo "Next steps for notarization:"
echo "1. Store credentials: xcrun notarytool store-credentials --team-id ${TEAM_ID}"
echo "2. Create ZIP: ditto -c -k --keepParent '${APP_PATH}' 'build/${APP_NAME}.zip'"
echo "3. Submit: xcrun notarytool submit 'build/${APP_NAME}.zip' --team-id ${TEAM_ID} --wait"
echo "4. Staple: xcrun stapler staple '${APP_PATH}'"