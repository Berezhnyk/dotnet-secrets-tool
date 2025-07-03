#!/bin/bash

# Script to help export Apple Developer certificate for GitHub Actions

echo "🔐 Exporting Apple Developer Certificate for GitHub Actions"
echo "=================================================="
echo ""

# Check if certificate exists
if ! security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "❌ Developer ID Application certificate not found in Keychain"
    echo "Please create and install your certificate first:"
    echo "1. Go to Apple Developer Portal"
    echo "2. Create 'Developer ID Application' certificate"
    echo "3. Download and install it in Keychain"
    exit 1
fi

# Get certificate name
CERT_NAME=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk -F'"' '{print $2}')
echo "✅ Found certificate: $CERT_NAME"
echo ""

# Prompt for password
echo "Enter a password to protect the exported certificate:"
read -s EXPORT_PASSWORD
echo ""

# Export certificate
OUTPUT_FILE="developer_id_certificate.p12"
echo "📤 Exporting certificate to: $OUTPUT_FILE"

security export -k login.keychain -t identities -f pkcs12 -P "$EXPORT_PASSWORD" -o "$OUTPUT_FILE" "$CERT_NAME"

if [[ $? -eq 0 ]]; then
    echo "✅ Certificate exported successfully!"
    echo ""
    echo "📋 Next steps for GitHub Actions:"
    echo "================================="
    echo ""
    echo "1. Convert certificate to base64:"
    echo "   base64 -i $OUTPUT_FILE | pbcopy"
    echo ""
    echo "2. Go to your GitHub repository settings"
    echo "3. Go to Settings > Secrets and variables > Actions"
    echo "4. Add these secrets:"
    echo "   • APPLE_CERTIFICATE: (paste the base64 output)"
    echo "   • APPLE_CERTIFICATE_PASSWORD: $EXPORT_PASSWORD"
    echo "   • APPLE_TEAM_ID: (your Team ID from Apple Developer Portal)"
    echo ""
    echo "5. Run the base64 command above to copy the certificate to clipboard"
    echo ""
    echo "⚠️  IMPORTANT: Keep the password and .p12 file secure!"
    echo "⚠️  Delete the .p12 file after setting up GitHub secrets:"
    echo "   rm $OUTPUT_FILE"
else
    echo "❌ Certificate export failed"
    exit 1
fi
