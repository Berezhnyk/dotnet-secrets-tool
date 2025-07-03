#!/bin/bash

# Script to create Certificate Signing Request (CSR) for Apple Developer ID

echo "Creating Certificate Signing Request (CSR) for Apple Developer ID..."

# Prompt for information
read -p "Enter your full name (e.g., John Doe): " FULL_NAME
read -p "Enter your email address: " EMAIL_ADDRESS
read -p "Enter your country code (e.g., US, CA, GB): " COUNTRY_CODE

# Create CSR
openssl req -new -newkey rsa:2048 -nodes -keyout developer_id_private_key.pem -out developer_id_csr.csr -subj "/C=$COUNTRY_CODE/ST=/L=/O=$FULL_NAME/OU=/CN=$FULL_NAME/emailAddress=$EMAIL_ADDRESS"

echo ""
echo "✅ Certificate Signing Request created successfully!"
echo ""
echo "Files created:"
echo "  📄 developer_id_csr.csr - Upload this to Apple Developer Portal"
echo "  🔐 developer_id_private_key.pem - Keep this private key safe!"
echo ""
echo "Next steps:"
echo "1. Upload 'developer_id_csr.csr' to Apple Developer Portal"
echo "2. Download the certificate from Apple"
echo "3. Double-click the certificate to install it in Keychain"
echo "4. Keep 'developer_id_private_key.pem' secure (needed for the certificate to work)"
echo ""
echo "⚠️  IMPORTANT: Do not share or commit the private key file!"
echo "⚠️  Clean up files after use: rm developer_id_csr.csr developer_id_private_key.pem"
