# Quick Start: Releasing Claw Updates

The simplest guide to release new versions of Claw.

---

## 🚀 Your First Release (Local)

### 1. Update Version
Edit `Claw.xcconfig`:
```
APP_VERSION = 1.0.1
```

### 2. Run Command
```bash
cd fastlane
bundle exec fastlane distribute_release
```

### 3. Wait (~20 min)
- Builds app
- Signs everything
- Notarizes with Apple
- Creates GitHub Release
- Creates PR

### 4. Merge PR
- Check GitHub for auto-created PR
- Review appcast.xml changes
- Merge to main

### 5. Done! ✨
- Users automatically get update
- New users download from GitHub Releases

---

## 🤖 Future Releases (Automated)

### Option A: Local Command (Always Works)
```bash
# Edit Claw.xcconfig: APP_VERSION = 1.0.2
cd fastlane
bundle exec fastlane distribute_release
# Review & merge PR
```

### Option B: GitHub Actions (After Setup)
```bash
# Edit Claw.xcconfig: APP_VERSION = 1.0.2
git add Claw.xcconfig
git commit -m "Bump to 1.0.2"
git push origin main
git tag v1.0.2
git push origin v1.0.2
# GitHub builds automatically
# Review & merge PR
```

---

## 📦 What Happens

### Automatic:
1. ✅ Builds Release app
2. ✅ Signs all binaries (including ApprovalMCPServer)
3. ✅ Notarizes with Apple
4. ✅ Creates Claw.app.zip (for auto-updates)
5. ✅ Creates Claw.dmg (for downloads)
6. ✅ Signs ZIP with Sparkle key
7. ✅ Updates appcast.xml
8. ✅ Uploads to GitHub Releases
9. ✅ Creates PR

### Manual:
1. ❌ Review PR
2. ❌ Merge to main

---

## 🧪 Testing

### Test Auto-Update:
```bash
# Temporarily change version to 0.9.0
# Build and run app
# Wait 30 seconds
# Should detect v1.0.0 update!
```

---

## 🆘 Troubleshooting

### Build fails?
```bash
# Check certificate
security find-identity -v -p codesigning
# Should see: Developer ID Application: James Rochabrun
```

### Notarization fails?
- Already fixed! ApprovalMCPServer signing is automated
- Check logs in Fastlane output

### Updates not detected?
```bash
# Check appcast.xml
curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
# Verify signature and version
```

---

## 📚 More Info

- **RELEASE_WORKFLOW.md** - Complete guide
- **GITHUB_SECRETS_SETUP.md** - Enable GitHub Actions
- **SPARKLE_SETUP.md** - Architecture details

---

## 🎯 Remember

**One Command Releases:**
```bash
cd fastlane && bundle exec fastlane distribute_release
```

**That's it!** Everything else is automatic. 🎉
