# Claw Release Guide

Complete guide for creating and distributing Claw releases with automatic updates.

## Table of Contents

- [Prerequisites](#prerequisites)
- [One-Time Setup](#one-time-setup)
- [Creating a Release](#creating-a-release)
- [Manual Release Process](#manual-release-process)
- [Automated Release Process](#automated-release-process)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- Xcode 15+ with Command Line Tools
- Ruby 3.3.0+ (installed via rbenv or system)
- Bundler gem: `gem install bundler`
- create-dmg: `brew install create-dmg`
- Developer ID Application certificate (from Apple Developer Program)

### Required Accounts & Access

- Apple Developer Program membership
- GitHub account with repo access
- Notarization credentials (App Store Connect API key)

## One-Time Setup

### 1. Install Ruby Dependencies

```bash
# Install bundler if not already installed
gem install bundler

# Install fastlane and dependencies
bundle install
```

### 2. Generate Sparkle Signing Keys

```bash
# Build project first to download Sparkle
xcodebuild -scheme Claw -configuration Release

# Generate EdDSA key pair
./generate_sparkle_keys.sh
```

This outputs:
```
SUPublicEDKey: abc123... (PUBLIC - add to Info.plist)
Private key: xyz789... (PRIVATE - keep secret!)
```

### 3. Configure Info.plist

Add these keys to `Claw/Info.plist`:

```xml
<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY_FROM_STEP_2</string>

<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml</string>
```

Or via Xcode project settings → Info tab.

### 4. Store Secrets Securely

#### Local Development (Keychain)

Fastlane will automatically store secrets in your Mac keychain. On first use:

```bash
# Set secrets as environment variables, fastlane will save to keychain
export SPARKLE_SECRET_KEY="your_private_key_from_step_2"
export MATCH_PASSWORD="your_match_password"
export FASTLANE_GITHUB_ACCESS_TOKEN="ghp_your_github_token"
export GH_WRITE_TOKEN="ghp_your_github_token"
export NOTARY_KEY_ID="your_app_store_connect_key_id"
export NOTARY_ISSUER_ID="your_app_store_connect_issuer_id"
export NOTARY_P8="-----BEGIN PRIVATE KEY-----
...your p8 key content...
-----END PRIVATE KEY-----"

# Run fastlane once to save to keychain
cd fastlane && bundle exec fastlane create_and_sign_release
```

After the first run, secrets are stored in keychain and loaded automatically.

#### GitHub Actions (CI/CD)

Add these secrets in GitHub repo settings → Secrets and variables → Actions:

- `SPARKLE_SECRET_KEY`
- `MATCH_PASSWORD`
- `FASTLANE_GITHUB_ACCESS_TOKEN`
- `GH_WRITE_TOKEN`
- `NOTARY_KEY_ID`
- `NOTARY_ISSUER_ID`
- `NOTARY_P8`

### 5. Set Up Fastlane Match (Code Signing)

Create a private GitHub repository for certificates:

```bash
# Create repo: https://github.com/jamesrochabrun/claw-provisioning-profiles (private)

# Initialize Match (first time only)
cd fastlane
bundle exec fastlane match developer_id --readonly false
```

This will:
1. Ask for the Match password (create a strong password)
2. Generate Developer ID certificates
3. Store them in the private repo
4. Install certificates on your Mac

Store the Match password securely (password manager or GitHub Secrets).

### 6. Link Claw.xcconfig to Xcode Project

1. Open `Claw.xcodeproj` in Xcode
2. Select the project root
3. Select the **Claw** target
4. Go to **Build Settings** tab
5. Search for "configuration"
6. Under **User-Defined**, add `#include "Claw.xcconfig"`

Or use Xcode's GUI:
1. Project settings → Info tab → Configurations
2. Set `Claw.xcconfig` for both Debug and Release

## Creating a Release

### Quick Release (Automated)

For the fully automated release process with PR creation:

```bash
# This will:
# - Bump version if needed (avoid conflicts)
# - Build, sign, notarize
# - Create Sparkle update
# - Upload to GitHub Releases
# - Create PR with appcast update
cd fastlane
bundle exec fastlane distribute_release
```

### Manual Release Steps

For more control over the release process:

#### 1. Update Version

Edit `Claw.xcconfig`:

```
APP_VERSION = 1.0.1  # Increment this
```

#### 2. Build and Sign

```bash
# Option A: Using convenience script
./build_and_notarize.sh

# Option B: Using fastlane directly
cd fastlane
bundle exec fastlane create_and_sign_release
```

This creates:
- `build/release/Claw.app` - Notarized app
- `build/release/Claw.dmg` - Installer for manual distribution
- `build/release/Claw.app.zip` - Sparkle update package
- `appcast.xml` - Updated with new version and signature

#### 3. Test the Build

```bash
# Test the notarized app
open build/release/Claw.app

# Verify signature
codesign --verify --deep --strict build/release/Claw.app
spctl -a -t exec -vv build/release/Claw.app
```

#### 4. Create GitHub Release

```bash
# Using GitHub CLI
gh release create v1.0.1 \
  --title "Release v1.0.1" \
  --notes "Release notes here" \
  build/release/Claw.dmg \
  build/release/Claw.app.zip

# Or manually via GitHub web UI:
# 1. Go to https://github.com/jamesrochabrun/Claw/releases/new
# 2. Tag: v1.0.1
# 3. Title: Release v1.0.1
# 4. Upload: Claw.dmg and Claw.app.zip
# 5. Publish release
```

#### 5. Commit and Push Appcast

```bash
# Commit the updated appcast
git add appcast.xml Claw.xcconfig
git commit -m "Release v1.0.1"
git push origin main
```

The appcast **must** be in the `main` branch for users to receive updates!

## Automated Release Process

The `distribute_release` lane fully automates releases:

### What It Does

1. **Version Management**
   - Reads current version from `Claw.xcconfig`
   - Checks for conflicts (existing tags, branches, releases)
   - Auto-increments version if conflicts found
   - Updates `Claw.xcconfig` with final version

2. **Build & Sign**
   - Fetches code signing certificates via Match
   - Builds Release configuration
   - Strips debug symbols (reduces size ~40%)
   - Code signs with Developer ID
   - Notarizes with Apple

3. **Sparkle Update**
   - Creates ZIP with proper resource fork handling
   - Signs with EdDSA private key
   - Updates `appcast.xml` with:
     - Version number
     - File size
     - EdDSA signature
     - Publication date

4. **Distribution**
   - Creates DMG for manual downloads
   - Uploads both DMG and ZIP to GitHub Releases
   - Creates PR with version bump and appcast update
   - PR base: `main`, head: `release-v1.0.X`

### Running Automated Release

```bash
cd fastlane
bundle exec fastlane distribute_release
```

This will:
- Output: Version being released (may auto-increment)
- Build and sign the app
- Upload to GitHub
- Print PR URL for review

Then:
1. Review and merge the PR
2. Users will receive update automatically

## Manual Release Process

For more granular control:

### Build Only

```bash
cd fastlane
bundle exec fastlane build_release
```

Creates unsigned app in `build/release/Claw.app`.

### Build and Sign (No Distribution)

```bash
cd fastlane
bundle exec fastlane create_and_sign_release
```

Creates:
- Signed app
- DMG
- Sparkle ZIP
- Updated appcast.xml

You handle GitHub release and PR manually.

## Release Checklist

Before each release:

- [ ] Version incremented in `Claw.xcconfig`
- [ ] Release notes prepared
- [ ] All secrets are set (check keychain or env vars)
- [ ] Match certificates are valid (not expired)
- [ ] Test build runs without errors
- [ ] Code signing verified
- [ ] Notarization successful
- [ ] Sparkle signature in appcast.xml
- [ ] GitHub release created with DMG + ZIP
- [ ] appcast.xml committed to main branch
- [ ] Update detected by previous version (test)

## Troubleshooting

### "No valid signing identity found"

```bash
# Re-fetch certificates from Match
cd fastlane
bundle exec fastlane match developer_id --readonly
```

### "Could not load secret from keychain"

```bash
# Check keychain
security find-generic-password -s 'com.claw.SPARKLE_SECRET_KEY' -w

# Re-set secret
export SPARKLE_SECRET_KEY="your_key"
cd fastlane && bundle exec fastlane create_and_sign_release
```

### "Notarization failed"

Check the notarization log:
```bash
xcrun notarytool log <submission-id> --keychain-profile "notarytool"
```

Common issues:
- Hardened runtime not enabled
- Missing entitlements
- Unsigned nested frameworks
- Invalid signature

### "Update not detected"

1. Check appcast.xml is accessible:
   ```bash
   curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
   ```

2. Verify EdDSA signature matches:
   - Public key in Info.plist
   - Signature in appcast.xml created with matching private key

3. Check version numbers:
   - `CFBundleVersion` in Info.plist
   - `APP_VERSION` in Claw.xcconfig
   - Version in appcast.xml

4. Check logs in Console.app:
   - Filter: `subsystem:com.claw.updates`

### "Match password incorrect"

```bash
# Update password in keychain
security delete-generic-password -s 'com.claw.MATCH_PASSWORD'
export MATCH_PASSWORD="new_password"
cd fastlane && bundle exec fastlane match developer_id
```

## Version History Example

```
v1.0.0 - Initial release
v1.0.1 - Bug fixes and performance improvements
v1.0.2 - New features: X, Y, Z
```

Keep a CHANGELOG.md for detailed version history.

## Security Notes

**Public Information (safe to commit):**
- SUPublicEDKey in Info.plist
- SUFeedURL in Info.plist
- appcast.xml file
- Claw.xcconfig version

**Private Information (never commit):**
- SPARKLE_SECRET_KEY (EdDSA private key)
- MATCH_PASSWORD
- GitHub access tokens
- Apple notarization credentials (P8 key)
- `.sparkle_private_key` file
- Any Match certificate repos

All private keys are in `.gitignore` and should be stored in:
- Local: Mac keychain (via Fastlane helpers)
- CI/CD: GitHub Secrets

## Additional Resources

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [Fastlane Docs](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [Apple Notarization](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [cmd app reference](https://github.com/getcmd-dev/cmd)
