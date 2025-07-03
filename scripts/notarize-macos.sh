#!/bin/bash

# Notarization script for macOS binaries
# Requires Apple Developer account and App Store Connect API key

set -e

# Configuration
BINARY_PATH="${1:-./publish/osx-arm64/SecretsTool}"
BUNDLE_ID="com.yourcompany.secretstool"  # Update with your bundle ID
APPLE_ID="${APPLE_ID:-}"                 # Set via environment variable
APPLE_PASSWORD="${APPLE_PASSWORD:-}"     # App-specific password
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"      # Your Team ID

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if binary exists
if [[ ! -f "$BINARY_PATH" ]]; then
    print_error "Binary not found at: $BINARY_PATH"
    exit 1
fi

# Check if binary is already signed
if ! codesign --verify --verbose "$BINARY_PATH" 2>/dev/null; then
    print_error "Binary must be code signed before notarization"
    echo "Run: ./scripts/codesign-macos.sh $BINARY_PATH"
    exit 1
fi

# Check required environment variables
if [[ -z "$APPLE_ID" || -z "$APPLE_PASSWORD" || -z "$APPLE_TEAM_ID" ]]; then
    print_error "Missing required environment variables:"
    echo "  APPLE_ID - Your Apple ID email"
    echo "  APPLE_PASSWORD - App-specific password"
    echo "  APPLE_TEAM_ID - Your Team ID"
    echo ""
    echo "Generate app-specific password at: https://appleid.apple.com/account/manage"
    exit 1
fi

# Create a temporary directory for notarization
TEMP_DIR=$(mktemp -d)
ARCHIVE_PATH="$TEMP_DIR/SecretsTool.zip"

print_status "Creating archive for notarization..."
ditto -c -k --keepParent "$BINARY_PATH" "$ARCHIVE_PATH"

print_status "Submitting for notarization..."
NOTARIZATION_RESULT=$(xcrun notarytool submit "$ARCHIVE_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait \
    --output-format json)

# Parse the result
if echo "$NOTARIZATION_RESULT" | jq -e '.status == "Accepted"' > /dev/null 2>&1; then
    print_success "Notarization successful!"
    
    # Staple the notarization to the binary
    print_status "Stapling notarization..."
    xcrun stapler staple "$BINARY_PATH"
    
    if [[ $? -eq 0 ]]; then
        print_success "Notarization stapled successfully"
        
        # Verify the stapling
        print_status "Verifying stapling..."
        xcrun stapler validate "$BINARY_PATH"
        
        if [[ $? -eq 0 ]]; then
            print_success "Notarization validation passed"
            print_success "Binary is now notarized and ready for distribution"
        else
            print_warning "Stapling validation failed, but notarization was successful"
        fi
    else
        print_warning "Stapling failed, but notarization was successful"
    fi
else
    print_error "Notarization failed"
    if command -v jq &> /dev/null; then
        echo "Status: $(echo "$NOTARIZATION_RESULT" | jq -r '.status // "Unknown"')"
        echo "Message: $(echo "$NOTARIZATION_RESULT" | jq -r '.statusSummary // "No message"')"
    else
        echo "Raw result: $NOTARIZATION_RESULT"
    fi
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"

print_status "Notarization process completed successfully"
