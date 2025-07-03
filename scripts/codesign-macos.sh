#!/bin/bash

# Code signing script for macOS binaries
# Requires Apple Developer Certificate to be installed in Keychain

set -e

# Configuration
DEVELOPER_ID="Developer ID Application: YOUR_NAME (YOUR_TEAM_ID)"
BINARY_PATH="${1:-./publish/osx-arm64/SecretsTool}"
ENTITLEMENTS_FILE="./scripts/entitlements.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if binary exists
if [[ ! -f "$BINARY_PATH" ]]; then
    print_error "Binary not found at: $BINARY_PATH"
    exit 1
fi

# Check if Developer ID certificate is available
if ! security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    print_error "Developer ID Application certificate not found in Keychain"
    echo "Please install your Apple Developer certificate first:"
    echo "1. Download certificate from Apple Developer Portal"
    echo "2. Double-click to install in Keychain"
    exit 1
fi

# Get the actual certificate identity
CERT_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk -F'"' '{print $2}')

print_status "Using certificate: $CERT_IDENTITY"
print_status "Signing binary: $BINARY_PATH"

# Sign the binary
codesign --sign "$CERT_IDENTITY" \
         --options runtime \
         --entitlements "$ENTITLEMENTS_FILE" \
         --force \
         --timestamp \
         "$BINARY_PATH"

if [[ $? -eq 0 ]]; then
    print_success "Code signing completed successfully"
    
    # Verify the signature
    print_status "Verifying signature..."
    codesign --verify --verbose "$BINARY_PATH"
    
    if [[ $? -eq 0 ]]; then
        print_success "Signature verification passed"
    else
        print_error "Signature verification failed"
        exit 1
    fi
else
    print_error "Code signing failed"
    exit 1
fi

print_status "Binary is now properly signed and should not trigger Gatekeeper warnings"
