# Sparkle Automatic Updates Setup Guide

This guide explains how to set up and use automatic updates for Claw using Sparkle.

## Overview

Claw uses [Sparkle](https://sparkle-project.org/) for automatic updates. The implementation follows the architecture from the [cmd app](https://github.com/getcmd-dev/cmd) with a focus on security and user privacy.

## Security Principles

### 🔐 Key Security Measures

1. **Private Key Protection**
   - NEVER commit the Sparkle private key to git
   - Store securely in password manager or GitHub Secrets
   - Used only during release builds to sign updates

2. **Public Key Distribution**
   - Public key is safe to commit (stored in Info.plist)
   - Users need this to verify update authenticity
   - Like a public SSH key - useless without private key

3. **User Privacy**
   - `sendSystemProfile: false` - no telemetry collected
   - Background updates - non-intrusive
   - User control via preferences

## Initial Setup

### Step 1: Add Sparkle via SPM

1. Open `Claw.xcodeproj` in Xcode
2. Go to **File → Add Packages...**
3. Enter: `https://github.com/sparkle-project/Sparkle`
4. Select version: "Up to Next Major Version" (recommended)
5. Add to the **Claw** target
6. Build the project once to download Sparkle

### Step 2: Generate Signing Keys

```bash
# Run the key generation script
./generate_sparkle_keys.sh
```

This will output two keys:

```
SUPublicEDKey: abc123xyz... (PUBLIC - safe to share)
Private key: xyz789abc... (PRIVATE - keep secret!)
```

### Step 3: Store Keys Securely

**Public Key (Info.plist):**
1. Copy the `SUPublicEDKey` value
2. Add to `Claw/Info.plist` or Xcode project settings
3. This is safe to commit to git ✅

**Private Key (Secret Storage):**

Option A - Local Development:
```bash
# Save to .sparkle_private_key (already in .gitignore)
echo 'YOUR_PRIVATE_KEY_HERE' > .sparkle_private_key
```

Option B - GitHub Actions (for CI/CD):
1. Go to repository Settings → Secrets and variables → Actions
2. Create new secret: `SPARKLE_PRIVATE_KEY`
3. Paste your private key value
4. Never print this in logs! ⚠️

### Step 4: Update Info.plist

Add these keys to your Info.plist:

```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml</string>

<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY_HERE</string>
```

Or in Xcode project settings:
- Target Claw → Info → Custom iOS Target Properties
- Add `SUFeedURL` (String): `https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml`
- Add `SUPublicEDKey` (String): Your public key

## Release Process

### Building and Signing a Release

```bash
# Set your private key (from secure storage)
export SPARKLE_PRIVATE_KEY=$(cat .sparkle_private_key)

# Build, sign, notarize, and create Sparkle update
./build_and_notarize.sh
```

This script will:
1. Build and code sign the app
2. Notarize with Apple
3. Create a ZIP for Sparkle updates
4. Sign the ZIP with your Sparkle private key
5. Generate `appcast.xml` with the signature

### Creating a GitHub Release

```bash
# Create DMG for manual distribution
./create_dmg.sh

# Upload both files to GitHub Release:
# - dist/Claw-1.0.X.dmg (manual download)
# - build/Claw-1.0.X.zip (Sparkle updates)
```

### Commit the Appcast

```bash
# Commit the updated appcast.xml
git add appcast.xml
git commit -m "Update appcast for version 1.0.X"
git push
```

The appcast.xml must be in your repository for updates to work!

## How It Works

### Architecture

```
ClawApp.swift
    ↓
DefaultAppUpdateService (checks every hour)
    ↓
UpdateChecker (wraps Sparkle)
    ↓
BackgroundUserDriver (silent UI)
    ↓
SPUUpdater (Sparkle framework)
```

### Update Flow

1. App launches → `DefaultAppUpdateService` starts
2. Every hour, checks `appcast.xml` from GitHub
3. Compares versions → verifies EdDSA signature
4. If update available → downloads in background
5. User sees notification → can install on next launch

### Files and Their Purpose

- `Models.swift` - Data structures for updates
- `AppUpdateService.swift` - Protocol definition
- `DefaultAppUpdateService.swift` - Background update logic
- `UpdateChecker.swift` - Sparkle integration wrapper
- `BackgroundUserDriver.swift` - Silent update UI (no popups)

## User Settings

Users can control updates via UserDefaults:

```swift
// Enable/disable automatic checks
UserDefaults.standard.set(false, forKey: "AppUpdateService.automaticallyCheckForUpdates")

// Ignored versions (user chose "skip this version")
// Stored as JSON array in UserDefaults
```

## Testing Updates

### Local Testing

1. Build version 1.0.2
2. Create a test appcast.xml pointing to local ZIP
3. Update `SUFeedURL` to point to local file
4. Run app → should detect "update"

### Production Testing

1. Create a test release with incremented version
2. Push appcast.xml to GitHub
3. Run current version of app
4. Wait for update check (or force check in DEBUG mode)

## Troubleshooting

### "No update available" but version is newer

- Check that `CFBundleVersion` (build number) is incrementing
- Verify appcast.xml is accessible at the feed URL
- Check Sparkle logs in Console.app (search for "com.claw.updates")

### "Update signature invalid"

- Private key used for signing doesn't match public key in Info.plist
- Regenerate keys and update Info.plist

### Update check not running

- Check DEBUG mode - updates disabled in DEBUG builds
- Verify `automaticallyCheckForUpdates` UserDefaults setting
- Check logs for service initialization

## Security Checklist

Before each release:

- [ ] Private key is NOT in source code
- [ ] Private key is NOT in git history
- [ ] Public key is in Info.plist
- [ ] appcast.xml uses HTTPS URL
- [ ] sendSystemProfile is false
- [ ] ZIP is signed with correct private key
- [ ] Signature in appcast.xml matches ZIP

## References

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [cmd app implementation](https://github.com/getcmd-dev/cmd/blob/main/app/modules/services/AppUpdateService/)
- [EdDSA Signing Guide](https://sparkle-project.org/documentation/signing/)
