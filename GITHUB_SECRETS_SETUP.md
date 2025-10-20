# GitHub Secrets Setup Guide

Complete guide for configuring GitHub Secrets to enable automated releases.

---

## 📍 Where to Add Secrets

1. Go to: https://github.com/jamesrochabrun/Claw/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret below

---

## 🔑 Required Secrets (9 total)

### 1. MATCH_PASSWORD

**What it is:** Encryption password for Fastlane Match certificate repository

**How to get the value:**

From your secure notes where you saved it during setup, OR retrieve from keychain:

```bash
security find-generic-password -s 'com.claw.MATCH_PASSWORD' -w | base64 -D
```

**Steps:**
- Name: `MATCH_PASSWORD`
- Secret: Paste your Match password
- Click "Add secret"

---

### 2. FASTLANE_GITHUB_ACCESS_TOKEN

**What it is:** GitHub Personal Access Token for creating releases

**How to get the value:**

Retrieve from keychain:
```bash
security find-generic-password -s 'com.claw.FASTLANE_GITHUB_ACCESS_TOKEN' -w | base64 -D
```

OR create new token at: https://github.com/settings/tokens (requires "repo" scope)

**Steps:**
- Name: `FASTLANE_GITHUB_ACCESS_TOKEN`
- Secret: Paste your GitHub token (starts with `ghp_`)
- Click "Add secret"

---

### 3. GH_WRITE_TOKEN

**What it is:** Same as FASTLANE_GITHUB_ACCESS_TOKEN (used for PRs)

**How to get the value:**

Same token as above:
```bash
security find-generic-password -s 'com.claw.GH_WRITE_TOKEN' -w | base64 -D
```

**Steps:**
- Name: `GH_WRITE_TOKEN`
- Secret: Paste the same token as FASTLANE_GITHUB_ACCESS_TOKEN
- Click "Add secret"

---

### 4. NOTARY_KEY_ID

**What it is:** App Store Connect API Key ID for notarization

**How to get the value:**

1. Go to: https://appstoreconnect.apple.com/access/api
2. Click on your API key
3. Copy the "Key ID" (10 characters)

**Steps:**
- Name: `NOTARY_KEY_ID`
- Secret: Paste your Key ID from App Store Connect
- Click "Add secret"

---

### 5. NOTARY_ISSUER_ID

**What it is:** App Store Connect Issuer ID for notarization

**How to get the value:**

1. Go to: https://appstoreconnect.apple.com/access/api
2. Find "Issuer ID" at the top of the page
3. Copy the UUID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

**Steps:**
- Name: `NOTARY_ISSUER_ID`
- Secret: Paste your Issuer ID from App Store Connect
- Click "Add secret"

---

### 6. NOTARY_P8

**What it is:** Base64-encoded App Store Connect API Key (.p8 file contents)

**How to get the value:**

Run this command in Terminal (replace YOUR_KEY_ID with your actual Key ID):
```bash
cat ~/private_keys/AuthKey_YOUR_KEY_ID.p8 | base64
```

Copy the output (it will be a long base64 string).

**Steps:**
- Name: `NOTARY_P8`
- Secret: Paste the base64 output
- Click "Add secret"

**Example output format:**
```
LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZ0pjODB1ckNIMEQxVHNYY1cKSmNMbExrTXBJaTYwQUd1MmhNNjFxVVRDMkttZ0NnWUlLb1pJemowREFRZWhSQU5DQUFUeklRYk54Unc...
```

---

### 7. SPARKLE_SECRET_KEY

**What it is:** Sparkle EdDSA private key for signing updates

**How to get the value:**

From the `.sparkle_private_key` file in your repo (not committed to git):
```bash
cat .sparkle_private_key
```

OR from keychain:
```bash
security find-generic-password -s 'com.claw.SPARKLE_SECRET_KEY' -w | base64 -D
```

**Steps:**
- Name: `SPARKLE_SECRET_KEY`
- Secret: Paste the Sparkle private key (base64 string)
- Click "Add secret"

**⚠️ Important:** This is your Sparkle private key - keep it secret! Anyone with this key can sign fake updates.

---

### 8. APPLE_TEAM_ID

**What it is:** Your Apple Developer Team ID

**How to get the value:**

1. Go to: https://developer.apple.com/account
2. Click "Membership" in the sidebar
3. Find your "Team ID" (10 characters)

**Steps:**
- Name: `APPLE_TEAM_ID`
- Secret: Paste your Team ID from Apple Developer
- Click "Add secret"

---

### 9. CERTIFICATE_SHA1

**What it is:** SHA1 fingerprint of your Developer ID certificate

**How to get the value:**

Run this command in Terminal:
```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
```

Copy the 40-character SHA1 hash (first value in parentheses).

**Steps:**
- Name: `CERTIFICATE_SHA1`
- Secret: Paste your certificate SHA1 hash
- Click "Add secret"

---

## ✅ Verification Checklist

After adding all secrets, verify:

- [ ] 9 secrets total in repository settings
- [ ] All secret names match exactly (case-sensitive)
- [ ] No trailing spaces or newlines in values
- [ ] NOTARY_P8 is base64-encoded (not raw .p8 content)
- [ ] GitHub tokens have "repo" scope

---

## 🧪 Test GitHub Actions

After adding secrets, test the workflow:

### Option 1: Manual Workflow Dispatch

1. Go to: https://github.com/jamesrochabrun/Claw/actions/workflows/release.yml
2. Click "Run workflow"
3. Select branch: `main`
4. Click "Run workflow"
5. Monitor the build

### Option 2: Push a Tag

```bash
git tag v1.0.0-test
git push origin v1.0.0-test
```

Then check: https://github.com/jamesrochabrun/Claw/actions

---

## 🔐 Security Best Practices

### Secrets Management

✅ **DO:**
- Keep secrets in GitHub Secrets only
- Rotate tokens periodically (every 90 days)
- Use fine-grained GitHub tokens when possible
- Monitor secret access in audit logs

❌ **DON'T:**
- Commit secrets to git
- Share secrets in issues/PRs
- Use the same token for multiple purposes
- Log secrets in workflow outputs

### Token Permissions

Your GitHub token needs **only** these scopes:
- ✅ `repo` (full repository access)

You **don't** need:
- ❌ `workflow`
- ❌ `admin:org`
- ❌ Other scopes

### Rotating Secrets

If you need to rotate secrets:

1. Generate new value (token, key, etc.)
2. Update GitHub Secret
3. Test workflow
4. Revoke old value

---

## 🆘 Troubleshooting

### "Secret not found" Error

**Check:**
- Secret name matches exactly (case-sensitive)
- Secret exists in correct repository
- You're using Actions secrets (not Dependabot/Codespaces secrets)

**Fix:**
```bash
# Verify secrets exist
gh secret list
```

### "Invalid base64" Error (NOTARY_P8)

**Problem:** The P8 content wasn't properly encoded

**Fix:**
```bash
# Re-encode the P8 file
cat ~/private_keys/AuthKey_8TMY75VN79.p8 | base64 | tr -d '\n'

# Copy output and update secret
```

### "Authentication failed" Error

**Problem:** GitHub token is invalid or lacks permissions

**Fix:**
1. Go to: https://github.com/settings/tokens
2. Check token hasn't expired
3. Verify "repo" scope is enabled
4. Generate new token if needed
5. Update both `FASTLANE_GITHUB_ACCESS_TOKEN` and `GH_WRITE_TOKEN`

### Workflow Fails Immediately

**Check workflow logs:**
1. Go to Actions tab
2. Click failed workflow
3. Expand "Run Fastlane distribute_release"
4. Look for which secret is missing/invalid

---

## 📋 Quick Reference

| Secret Name | Source | Format |
|-------------|--------|--------|
| `MATCH_PASSWORD` | Generated earlier | Plain text |
| `FASTLANE_GITHUB_ACCESS_TOKEN` | github.com/settings/tokens | ghp_... |
| `GH_WRITE_TOKEN` | Same as above | ghp_... |
| `NOTARY_KEY_ID` | App Store Connect | 10 chars |
| `NOTARY_ISSUER_ID` | App Store Connect | UUID |
| `NOTARY_P8` | Base64 of .p8 file | Base64 |
| `SPARKLE_SECRET_KEY` | From .sparkle_private_key | Base64 key |
| `APPLE_TEAM_ID` | Apple Developer | 10 chars |
| `CERTIFICATE_SHA1` | Certificate fingerprint | 40 hex chars |

---

## 🎯 Next Steps

After adding all secrets:

1. ✅ Test GitHub Actions workflow
2. ✅ Read RELEASE_WORKFLOW.md
3. ✅ Try your first automated release!

---

## 📞 Support

**Can't find a value?**
- Match password: Check your secure notes from setup
- GitHub token: https://github.com/settings/tokens
- Notary credentials: https://appstoreconnect.apple.com/access/api
- Sparkle key: File `.sparkle_private_key` in repo root (not committed)

**Still stuck?**
- Check the Fastfile for helper functions (`load_secret`)
- Review logs in Console.app
- Verify keychain has secrets: `security find-generic-password -s 'com.claw.MATCH_PASSWORD'`
