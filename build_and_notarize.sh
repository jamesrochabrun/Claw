#!/bin/bash

# Build, sign, notarize and create Sparkle update using Fastlane
# This is a convenience wrapper around fastlane create_and_sign_release
set -e

echo "🔨 Building and notarizing Claw using Fastlane..."
echo ""
echo "This script will:"
echo "  1. Build and sign the app"
echo "  2. Notarize with Apple"
echo "  3. Create Sparkle update ZIP"
echo "  4. Sign update with Sparkle EdDSA signature"
echo "  5. Update appcast.xml"
echo "  6. Create DMG for distribution"
echo ""

# Check if bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "❌ Error: Bundler not found. Install it with: gem install bundler"
    exit 1
fi

# Check if gems are installed
if [ ! -f "Gemfile.lock" ]; then
    echo "📦 Installing Ruby gems..."
    bundle install
fi

# Ensure required secrets are set
if [ -z "${SPARKLE_SECRET_KEY}" ]; then
    echo "⚠️  SPARKLE_SECRET_KEY not set. Checking keychain..."
    # Fastlane will attempt to load from keychain
fi

# Run fastlane lane
echo "🚀 Running fastlane create_and_sign_release..."
cd fastlane
bundle exec fastlane create_and_sign_release
cd ..

echo ""
echo "✅ Build complete!"
echo ""
echo "Next steps:"
echo "  1. Test the app in build/release/Claw.app"
echo "  2. Create a GitHub release with:"
echo "     - build/release/Claw.dmg (manual distribution)"
echo "     - build/release/Claw.app.zip (Sparkle updates)"
echo "  3. Commit and push the updated appcast.xml"
echo ""