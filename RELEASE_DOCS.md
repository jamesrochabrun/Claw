# Claw Release Documentation

Quick guide to the release documentation.

---

## 🚀 Releasing Updates

### Start Here:
👉 **[QUICK_START_RELEASES.md](QUICK_START_RELEASES.md)** - TL;DR version

**One command to release:**
```bash
cd fastlane && bundle exec fastlane distribute_release
```

---

## 📚 Complete Guides

### [RELEASE_WORKFLOW.md](RELEASE_WORKFLOW.md)
Complete step-by-step release workflow with:
- Detailed process
- Troubleshooting
- Testing automatic updates
- Best practices

**Read this when:**
- First time releasing
- Something goes wrong
- Understanding the full process

---

## 🤖 GitHub Actions Setup

### [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)
How to enable automated releases via GitHub Actions.

**What you get:**
- Push a tag → Automatic build & release
- No local setup needed
- Build from any machine

**Setup time:** ~20 minutes

---

## 🏗️ Architecture

### [SPARKLE_SETUP.md](SPARKLE_SETUP.md)
How Sparkle automatic updates work.

**Covers:**
- Architecture overview
- Security (EdDSA signing)
- Update flow
- Configuration details

**Read this when:**
- Understanding how updates work
- Debugging update issues
- Making changes to update system

---

## 🎯 What Each Release Does

### Automatically:
1. ✅ Builds Claw.app (Release mode)
2. ✅ Signs all binaries (Developer ID)
3. ✅ Notarizes with Apple
4. ✅ Creates Claw.app.zip (Sparkle updates)
5. ✅ Creates Claw.dmg (manual downloads)
6. ✅ Signs ZIP with EdDSA key
7. ✅ Updates appcast.xml
8. ✅ Creates GitHub Release
9. ✅ Creates PR for review

### Manually:
1. ❌ Review PR
2. ❌ Merge to main

---

## 📦 Release Assets

Each release creates:
- **Claw.app.zip** (~8-9 MB) - For automatic updates
- **Claw.dmg** (~10-11 MB) - For new user downloads

Both uploaded to: `https://github.com/jamesrochabrun/Claw/releases`

---

## 🔄 Update Flow for Users

### New Users:
1. Download DMG from GitHub Releases
2. Install to Applications
3. Launch (notarized, no warnings)

### Existing Users:
1. App checks for updates hourly (background)
2. Finds new version in appcast.xml
3. Downloads ZIP, verifies signature
4. Shows notification
5. User clicks "Install"
6. **Automatic update!** ✨

---

## 🆘 Quick Troubleshooting

### Build fails?
```bash
security find-identity -v -p codesigning
# Should see: Developer ID Application: James Rochabrun (YOUR_TEAM_ID)
```

### Updates not detected?
```bash
curl https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
# Check version, signature, and URL
```

### More help?
- Check Console.app (subsystem: com.claw.updates)
- Review Fastlane output
- Read RELEASE_WORKFLOW.md troubleshooting section

---

## 📝 Quick Reference

| Task | Command |
|------|---------|
| Release update | `cd fastlane && bundle exec fastlane distribute_release` |
| Check certificates | `security find-identity -v -p codesigning` |
| Verify appcast | `curl https://raw.githubusercontent.com/.../appcast.xml` |
| Test build | `bundle exec fastlane build_release` |

---

**Need help? Start with [QUICK_START_RELEASES.md](QUICK_START_RELEASES.md)** 🚀
