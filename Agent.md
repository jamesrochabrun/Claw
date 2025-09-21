# Olive Agent Setup Documentation

## Setup Checklist

### 1. App Entitlements Configuration
Configure in `Olive.entitlements`:

**Removed Entitlements:**
- App Sandbox: Set to `NO` (removed `com.apple.security.app-sandbox`)
  - Required for full system access and screen recording capabilities

**Added Entitlements:**
- User Script Sandboxing: Set to `NO` (`com.apple.security.app-sandbox.user-scripts`)
  - Allows execution of user scripts without sandbox restrictions

### 2. Add Swift Packages
Add via Xcode's Swift Package Manager:
- https://github.com/jamesrochabrun/ClaudeCodeUI
- https://github.com/jamesrochabrun/ClaudeCodeApprovalServer (add the library, not the executable)

### 3. Add Run Script Phase
Add script to bundle approval server in app:
- Available as Run Script phase in Build Phases
- Bundles the approval server within the app