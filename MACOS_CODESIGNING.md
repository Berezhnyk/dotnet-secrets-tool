# macOS Code Signing Setup Guide

This guide explains how to set up code signing for macOS to eliminate Gatekeeper warnings.

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer account
2. **Developer ID Certificate**: Download from Apple Developer Portal
3. **Xcode Command Line Tools**: Install via `xcode-select --install`

## Step 1: Install Apple Developer Certificate

1. Log into [Apple Developer Portal](https://developer.apple.com/)
2. Go to **Certificates, Identifiers & Profiles** > **Certificates**
3. Click **+** to create a new certificate
4. Select **Developer ID Application** (for distributing outside App Store)
5. Follow the instructions to create a Certificate Signing Request (CSR)
6. Download the certificate and double-click to install it in Keychain

## Step 2: Verify Certificate Installation

```bash
# Check if certificate is installed
security find-identity -v -p codesigning

# You should see something like:
# 1) ABCDEF1234567890 "Developer ID Application: Your Name (TEAM123456)"
```

## Step 3: Set Up Environment Variables (for Notarization)

**Note:** These are only needed if you want to notarize your app. Code signing works without them.

```bash
# Add to your ~/.zshrc or ~/.bashrc
export APPLE_ID="your-apple-id@example.com"
export APPLE_PASSWORD="your-app-specific-password"  # NOT your regular Apple ID password!
export APPLE_TEAM_ID="YOUR_TEAM_ID"  # Found in Apple Developer Portal
```

**Important:** `APPLE_PASSWORD` is **NOT** your regular Apple ID password. It's a special "App-Specific Password" that you generate specifically for command-line tools.

## Step 4: Build and Sign

```bash
# Build the application
make publish

# Sign the binary
./scripts/codesign-macos.sh ./publish/osx-arm64/SecretsTool

# Optional: Notarize for wider distribution
./scripts/notarize-macos.sh ./publish/osx-arm64/SecretsTool

# Create signed distribution
make dist-signed
```

## Step 5: Verify Signing

```bash
# Check code signature
codesign --verify --verbose ./publish/osx-arm64/SecretsTool

# Check if notarized
spctl --assess --verbose ./publish/osx-arm64/SecretsTool
```

## Troubleshooting

### Certificate Not Found
If you get "certificate not found" errors:
1. Verify certificate is in Keychain Access
2. Check that it's a "Developer ID Application" certificate
3. Ensure it's not expired

### Notarization Failed
If notarization fails:
1. Check your Apple ID credentials
2. Ensure you have an active Apple Developer account
3. Verify your Team ID is correct
4. Check that the binary is properly signed first

### Keychain Access Issues
If you get keychain access errors:
```bash
# Allow codesign to access keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" [keychain-name]
```

## App-Specific Password Setup

**What is an App-Specific Password?**
An App-Specific Password is a special password that Apple generates for you to use with command-line tools and automated systems. It's **NOT** your regular Apple ID password.

**Why do you need it?**
- Your Apple ID has Two-Factor Authentication enabled
- Command-line tools can't handle 2FA prompts
- Apple requires these special passwords for security

**How to create one:**

1. Go to [Apple ID Account Management](https://appleid.apple.com/account/manage)
2. Sign in with your Apple ID (you may need to complete 2FA)
3. In the "Security" section, find "App-Specific Passwords"
4. Click "Generate Password"
5. Enter a label like "SecretsTool Notarization" (so you remember what it's for)
6. Apple will show you a password like: `abcd-efgh-ijkl-mnop`
7. Copy this password and use it for `APPLE_PASSWORD`

**Important Notes:**
- ✅ This password is ONLY for command-line tools
- ✅ You can create multiple app-specific passwords
- ✅ You can revoke them anytime if needed
- ❌ Don't use your regular Apple ID password
- ❌ Don't share this password with anyone

## Benefits of Code Signing

- ✅ Eliminates Gatekeeper warnings
- ✅ Users can run without security prompts
- ✅ Builds trust with users
- ✅ Required for distribution on Mac App Store
- ✅ Enables automatic updates in future versions

## Understanding Code Signing vs Notarization

### Code Signing (Required)
- **What it does:** Proves you created the app
- **Requirements:** Apple Developer Certificate only
- **Result:** Eliminates most Gatekeeper warnings
- **When to use:** Always for distribution

### Notarization (Optional but Recommended)
- **What it does:** Apple scans your app for malware
- **Requirements:** Code signing + Apple ID + App-Specific Password
- **Result:** Complete trust, no warnings at all
- **When to use:** For wider distribution or professional releases

### Do You Need Both?
- **Minimum:** Code signing (eliminates the main Gatekeeper error)
- **Recommended:** Code signing + Notarization (complete trust)

### For Your SecretsTool:
1. **Start with code signing** - This solves your immediate problem
2. **Add notarization later** - If you want maximum trust

## GitHub Actions Integration

The project is configured to automatically sign macOS binaries in GitHub Actions when you set up these secrets:

- `APPLE_CERTIFICATE`: Base64 encoded .p12 certificate
- `APPLE_CERTIFICATE_PASSWORD`: Password for the .p12 file
- `APPLE_TEAM_ID`: Your Apple Developer Team ID

To set up:
1. Export your certificate as .p12 from Keychain Access
2. Convert to base64: `base64 -i certificate.p12 | pbcopy`
3. Add as GitHub secret: `APPLE_CERTIFICATE`
4. Add certificate password as: `APPLE_CERTIFICATE_PASSWORD`
5. Add your Team ID as: `APPLE_TEAM_ID`
