# Sparkle Automatic Updates Setup Guide

Complete implementation of automatic updates for Claw using [Sparkle](https://sparkle-project.org/) and Fastlane.

## Overview

Claw uses Sparkle for automatic updates with a complete Fastlane-based release pipeline, following the architecture from the [cmd app](https://github.com/getcmd-dev/cmd).

### Key Features

- Background update checking (hourly)
- Silent downloads (no intrusive popups)
- EdDSA signature verification
- User privacy protected (no telemetry)
- Automated release workflow
- Professional code signing with Fastlane Match

## Architecture

```
ClawApp.swift
    ↓
DefaultAppUpdateService (checks hourly)
    ↓
UpdateChecker (wraps Sparkle)
    ↓
BackgroundUserDriver (silent UI)
    ↓
SPUUpdater (Sparkle framework)
    ↓
Downloads from appcast.xml → GitHub Releases
```

### Update Flow

1. App launches → `DefaultAppUpdateService` starts
2. Every hour, checks `appcast.xml` from GitHub
3. Compares versions → verifies EdDSA signature
4. If update available → downloads ZIP in background
5. User sees notification → installs on next launch

### Files and Their Purpose

**Swift Implementation:**
- `Models.swift` - Data structures (`AppUpdateInfo`, `AppUpdateResult`)
- `AppUpdateService.swift` - Protocol definition
- `DefaultAppUpdateService.swift` - Background checking logic
- `UpdateChecker.swift` - Sparkle integration wrapper
- `BackgroundUserDriver.swift` - Silent update UI (no popups)

**Build & Release:**
- `fastlane/Fastfile` - Complete automation (build, sign, notarize, release)
- `fastlane/Appfile` - Bundle ID and team configuration
- `Claw.xcconfig` - Version and channel configuration
- `appcast.template.xml` - Template for update manifest
- `appcast.xml` - Active update manifest (auto-generated)

**Configuration:**
- `Info.plist` - Sparkle public key and feed URL
- `Gemfile` - Ruby dependencies (fastlane, xcbeautify)
- `.ruby-version` - Ruby version lock

## Security Architecture

### EdDSA Key Pair (Sparkle Signing)

**Private Key:**
- Used to sign update ZIPs
- NEVER commit to git
- Store in keychain (local) or GitHub Secrets (CI)
- Loaded via Fastlane helpers

**Public Key:**
- Embedded in Info.plist (SUPublicEDKey)
- Safe to commit to git
- Users need this to verify authenticity
- Like SSH public key - useless without private key

### Code Signing (Apple Developer ID)

Managed via Fastlane Match:
- Certificates stored in private Git repo
- Encrypted with MATCH_PASSWORD
- Shared across machines/CI
- Automatic synchronization

### Privacy Protection

```swift
// BackgroundUserDriver.swift
SUUpdatePermissionResponse(
  automaticUpdateChecks: true,
  automaticUpdateDownloading: true,
  sendSystemProfile: false  // ⭐ No telemetry!
)
```

## Initial Setup

### 1. Install Dependencies

```bash
# Install Bundler (if needed)
gem install bundler

# Install Fastlane and tools
bundle install

# Install create-dmg for DMG creation
brew install create-dmg
```

### 2. Add Sparkle via SPM

1. Open `Claw.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. URL: `https://github.com/sparkle-project/Sparkle`
4. Version: Up to Next Major (2.0.0+)
5. Add to Claw target

### 3. Generate Sparkle Keys

```bash
# Build project once to download Sparkle
xcodebuild -scheme Claw -configuration Release

# Generate EdDSA signing keys
./generate_sparkle_keys.sh
```

Output:
```
SUPublicEDKey: abc123xyz... (PUBLIC - add to Info.plist)
Private key: xyz789abc... (PRIVATE - keep secret!)
```

### 4. Configure Info.plist

Add to `Claw/Info.plist`:

```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml</string>

<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY_FROM_STEP_3</string>
```

### 5. Set Up Fastlane Match

```bash
# Create private GitHub repo for certificates
# https://github.com/jamesrochabrun/claw-provisioning-profiles

# Initialize Match
cd fastlane
bundle exec fastlane match developer_id --readonly false
```

Enter a strong Match password when prompted. Store it securely!

### 6. Store Secrets

#### Local Development

```bash
# Set secrets as environment variables
export SPARKLE_SECRET_KEY="your_private_key_from_step_3"
export MATCH_PASSWORD="your_match_password"
export FASTLANE_GITHUB_ACCESS_TOKEN="ghp_your_token"
export GH_WRITE_TOKEN="ghp_your_token"
export NOTARY_KEY_ID="your_asc_key_id"
export NOTARY_ISSUER_ID="your_asc_issuer"
export NOTARY_P8="-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----"

# Run fastlane once - it will save to keychain
cd fastlane
bundle exec fastlane create_and_sign_release
```

After first run, secrets are in keychain and loaded automatically.

#### GitHub Actions (CI/CD)

Repository Settings → Secrets and variables → Actions:

Required secrets:
- `SPARKLE_SECRET_KEY`
- `MATCH_PASSWORD`
- `FASTLANE_GITHUB_ACCESS_TOKEN`
- `GH_WRITE_TOKEN`
- `NOTARY_KEY_ID`
- `NOTARY_ISSUER_ID`
- `NOTARY_P8`

### 7. Link Claw.xcconfig

In Xcode:
1. Project settings → Info → Configurations
2. Set `Claw.xcconfig` for both Debug and Release

Or add to Build Settings:
```
#include "Claw.xcconfig"
```

## Release Process

### Automated Release (Recommended)

```bash
cd fastlane
bundle exec fastlane distribute_release
```

This will:
1. Auto-increment version if needed
2. Build, sign, notarize
3. Create Sparkle ZIP + DMG
4. Update appcast.xml
5. Upload to GitHub Releases
6. Create PR with changes

### Manual Release

See [RELEASE.md](./RELEASE.md) for detailed manual process.

Quick version:

```bash
# 1. Update version in Claw.xcconfig
# APP_VERSION = 1.0.1

# 2. Build and sign
./build_and_notarize.sh

# 3. Create GitHub release
gh release create v1.0.1 \
  build/release/Claw.dmg \
  build/release/Claw.app.zip

# 4. Commit appcast
git add appcast.xml Claw.xcconfig
git commit -m "Release v1.0.1"
git push
```

## Fastlane Lanes

### build_debug
Quick debug build for testing.
```bash
bundle exec fastlane build_debug
```

### build_release
Release build without signing (testing only).
```bash
bundle exec fastlane build_release
```

### create_and_sign_release
Full build, sign, notarize, create Sparkle update.
```bash
bundle exec fastlane create_and_sign_release
```

Creates:
- `build/release/Claw.app` (notarized)
- `build/release/Claw.dmg` (installer)
- `build/release/Claw.app.zip` (Sparkle update)
- Updated `appcast.xml`

### distribute_release
Fully automated release with GitHub upload and PR.
```bash
bundle exec fastlane distribute_release
```

### strip_debug_symbols_and_resign
Utility lane to reduce binary size (~40% reduction).
```bash
bundle exec fastlane strip_debug_symbols_and_resign \
  app_path:build/release/Claw.app \
  app_binary_path:build/release/Claw.app/Contents/MacOS/Claw \
  build_path:build \
  certificate_name:"Developer ID Application" \
  certificate_sha1:ABC123...
```

## Configuration Files

### Claw.xcconfig

Version and channel management:

```
APP_VERSION = 1.0.0
APP_DISTRIBUTION_CHANNEL = stable
MARKETING_VERSION = $(APP_VERSION)
CURRENT_PROJECT_VERSION = 1
```

Updated automatically by `distribute_release` lane.

### appcast.template.xml

Template for update manifest. Placeholders replaced by Fastlane:

```xml
<sparkle:version>REPLACE_VERSION</sparkle:version>
<sparkle:edSignature>REPLACE_SIGNATURE</sparkle:edSignature>
<pubDate>REPLACE_PUBDATE</pubDate>
```

### appcast.xml

Active update manifest hosted on GitHub. Generated from template.

Users' apps poll this URL hourly.

## How Sparkle Signing Works

### During Build (Fastlane)

```ruby
# After creating notarized app, create special ZIP
sh("ditto -c -k --keepParent --sequesterRsrc #{app_path} #{app_zip_path}")

# Sign with EdDSA private key
sparkle_output = sh("echo '#{sparkle_secret_key}' | #{sparkle_path}/bin/sign_update #{app_zip_path} --ed-key-file -")

# Output: "sparkle:edSignature="abc123..." length="12345678""
```

### During Update (User's App)

```swift
// 1. Download appcast.xml from GitHub
// 2. Parse <enclosure> tag
// 3. Verify edSignature using SUPublicEDKey from Info.plist
// 4. If valid, download and install ZIP
// 5. If invalid, reject update (security!)
```

This prevents malicious updates - only ZIPs signed with your private key are accepted.

## Testing Updates

### Local Testing

1. Build version 1.0.1:
   ```bash
   # In Claw.xcconfig: APP_VERSION = 1.0.1
   ./build_and_notarize.sh
   ```

2. Install and run version 1.0.0

3. Host appcast locally:
   ```bash
   python3 -m http.server 8000
   ```

4. Update Info.plist SUFeedURL:
   ```
   http://localhost:8000/appcast.xml
   ```

5. App should detect update within ~1 hour (or force check)

### Production Testing

1. Create test release (1.0.1)
2. Upload to GitHub Releases
3. Push appcast.xml to main branch
4. Run version 1.0.0
5. Wait for update check (check Console.app logs)

## Troubleshooting

### Update Check Not Running

Check logs in Console.app:
```
subsystem:com.claw.updates category:service
```

Common issues:
- DEBUG mode (updates disabled in debug builds)
- `automaticallyCheckForUpdates` setting is false
- Service not initialized in ClawApp.swift

### No Update Detected

1. Verify appcast.xml accessible:
   ```bash
   curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
   ```

2. Check version comparison:
   - Current: `CFBundleVersion` in Info.plist
   - New: `<sparkle:version>` in appcast.xml
   - Must be higher to trigger update

3. Verify signature:
   ```bash
   # Public key in Info.plist must match private key used to sign
   ```

### Signature Verification Failed

```
updaterError: Update signature invalid
```

Cause: Private/public key mismatch.

Fix:
1. Regenerate keys: `./generate_sparkle_keys.sh`
2. Update SUPublicEDKey in Info.plist
3. Re-sign update ZIP with new private key

### Notarization Failed

Check notarization log:
```bash
xcrun notarytool log <submission-id> --keychain-profile notarytool
```

Common issues:
- Missing hardened runtime
- Unsigned nested frameworks
- Invalid entitlements

Fix:
```bash
# Re-sign all components
cd fastlane
bundle exec fastlane strip_debug_symbols_and_resign
```

### Fastlane Match Issues

```
Could not decrypt provisioning profile
```

Fix:
```bash
# Verify password
security find-generic-password -s 'com.claw.MATCH_PASSWORD' -w

# Re-fetch certificates
bundle exec fastlane match developer_id --readonly
```

## User Settings

Users can control updates via UserDefaults:

```swift
// Disable automatic checks
UserDefaults.standard.set(false, forKey: "AppUpdateService.automaticallyCheckForUpdates")

// Ignored versions (user clicked "Skip")
// Stored as JSON array in UserDefaults
UserDefaults.standard.string(forKey: "AppUpdateService.ignoredVersion")
```

## Security Checklist

Before each release:

- [ ] Private key NOT in source code
- [ ] Private key NOT in git history
- [ ] Public key IS in Info.plist
- [ ] appcast.xml uses HTTPS URL
- [ ] `sendSystemProfile` is false
- [ ] ZIP signed with correct private key
- [ ] Signature in appcast.xml matches ZIP
- [ ] Match certificates valid (not expired)
- [ ] Code signing verified
- [ ] Notarization successful

## References

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [Apple Notarization](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [cmd app reference](https://github.com/getcmd-dev/cmd)
- [RELEASE.md](./RELEASE.md) - Complete release guide
