# Sparkle Automatic Updates - Setup Checklist

This checklist guides you through completing the Sparkle automatic updates setup.

## ✅ Already Completed

- [x] Sparkle framework integrated
- [x] AppUpdateService module implemented
- [x] Background update checking configured
- [x] EdDSA key pair generated (`.sparkle_private_key` stored locally)
- [x] Fastlane automation scripts created
- [x] Version management via `Claw.xcconfig`
- [x] Info.plist configured with SUFeedURL and SUPublicEDKey
- [x] Documentation written (SPARKLE_SETUP.md, RELEASE.md, NEXT_STEPS.md)
- [x] Code committed to `jroch-sparkle` branch

## 📋 Remaining Setup Steps

### Phase 1: Fastlane Match Setup (30 min)

#### 1.1 Create Match Repository
**What**: Private GitHub repository to store code signing certificates

**Steps**:
1. Go to https://github.com/new
2. Repository name: `Claw-certificates` (or any name you prefer)
3. **IMPORTANT**: Set to **Private**
4. Do NOT initialize with README, .gitignore, or license
5. Click "Create repository"
6. Copy the repository URL (e.g., `git@github.com:jamesrochabrun/Claw-certificates.git`)

#### 1.2 Initialize Fastlane Match
**What**: Configure Match to use your certificates repository

**Steps**:
```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane match init
```

When prompted:
- Select `git` for storage mode
- Enter your Match repository URL (from step 1.1)
- This creates `fastlane/Matchfile`

#### 1.3 Generate Match Encryption Password
**What**: Strong password to encrypt certificates in the Match repo

**Steps**:
```bash
# Generate a strong random password
openssl rand -base64 32
```

**SAVE THIS PASSWORD** - You'll need it for:
- Local development
- GitHub Actions secrets

#### 1.4 Import Existing Certificates (or Generate New)
**What**: Store your Apple Developer certificates in Match

**Option A - Import Existing** (if you have certificates):
```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane match import
```

**Option B - Generate New** (recommended for fresh start):
```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane match development
bundle exec fastlane match appstore
```

When prompted, enter:
- Apple ID: Your Apple Developer account email
- Team ID: `CQ45U4X9K3`
- Match password: (the one from step 1.3)

### Phase 2: Apple App Store Connect API Key (20 min)

#### 2.1 Create API Key
**What**: Required for notarization without 2FA prompts

**Steps**:
1. Go to https://appstoreconnect.apple.com/access/api
2. Click the "+" button under "Keys"
3. Name: `Claw Fastlane`
4. Access: Select **App Manager** role
5. Click "Generate"
6. **Download the .p8 file** (only shown once!)
7. Note the **Key ID** and **Issuer ID**

#### 2.2 Store API Key Securely
**What**: Save the .p8 file in a secure location

**Recommended location**:
```bash
mkdir -p ~/private_keys
mv ~/Downloads/AuthKey_*.p8 ~/private_keys/
chmod 600 ~/private_keys/AuthKey_*.p8
```

### Phase 3: GitHub Secrets Configuration (10 min)

#### 3.1 Add Repository Secrets
**What**: Configure secrets for GitHub Actions (future CI/CD)

**Steps**:
1. Go to your Claw repository on GitHub
2. Click "Settings" > "Secrets and variables" > "Actions"
3. Click "New repository secret" for each:

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `MATCH_PASSWORD` | Your Match encryption password | Step 1.3 |
| `MATCH_GIT_URL` | Your Match repository URL | Step 1.1 |
| `APPLE_ID` | Your Apple Developer email | Apple Developer account |
| `APPLE_TEAM_ID` | `CQ45U4X9K3` | Already known |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from step 2.1 | App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step 2.1 | App Store Connect |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64-encoded .p8 file | See below |
| `SPARKLE_PRIVATE_KEY` | Base64-encoded private key | See below |
| `GITHUB_TOKEN` | GitHub personal access token | See below |

#### 3.2 Encode .p8 File
```bash
base64 -i ~/private_keys/AuthKey_*.p8 | pbcopy
```
Paste into `APP_STORE_CONNECT_API_KEY_CONTENT` secret.

#### 3.3 Encode Sparkle Private Key
```bash
base64 -i .sparkle_private_key | pbcopy
```
Paste into `SPARKLE_PRIVATE_KEY` secret.

#### 3.4 Create GitHub Personal Access Token
**Steps**:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `Claw Fastlane Releases`
4. Scopes: Select **repo** (all sub-scopes)
5. Click "Generate token"
6. Copy the token (only shown once!)
7. Paste into `GITHUB_TOKEN` secret

### Phase 4: Local Testing (30 min)

#### 4.1 Test Match Access
**What**: Verify Match can access certificates

```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane match development --readonly
```

Should succeed without errors.

#### 4.2 Test Debug Build
**What**: Verify Fastlane can build the app

```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane build_debug
```

Should produce a working .app in `build/` directory.

#### 4.3 Test Release Build (Without Notarization)
**What**: Test building a signed release

```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane build_release
```

Should succeed with code signing.

#### 4.4 Test Full Release Pipeline
**What**: Create your first v1.0.0 release

```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane distribute_release
```

This will:
1. Check for version conflicts
2. Fetch code signing certificates
3. Build the app in Release mode
4. Strip debug symbols
5. Code sign with Developer ID
6. Notarize with Apple
7. Create Sparkle update ZIP
8. Sign ZIP with EdDSA private key
9. Update appcast.xml
10. Create DMG for manual distribution
11. Upload to GitHub Releases
12. Create PR with changes

### Phase 5: Verification (15 min)

#### 5.1 Check GitHub Release
1. Go to https://github.com/jamesrochabrun/Claw/releases
2. Verify v1.0.0 release exists
3. Download `Claw.app.zip`
4. Verify signature:
   ```bash
   ~/Library/Developer/Xcode/DerivedData/Claw-*/SourcePackages/artifacts/sparkle/Sparkle/bin/verify_signature \
     Claw.app.zip $(cat Claw/Info.plist | grep SUPublicEDKey -A1 | tail -1 | cut -d'>' -f2 | cut -d'<' -f1)
   ```

#### 5.2 Merge Release PR
1. Review the PR created by Fastlane
2. Verify appcast.xml has correct signature and file size
3. Merge to `main` branch

#### 5.3 Test Auto-Update Flow
1. Change `Claw.xcconfig`: `APP_VERSION = 0.9.0`
2. Build and run the app
3. Wait ~30 seconds for background update check
4. Verify update is detected in Console.app logs:
   ```
   subsystem:com.claw.updates category:sparkle
   ```
5. Update should download, verify signature, and offer to install

## 🎉 Success Criteria

- ✅ Match repository created and configured
- ✅ Code signing certificates in Match repo
- ✅ GitHub secrets all configured
- ✅ `fastlane build_debug` succeeds
- ✅ `fastlane build_release` succeeds
- ✅ `fastlane distribute_release` creates v1.0.0
- ✅ GitHub Release v1.0.0 exists with signed ZIP
- ✅ appcast.xml on main branch with valid signature
- ✅ App detects and installs update successfully

## 📚 Reference Documentation

- [SPARKLE_SETUP.md](./SPARKLE_SETUP.md) - Architecture and configuration
- [RELEASE.md](./RELEASE.md) - Release workflow details
- [NEXT_STEPS.md](./NEXT_STEPS.md) - Quick start guide
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - What was implemented

## 🆘 Troubleshooting

### Match Errors
- **"Could not find the certificate"**: Run `fastlane match development` to generate new certificates
- **"Invalid password"**: Check your Match password is correct
- **"Git error"**: Verify Match repository URL is correct and you have access

### Notarization Errors
- **"Invalid API key"**: Verify App Store Connect API key is correct
- **"Team ID mismatch"**: Ensure `APPLE_TEAM_ID` is `CQ45U4X9K3`

### Sparkle Signature Errors
- **"Invalid signature"**: Verify public key in Info.plist matches `.sparkle_private_key`
- **"No update available"**: Check build numbers in appcast.xml (`sparkle:version`)

## 🔐 Security Notes

**NEVER commit these files**:
- ✅ `.sparkle_private_key` (in .gitignore)
- ✅ `AuthKey_*.p8` (store in ~/private_keys/)
- ✅ Match password (use environment variable or keychain)
- ✅ GitHub tokens (use GitHub Secrets)

**Verify before pushing**:
```bash
git ls-files | grep -E "sparkle_private_key|AuthKey|\.p8"
```
Should return nothing.

---

**Estimated Total Time**: ~2 hours (first time), ~30 min (subsequent releases)

**Current Status**: Code complete, infrastructure setup pending

**Next Action**: Start with Phase 1.1 (Create Match Repository)
