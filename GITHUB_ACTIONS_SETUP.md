# GitHub Actions Code Signing Setup

## Required GitHub Secrets

You need to set up these secrets in your GitHub repository for **code signing**:

### 1. APPLE_CERTIFICATE (Required)
- **What it is:** Your Developer ID Application certificate in base64 format
- **How to get it:** 
  1. Export your certificate using: `./scripts/export-certificate.sh`
  2. Convert to base64: `base64 -i developer_id_certificate.p12 | pbcopy`
  3. Paste the base64 output as the secret value

### 2. APPLE_CERTIFICATE_PASSWORD (Required)
- **What it is:** The password you used when exporting the certificate
- **How to get it:** Use the same password you entered in the export script

### 3. APPLE_TEAM_ID (Required)
- **What it is:** Your Apple Developer Team ID
- **How to get it:** 
  1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
  2. Look for "Team ID" in the top right corner
  3. It looks like: `ABC123XYZ9`

## Optional GitHub Secrets (for Notarization)

Add these secrets for **complete Gatekeeper bypass** (recommended):

### 4. APPLE_ID (Optional but Recommended)
- **What it is:** Your Apple ID email address
- **Example:** `your-email@example.com`

### 5. APPLE_PASSWORD (Optional but Recommended)
- **What it is:** An App-Specific Password for notarization
- **How to get it:**
  1. Go to [Apple ID Account Management](https://appleid.apple.com/account/manage)
  2. Sign in and complete 2FA
  3. In "Security" section, click "Generate Password" under "App-Specific Passwords"
  4. Enter label: "GitHub Actions Notarization"
  5. Use the generated password (format: `abcd-efgh-ijkl-mnop`)

## Benefits of Each Level

### Code Signing Only (3 secrets)
✅ Eliminates most Gatekeeper warnings
✅ Establishes developer identity
⚠️ May still show warnings on first download

### Code Signing + Notarization (5 secrets)
✅ Eliminates ALL Gatekeeper warnings
✅ Complete trust on first download
✅ No user interaction required
✅ Professional-grade distribution

## Setting Up GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each of the three secrets above

## Finding Your Team ID

Your Team ID is displayed in several places:
- Apple Developer Portal (top right when logged in)
- In your certificate name: "Developer ID Application: Your Name (**TEAM123456**)"
- In Xcode: Preferences → Accounts → View Details

## Testing the Setup

After setting up the secrets, create a release to test:

1. Tag a new version: `git tag v1.0.3 && git push origin v1.0.3`
2. Check the GitHub Actions run
3. Verify the macOS binaries are signed in the release artifacts

## What Happens During GitHub Actions Build

1. **Certificate Import:** GitHub Actions imports your certificate into a temporary keychain
2. **Code Signing:** The macOS binary is signed with your Developer ID
3. **Verification:** The signature is verified before packaging
4. **Archive Creation:** The signed binary is packaged for distribution

## Security Notes

- ✅ GitHub encrypts all secrets
- ✅ Secrets are only accessible during workflow runs
- ✅ Certificate is imported into a temporary keychain that's destroyed after the build
- ✅ Your private key never leaves the secure environment

## Troubleshooting

### "Certificate not found" error
- Check that `APPLE_CERTIFICATE` is properly base64 encoded
- Verify `APPLE_CERTIFICATE_PASSWORD` is correct
- Ensure the certificate hasn't expired

### "Team ID not found" error
- Double-check your `APPLE_TEAM_ID` matches exactly
- Make sure there are no extra spaces or characters

### Build fails on macOS
- Check the GitHub Actions logs for specific error messages
- Ensure all three secrets are set correctly
- Verify your Apple Developer account is active
