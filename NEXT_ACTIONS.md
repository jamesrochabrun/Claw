# Sparkle Integration - Next Actions

## 🎯 Current Status: CODE COMPLETE ✅

**Branch**: `jroch-sparkle` (pushed to GitHub)
**Commits**: 2 commits with full Sparkle implementation
**Security**: ✅ Private key NOT in git (`.sparkle_private_key` in .gitignore)

## ✅ What's Working

- Sparkle framework integrated
- Background update checking (hourly, silent)
- EdDSA key pair generated (public in Info.plist, private in `.sparkle_private_key`)
- Fastlane automation complete (build, sign, notarize, release)
- Version management via `Claw.xcconfig`
- Documentation complete

## 🚀 IMMEDIATE NEXT PHASE: Infrastructure Setup

### Phase 1: Create Match Repository (YOU - 5 min)

**Action Required**:
1. Go to https://github.com/new
2. Repository name: `Claw-certificates`
3. **Set to PRIVATE** ⚠️
4. Do NOT initialize (no README, .gitignore, license)
5. Create repository
6. **Copy the SSH URL** (e.g., `git@github.com:jamesrochabrun/Claw-certificates.git`)

**Tell me when done**: Provide the repository URL

---

### Phase 2: Initialize Match (ME - 10 min)

**What I'll do**:
```bash
cd fastlane
bundle exec fastlane match init
```

**What you'll provide when prompted**:
- Storage mode: `git` (I'll select this)
- Git URL: The URL from Phase 1

**What I'll create**:
- `fastlane/Matchfile` configuration

---

### Phase 3: Generate Match Password (ME - 1 min)

**What I'll do**:
```bash
openssl rand -base64 32
```

**Output**: Strong random password (e.g., `xK7mP9vR...`)

**What you'll do**:
- **SAVE THIS PASSWORD** securely (1Password, etc.)
- You'll need it for local development and GitHub secrets

---

### Phase 4: Get Apple Credentials (YOU - 15 min)

**Required Information**:

#### A. Apple ID & Team ID
- Apple ID: Your Apple Developer email
- Team ID: `CQ45U4X9K3` (already known)

#### B. App Store Connect API Key
1. Go to https://appstoreconnect.apple.com/access/api
2. Click "+" under Keys
3. Name: `Claw Fastlane`
4. Role: **App Manager**
5. Generate and **download the .p8 file** (only shown once!)
6. Note the **Key ID** and **Issuer ID**

**Save the .p8 file**:
```bash
mkdir -p ~/private_keys
mv ~/Downloads/AuthKey_*.p8 ~/private_keys/
chmod 600 ~/private_keys/AuthKey_*.p8
```

**Tell me when done**: Confirm you have Key ID, Issuer ID, and .p8 file saved

---

### Phase 5: Import/Generate Certificates (ME - 10 min)

**What I'll do**:
```bash
cd fastlane
bundle exec fastlane match development
bundle exec fastlane match appstore
```

**What you'll provide when prompted**:
- Apple ID: (from Phase 4A)
- Team ID: `CQ45U4X9K3`
- Match password: (from Phase 3)

**What happens**:
- Certificates stored in Match repository
- Encrypted with Match password
- Ready for use in builds

---

### Phase 6: Configure GitHub Secrets (YOU - 10 min)

**Where**: GitHub repo → Settings → Secrets and variables → Actions

**Secrets to add** (I'll provide the values):

| Secret Name | Source |
|-------------|--------|
| `MATCH_PASSWORD` | From Phase 3 |
| `MATCH_GIT_URL` | From Phase 1 |
| `APPLE_ID` | From Phase 4A |
| `APPLE_TEAM_ID` | `CQ45U4X9K3` |
| `APP_STORE_CONNECT_API_KEY_ID` | From Phase 4B |
| `APP_STORE_CONNECT_ISSUER_ID` | From Phase 4B |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | I'll encode .p8 file |
| `SPARKLE_PRIVATE_KEY` | I'll encode private key |
| `GITHUB_TOKEN` | You create personal access token |

**For GitHub Token**:
1. https://github.com/settings/tokens
2. Generate new token (classic)
3. Name: `Claw Fastlane Releases`
4. Scope: **repo** (all)
5. Generate and copy

**Tell me when done**: Confirm all secrets added

---

### Phase 7: Test First Release (ME - 30 min)

**What I'll do**:
```bash
cd fastlane
bundle exec fastlane distribute_release
```

**What happens**:
1. Fetches certificates from Match
2. Builds app in Release mode
3. Strips debug symbols
4. Code signs with Developer ID
5. Notarizes with Apple
6. Creates Sparkle ZIP
7. Signs with EdDSA
8. Updates appcast.xml
9. Uploads to GitHub Releases
10. Creates PR

**Success criteria**:
- GitHub Release v1.0.0 exists
- `Claw.app.zip` uploaded
- appcast.xml updated with signature
- PR ready to merge

---

### Phase 8: Test Update Flow (ME - 10 min)

**What I'll do**:
1. Change version to 0.9.0
2. Build and run app
3. Verify update detected
4. Confirm signature validates
5. Test installation

---

## 📊 Summary

**Total estimated time**: ~1.5 hours

**Your actions** (30 min):
- Phase 1: Create Match repo (5 min)
- Phase 4: Get Apple credentials (15 min)
- Phase 6: Configure GitHub secrets (10 min)

**My actions** (1 hour):
- Phase 2: Initialize Match (10 min)
- Phase 3: Generate password (1 min)
- Phase 5: Import certificates (10 min)
- Phase 7: Test release (30 min)
- Phase 8: Test update (10 min)

## 🎬 Ready to Start?

**First action**: Tell me when you've created the Match repository and have the URL ready.

Then we'll proceed through phases 2-8 together.

---

## 📚 Reference Files

- `SETUP_CHECKLIST.md` - Detailed step-by-step guide
- `SPARKLE_SETUP.md` - Architecture documentation
- `RELEASE.md` - Release workflow details
- `IMPLEMENTATION_SUMMARY.md` - What was implemented

## 🔒 Security Checklist

Before we start, verify:
```bash
# Private key NOT in git
git ls-files | grep sparkle_private_key
# Should return nothing

# .gitignore includes private key
grep sparkle_private_key .gitignore
# Should return: .sparkle_private_key
```

Both ✅ - we're safe to proceed!
