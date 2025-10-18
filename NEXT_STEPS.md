# Next Steps: Fastlane-Based Sparkle Integration

Complete Sparkle automatic updates implementation with Fastlane automation is ready!

## ✅ Already Completed

- [x] AppUpdateService Swift implementation
  - Models, protocols, default service
  - UpdateChecker with Sparkle integration
  - BackgroundUserDriver for silent updates
  - Integration with ClawApp.swift
- [x] Fastlane automation setup
  - Complete Fastfile with all lanes
  - Appfile with bundle ID and team
  - Gemfile with dependencies
  - Ruby version lock (.ruby-version)
- [x] Version configuration (Claw.xcconfig)
- [x] Appcast template with placeholders
- [x] Build scripts updated for Fastlane
- [x] Security measures (.gitignore)
- [x] Comprehensive documentation (SPARKLE_SETUP.md, RELEASE.md)

## 🔧 Manual Setup Required

These steps require manual configuration in Xcode and external services:

### 1. Install Ruby Dependencies (5 minutes)

```bash
# Install Bundler if needed
gem install bundler

# Install Fastlane and tools
bundle install

# Install create-dmg for DMG creation
brew install create-dmg
```

### 2. Add Sparkle via Swift Package Manager (5 minutes)

Must be done in Xcode:

1. Open `Claw.xcodeproj` in Xcode
2. Select the project → **Package Dependencies** tab
3. Click **+** → Add Package Dependency
4. URL: `https://github.com/sparkle-project/Sparkle`
5. Version: "Up to Next Major Version" → 2.0.0
6. Add to **Claw** target
7. Build once (⌘B) to download Sparkle

### 3. Generate Sparkle Signing Keys (2 minutes)

```bash
# Build project first to ensure Sparkle is downloaded
xcodebuild -scheme Claw -configuration Release

# Generate EdDSA key pair
./generate_sparkle_keys.sh
```

Output will show:
```
SUPublicEDKey: abc123xyz...  (PUBLIC - add to Info.plist)
Private key: xyz789abc...    (PRIVATE - keep secret!)
```

⚠️ **Save both keys immediately** - you'll need them for the next steps!

### 4. Update Info.plist (5 minutes)

**Option A - Via Xcode (Recommended):**

1. Select **Claw** target
2. **Info** tab → Custom macOS Target Properties
3. Hover and click **+** to add keys:
   - `SUFeedURL` (String):
     ```
     https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
     ```
   - `SUPublicEDKey` (String):
     ```
     [paste PUBLIC key from step 3]
     ```

**Option B - Edit Info.plist directly:**

```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml</string>

<key>SUPublicEDKey</key>
<string>[paste PUBLIC key from step 3]</string>
```

### 5. Link Claw.xcconfig to Project (5 minutes)

**Option A - Via Xcode Project Settings:**

1. Open project settings (click on project root)
2. **Info** tab
3. Under **Configurations** section:
   - Debug: Set to `Claw`
   - Release: Set to `Claw`
4. Select `Claw.xcconfig` for both

**Option B - Via Build Settings:**

1. Select **Claw** target
2. **Build Settings** tab
3. Search for "config"
4. Add under any setting:
   ```
   #include "Claw.xcconfig"
   ```

### 6. Set Up Fastlane Match (15 minutes)

⚠️ **Important**: This manages your code signing certificates.

1. **Create private GitHub repository:**
   - Name: `claw-provisioning-profiles` (or your choice)
   - Visibility: **Private** (critical for security!)
   - URL example: `https://github.com/jamesrochabrun/claw-provisioning-profiles`

2. **Initialize Match:**
   ```bash
   cd fastlane
   bundle exec fastlane match developer_id --readonly false
   ```

3. **Follow prompts:**
   - Git URL: Your private repo URL
   - Password: Create a strong password (store in password manager!)
   - Match will generate Developer ID certificates

4. **Save Match password securely** (1Password, LastPass, etc.)

### 7. Configure Secrets (15 minutes)

You need credentials for:
- Apple notarization (App Store Connect API)
- GitHub (personal access tokens)
- Sparkle signing (EdDSA private key)
- Match (certificate password)

#### Apple Notarization Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys
3. Create new API Key with Admin access
4. Download the `.p8` file
5. Note the Key ID and Issuer ID

#### GitHub Token Setup

1. Go to [GitHub Settings → Developer Settings → Personal Access Tokens](https://github.com/settings/tokens)
2. Generate new token (classic)
3. Scopes needed:
   - `repo` (all)
   - `write:packages`
   - `read:packages`
4. Copy the token (starts with `ghp_`)

#### Store Secrets Locally

```bash
# Set all secrets as environment variables
export SPARKLE_SECRET_KEY="[PRIVATE key from step 3]"
export MATCH_PASSWORD="[password from step 6]"
export FASTLANE_GITHUB_ACCESS_TOKEN="ghp_[your GitHub token]"
export GH_WRITE_TOKEN="ghp_[your GitHub token]"
export NOTARY_KEY_ID="[App Store Connect Key ID]"
export NOTARY_ISSUER_ID="[App Store Connect Issuer ID]"
export NOTARY_P8="-----BEGIN PRIVATE KEY-----
[paste contents of .p8 file]
-----END PRIVATE KEY-----"

# Run fastlane once - it saves to keychain automatically
cd fastlane
bundle exec fastlane create_and_sign_release
```

After first run, Fastlane stores secrets in your Mac keychain. Future runs load them automatically!

#### For GitHub Actions (Optional)

If using CI/CD, add these as repository secrets:

1. GitHub repo → Settings → Secrets and variables → Actions
2. Add new repository secrets:
   - `SPARKLE_SECRET_KEY`
   - `MATCH_PASSWORD`
   - `FASTLANE_GITHUB_ACCESS_TOKEN`
   - `GH_WRITE_TOKEN`
   - `NOTARY_KEY_ID`
   - `NOTARY_ISSUER_ID`
   - `NOTARY_P8`

### 8. Verify Setup (5 minutes)

```bash
# Test build (won't upload anything)
cd fastlane
bundle exec fastlane build_debug
```

Expected output:
```
✓ Build successful
✓ App at: build/Claw.app
```

If successful, the setup is complete!

## 🎯 Quick Start Checklist

Use this checklist to track your progress:

- [ ] Install Ruby dependencies (`bundle install`)
- [ ] Install create-dmg (`brew install create-dmg`)
- [ ] Add Sparkle package in Xcode
- [ ] Build project to download Sparkle
- [ ] Generate Sparkle keys (`./generate_sparkle_keys.sh`)
- [ ] Add SUFeedURL to Info.plist
- [ ] Add SUPublicEDKey to Info.plist
- [ ] Link Claw.xcconfig to Xcode project
- [ ] Create private GitHub repo for Match
- [ ] Initialize Match (`fastlane match developer_id`)
- [ ] Set up Apple notarization (App Store Connect API)
- [ ] Create GitHub personal access token
- [ ] Export all secrets as environment variables
- [ ] Run first build (`fastlane create_and_sign_release`)
- [ ] Test debug build (`fastlane build_debug`)
- [ ] Verify app launches and update service starts

## 🚀 Your First Release

Once setup is complete, create your first release:

### Automated (Recommended)

```bash
cd fastlane
bundle exec fastlane distribute_release
```

This will:
1. Auto-increment version if needed
2. Build, sign, notarize
3. Create Sparkle update ZIP
4. Create DMG for distribution
5. Upload both to GitHub Releases
6. Create PR with appcast update
7. Print PR URL for review

Then merge the PR and users will receive updates!

### Manual

See [RELEASE.md](./RELEASE.md) for step-by-step manual process.

## 📚 Documentation

- [SPARKLE_SETUP.md](./SPARKLE_SETUP.md) - Complete architecture and configuration
- [RELEASE.md](./RELEASE.md) - Detailed release workflow guide
- [Sparkle Docs](https://sparkle-project.org/documentation/)
- [Fastlane Docs](https://docs.fastlane.tools/)
- [cmd app reference](https://github.com/getcmd-dev/cmd)

## 🔍 Verify It's Working

After setup and first release:

1. **Check update service is running:**
   ```bash
   # Build and run app
   # Open Console.app
   # Filter: subsystem:com.claw.updates
   # Should see: "Started update checking loop"
   ```

2. **Verify appcast.xml:**
   ```bash
   curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
   # Should show your version and Sparkle signature
   ```

3. **Test update detection:**
   - Install current version
   - Create new release with higher version
   - Wait ~1 hour or check logs for update check

## ⚠️ Common Issues

### "Bundle install fails"

Make sure you have Ruby 3.3.0+:
```bash
ruby --version
# If old, install via rbenv or system upgrade
```

### "Match fails to create certificates"

1. Check GitHub repo is private
2. Verify you have push access
3. Ensure your Apple Developer account is active

### "Notarization fails"

1. Verify App Store Connect API credentials
2. Check the `.p8` file content is complete
3. Ensure Developer ID certificate is valid

### "Can't find Sparkle"

1. Verify Sparkle package is added in Xcode
2. Build project once to download it
3. Check `build/derived_data/SourcePackages/artifacts/sparkle`

## 🔐 Security Reminders

**Safe to commit:**
- ✅ SUPublicEDKey (in Info.plist)
- ✅ appcast.xml
- ✅ Claw.xcconfig
- ✅ Fastfile, Gemfile

**Never commit:**
- ❌ SPARKLE_SECRET_KEY (private key)
- ❌ .sparkle_private_key file
- ❌ MATCH_PASSWORD
- ❌ GitHub tokens
- ❌ Apple API keys (.p8 files)
- ❌ Match certificate repos

All sensitive data is in `.gitignore` or stored in keychain/GitHub Secrets.

## 📞 Need Help?

1. Check troubleshooting in [SPARKLE_SETUP.md](./SPARKLE_SETUP.md)
2. Review [RELEASE.md](./RELEASE.md) for release issues
3. Check Sparkle logs in Console.app
4. Review Fastlane output for error messages
5. Compare with [cmd app implementation](https://github.com/getcmd-dev/cmd)

## 🎉 Success Criteria

You'll know everything is working when:

- ✅ `fastlane build_debug` completes without errors
- ✅ `fastlane create_and_sign_release` creates signed app
- ✅ appcast.xml has valid EdDSA signature
- ✅ Console.app shows "Started update checking loop"
- ✅ Test update is detected within 1 hour
- ✅ Update installs successfully on quit/relaunch

Ready to ship automatic updates! 🚀
