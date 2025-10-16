#!/bin/bash

# Generate Sparkle EdDSA signing keys
# Run this script ONCE to generate your signing keys

echo "🔐 Generating Sparkle EdDSA signing keys..."
echo ""
echo "⚠️  IMPORTANT SECURITY NOTES:"
echo "  - The PRIVATE key must NEVER be committed to git"
echo "  - Store the private key securely (password manager, GitHub Secrets)"
echo "  - The PUBLIC key goes in your Info.plist (safe to commit)"
echo ""

# Find Sparkle's generate_keys tool
SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData -name "generate_keys" -type f 2>/dev/null | head -n 1)

if [ -z "${SPARKLE_BIN}" ]; then
  echo "❌ Error: Sparkle generate_keys tool not found"
  echo ""
  echo "To fix this:"
  echo "1. Add Sparkle via Swift Package Manager in Xcode:"
  echo "   https://github.com/sparkle-project/Sparkle"
  echo "2. Build the project at least once"
  echo "3. Run this script again"
  exit 1
fi

# Generate keys
echo "Running: ${SPARKLE_BIN}"
"${SPARKLE_BIN}"

echo ""
echo "✅ Keys generated!"
echo ""
echo "📋 Next steps:"
echo "1. Copy the PUBLIC KEY (starts with SUPublicEDKey) to your Info.plist"
echo "2. Store the PRIVATE KEY securely:"
echo "   - Local: Save to .sparkle_private_key file (already in .gitignore)"
echo "   - CI/CD: Add as GitHub Secret named SPARKLE_PRIVATE_KEY"
echo "3. NEVER commit the private key to git!"
echo ""
echo "💡 To save private key locally:"
echo "   echo 'YOUR_PRIVATE_KEY_HERE' > .sparkle_private_key"
echo ""
echo "💡 To use in build script:"
echo "   export SPARKLE_PRIVATE_KEY=\$(cat .sparkle_private_key)"
echo "   ./build_and_notarize.sh"
