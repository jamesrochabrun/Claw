# Next Steps: Complete Sparkle Integration

Most of the Sparkle automatic updates implementation is complete! Here's what you need to do manually:

## ✅ Already Completed

- [x] AppUpdateService module created with all Swift files
- [x] Background update checking logic implemented
- [x] Sparkle integration with UpdateChecker and BackgroundUserDriver
- [x] Silent updates (no intrusive popups)
- [x] User privacy protected (no telemetry)
- [x] Integration with ClawApp.swift
- [x] Build script updated for Sparkle signing
- [x] Appcast template created
- [x] Key generation helper script created
- [x] Security measures (.gitignore updated)
- [x] Comprehensive documentation

## ⚠️ Manual Steps Required

### 1. Add Sparkle via Swift Package Manager (5 minutes)

You need to add Sparkle to your Xcode project:

1. Open `Claw.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the **Claw** target
4. Go to **General** tab → **Frameworks, Libraries, and Embedded Content**
5. Click the **+** button
6. Click **Add Package Dependency...**
7. Enter URL: `https://github.com/sparkle-project/Sparkle`
8. Version: Select "Up to Next Major Version" → 2.0.0
9. Click **Add Package**
10. Select **Sparkle** product → Click **Add Package**

### 2. Add New Files to Xcode Project (5 minutes)

Add the AppUpdateService files to your Xcode project:

1. In Xcode, right-click on the **Claw** folder in the Project Navigator
2. Select **Add Files to "Claw"...**
3. Navigate to `Claw/AppUpdateService/`
4. Select ALL files in the AppUpdateService folder:
   - Models.swift
   - AppUpdateService.swift
   - DefaultAppUpdateService.swift
   - UpdateChecker.swift
   - BackgroundUserDriver.swift
5. Make sure "Copy items if needed" is **unchecked** (files already in place)
6. Make sure "Add to targets" has **Claw** checked
7. Click **Add**

### 3. Update Info.plist with Sparkle Configuration (10 minutes)

#### Step A: Generate Keys

```bash
# First, build the project in Xcode to download Sparkle
# Then run:
./generate_sparkle_keys.sh
```

This will output:
```
SUPublicEDKey: abc123xyz...
Private key: xyz789abc...
```

#### Step B: Add to Info.plist

Option 1 - Via Xcode (Recommended):
1. Select the **Claw** target
2. Go to **Info** tab
3. Hover over any row and click the **+** button
4. Add key `SUFeedURL` (String):
   ```
   https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml
   ```
5. Add key `SUPublicEDKey` (String):
   ```
   YOUR_PUBLIC_KEY_FROM_STEP_A
   ```

Option 2 - Edit Info.plist directly:
```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/jamesrochabrun/Claw/main/appcast.xml</string>

<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY_FROM_STEP_A</string>
```

#### Step C: Store Private Key Securely

```bash
# Save to local file (in .gitignore)
echo 'YOUR_PRIVATE_KEY_FROM_STEP_A' > .sparkle_private_key
```

⚠️ **NEVER commit this file to git!** It's already in .gitignore.

### 4. Build and Test (5 minutes)

```bash
# Build the project in Xcode (⌘B)
# Run it to verify no compilation errors

# If you want to test the full release pipeline:
export SPARKLE_PRIVATE_KEY=$(cat .sparkle_private_key)
./build_and_notarize.sh
```

## 🎯 Quick Start Checklist

- [ ] Add Sparkle package dependency in Xcode
- [ ] Add AppUpdateService/*.swift files to Xcode project
- [ ] Build project once to download Sparkle
- [ ] Run `./generate_sparkle_keys.sh`
- [ ] Add SUFeedURL to Info.plist
- [ ] Add SUPublicEDKey to Info.plist (public key from script)
- [ ] Save private key to `.sparkle_private_key` file
- [ ] Build and run app (⌘R)
- [ ] Check logs for "Claw updates" to verify service is running

## 🔍 Verify It's Working

After completing the steps above:

1. Build and run the app in Xcode
2. Open Console.app
3. Filter for "claw" or "updates"
4. You should see logs like:
   ```
   [com.claw.updates] updaterMayCheck(forUpdates:)
   [com.claw.updates] No update available
   ```

## 📚 Documentation

See [`SPARKLE_SETUP.md`](./SPARKLE_SETUP.md) for:
- Complete architecture documentation
- Release process guide
- Security best practices
- Troubleshooting tips

## 🚀 Creating Your First Release with Updates

Once everything is set up:

```bash
# 1. Update version in Xcode (e.g., 1.0.3)
# 2. Build, sign, and create update
export SPARKLE_PRIVATE_KEY=$(cat .sparkle_private_key)
./build_and_notarize.sh

# 3. Create DMG
./create_dmg.sh

# 4. Create GitHub Release
# - Upload dist/Claw-1.0.3.dmg (manual distribution)
# - Upload build/Claw-1.0.3.zip (Sparkle updates)

# 5. Commit the updated appcast.xml
git add appcast.xml
git commit -m "Update appcast for v1.0.3"
git push
```

## ❓ Need Help?

- Check `SPARKLE_SETUP.md` for detailed documentation
- Review Sparkle's official docs: https://sparkle-project.org/documentation/
- Check the cmd app reference: https://github.com/getcmd-dev/cmd

## 🔐 Security Reminders

- ✅ Private key is in `.gitignore`
- ✅ Never commit `.sparkle_private_key` to git
- ✅ Store private key in password manager
- ✅ For CI/CD, use GitHub Secrets
- ✅ Public key in Info.plist is safe to commit
- ✅ No telemetry - `sendSystemProfile: false`
