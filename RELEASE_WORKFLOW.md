# Claw Release Workflow

Complete guide for releasing new versions of Claw with automatic updates.

---

## 🎯 Quick Start

### Option 1: Local Release (Recommended First Time)

```bash
# 1. Update version in Claw.xcconfig
# APP_VERSION = 1.0.1

# 2. Run release command
cd fastlane
bundle exec fastlane distribute_release

# 3. Review and merge the auto-created PR
# GitHub will have a PR with updated appcast.xml

# 4. Done! Users get automatic updates ✨
```

### Option 2: GitHub Actions Release

```bash
# 1. Update version in Claw.xcconfig
# APP_VERSION = 1.0.1

# 2. Commit and push
git add Claw.xcconfig
git commit -m "Bump version to 1.0.1"
git push origin main

# 3. Create and push tag
git tag v1.0.1
git push origin v1.0.1

# 4. GitHub Actions automatically builds and creates release
# 5. Review and merge the auto-created PR
```

---

## 📋 Detailed Release Process

### Step 1: Pre-Release Checks

- [ ] All code changes tested locally
- [ ] App runs without errors
- [ ] New features documented
- [ ] Version number decided (follow semantic versioning)

### Step 2: Update Version

Edit `Claw.xcconfig`:

```diff
- APP_VERSION = 1.0.0
+ APP_VERSION = 1.0.1
```

**Version Guidelines:**
- `1.0.0` → `1.0.1`: Bug fixes
- `1.0.0` → `1.1.0`: New features (backward compatible)
- `1.0.0` → `2.0.0`: Breaking changes

### Step 3: Build & Release

#### Using Fastlane Locally:

```bash
cd /Users/jamesrochabrun/Desktop/git/Claw/fastlane
bundle exec fastlane distribute_release
```

**What this does:**
1. ✅ Auto-increments version if conflicts detected
2. ✅ Builds app in Release mode (arm64)
3. ✅ Signs with Developer ID certificate
4. ✅ Signs ApprovalMCPServer and all binaries
5. ✅ Notarizes with Apple
6. ✅ Staples notarization ticket
7. ✅ Creates Sparkle ZIP (for automatic updates)
8. ✅ Creates DMG (for manual downloads)
9. ✅ Signs ZIP with EdDSA key
10. ✅ Updates appcast.xml with signature
11. ✅ Creates GitHub Release with ZIP + DMG
12. ✅ Creates PR with appcast.xml changes

**Time:** ~15-20 minutes (notarization takes ~5-10 min)

#### Using GitHub Actions:

```bash
# Trigger the workflow
git tag v1.0.1
git push origin v1.0.1
```

Then monitor: https://github.com/jamesrochabrun/Claw/actions

### Step 4: Review & Merge PR

1. Go to: https://github.com/jamesrochabrun/Claw/pulls
2. Find PR: "Release v1.0.1"
3. Review changes:
   - ✅ appcast.xml has correct version
   - ✅ EdDSA signature present
   - ✅ File size matches
   - ✅ Download URL correct
4. Merge to `main`

### Step 5: Verify Release

1. Check GitHub Release: https://github.com/jamesrochabrun/Claw/releases
2. Verify files uploaded:
   - `Claw.app.zip` (~8-9 MB)
   - `Claw.dmg` (~10-11 MB)
3. Test download links work

---

## 🧪 Testing Automatic Updates

### Test with Lower Version

1. Edit `Claw.xcconfig` temporarily:
   ```
   APP_VERSION = 0.9.0
   ```

2. Build and run locally:
   ```bash
   cd fastlane
   bundle exec fastlane build_debug
   open ../build/Debug/Claw.app
   ```

3. Wait ~30 seconds (or check manually)

4. App should detect v1.0.0 update from appcast.xml

5. Download, verify signature, and offer to install

### Check Logs

Open Console.app and filter:
- Subsystem: `com.claw.updates`
- Category: `sparkle`

You should see:
```
Update check started
Found update: v1.0.0
Signature valid
Downloading update...
```

---

## 📦 What Gets Created

### For Each Release:

#### 1. GitHub Release
**URL:** `https://github.com/jamesrochabrun/Claw/releases/tag/v1.0.1`

**Assets:**
- `Claw.app.zip` - For Sparkle automatic updates
- `Claw.dmg` - For manual downloads/new users

#### 2. Updated appcast.xml
**Location:** Main branch root

**Contains:**
```xml
<sparkle:version>1</sparkle:version>
<sparkle:shortVersionString>1.0.1</sparkle:shortVersionString>
<sparkle:edSignature>pJUw+c04L...</sparkle:edSignature>
<length>8781099</length>
<url>https://github.com/.../v1.0.1/Claw.app.zip</url>
```

#### 3. Pull Request
Automatic PR with:
- Updated appcast.xml
- Updated Claw.xcconfig
- Commit message: "Release v1.0.1"

---

## 🔧 Troubleshooting

### Build Fails

**Error: "Certificate not found"**
```bash
# Check your certificate
security find-identity -v -p codesigning

# Should see: Developer ID Application: James Rochabrun (CQ45U4X9K3)
```

**Error: "ApprovalMCPServer signature invalid"**
- Fixed! The Fastfile now automatically signs all binaries including ApprovalMCPServer

### Notarization Fails

**Check notarization log:**
```bash
# Get submission ID from Fastlane output
xcrun notarytool log <SUBMISSION_ID> \
  --key ~/private_keys/AuthKey_8TMY75VN79.p8 \
  --key-id 8TMY75VN79 \
  --issuer 69a6de98-2117-47e3-e053-5b8c7c11a4d1
```

**Common issues:**
- Unsigned nested binaries → Fixed in latest Fastfile
- Invalid entitlements → Check console output
- Hardened runtime missing → Already configured

### GitHub Release Fails

**Error: "Authentication failed"**
```bash
# Check GitHub token
security find-generic-password -s 'com.claw.GH_WRITE_TOKEN' -w

# Should return your token
```

**Error: "Tag already exists"**
- Fastlane auto-increments version if tag exists
- Or manually delete tag: `git push --delete origin v1.0.1`

### Updates Not Detected

**Check appcast.xml:**
```bash
curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
```

**Verify:**
- ✅ Version number is higher than installed version
- ✅ EdDSA signature present
- ✅ Download URL accessible
- ✅ File size matches actual ZIP

**Force update check:**
- Add manual "Check for Updates" menu item
- Or check Console.app logs for update errors

---

## 🚀 Best Practices

### Versioning

- **Patch (1.0.x)**: Bug fixes, minor improvements
- **Minor (1.x.0)**: New features, enhancements
- **Major (x.0.0)**: Breaking changes, major rewrites

### Testing

1. Always test the app locally before releasing
2. Test on a clean machine if possible
3. Verify automatic updates work before announcing

### Release Notes

Update the GitHub Release description with:
- What's new
- Bug fixes
- Known issues

### Rollback

If you need to rollback:
1. Create new release with previous version number +0.0.1
2. Revert code changes
3. Release as normal

---

## 🔐 Security Checklist

Before each release:

- [ ] `.sparkle_private_key` NOT in git
- [ ] `AuthKey_*.p8` NOT in git
- [ ] Secrets in keychain/GitHub Secrets only
- [ ] All binaries signed with Developer ID
- [ ] Notarization successful
- [ ] EdDSA signature valid

---

## 📞 Support

**Documentation:**
- SPARKLE_SETUP.md - Architecture details
- NEXT_ACTIONS.md - Initial setup guide
- RELEASE.md - Manual release process

**Issues:**
- Check Console.app logs (subsystem: com.claw.updates)
- Review Fastlane output for errors
- Verify certificates: `security find-identity -v -p codesigning`

---

## 🎯 Summary

**Complete Release in 4 Steps:**

1. Update `APP_VERSION` in Claw.xcconfig
2. Run `bundle exec fastlane distribute_release`
3. Review and merge auto-created PR
4. Done! Users get automatic updates

**Total Time:** ~20 minutes
**User Experience:** Seamless automatic updates ✨
