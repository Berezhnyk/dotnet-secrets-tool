#!/bin/bash

# GitLab Secrets Tool - Installation Script for macOS/Linux
# This script downloads and installs the latest release

set -e

REPO="berezhnyk/SecretsTool"
INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="SecretsTool"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $OS in
        darwin)
            OS="macos"
            ;;
        linux)
            OS="linux"
            ;;
        *)
            print_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    
    case $ARCH in
        x86_64)
            ARCH="x64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            print_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    PLATFORM="${OS}-${ARCH}"
    print_status "Detected platform: $PLATFORM"
}

# Get latest release info
get_latest_release() {
    print_status "Fetching latest release information..."
    
    RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
    
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch release information"
        exit 1
    fi
    
    TAG_NAME=$(echo "$RELEASE_INFO" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$TAG_NAME" ]; then
        print_error "Could not parse release tag"
        exit 1
    fi
    
    print_status "Latest release: $TAG_NAME"
}

# Download and install
install_tool() {
    ASSET_NAME="secretstool-${PLATFORM}.tar.gz"
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG_NAME/$ASSET_NAME"
    
    print_status "Downloading $ASSET_NAME..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download the release
    if ! curl -L -o "$ASSET_NAME" "$DOWNLOAD_URL"; then
        print_error "Failed to download $ASSET_NAME"
        print_error "URL: $DOWNLOAD_URL"
        exit 1
    fi
    
    # Extract
    print_status "Extracting archive..."
    tar -xzf "$ASSET_NAME"
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Move binary to install directory
    mv "$BINARY_NAME" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "GitLab Secrets Tool installed to $INSTALL_DIR/$BINARY_NAME"
}

# Check if install directory is in PATH
check_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "Install directory $INSTALL_DIR is not in your PATH"
        print_warning "Add the following line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo ""
        echo "    export PATH=\"\$PATH:$INSTALL_DIR\""
        echo ""
        print_warning "Or run the tool with full path: $INSTALL_DIR/$BINARY_NAME"
    else
        print_success "Install directory is in PATH. You can now run: $BINARY_NAME"
    fi
}

# Verify installation
verify_installation() {
    if [ -x "$INSTALL_DIR/$BINARY_NAME" ]; then
        print_status "Verifying installation..."
        VERSION_OUTPUT=$("$INSTALL_DIR/$BINARY_NAME" --help | head -n 1)
        print_success "Installation verified: $VERSION_OUTPUT"
        
        echo ""
        print_status "Usage example:"
        echo "    $BINARY_NAME --project-id YOUR_PROJECT_ID --token YOUR_GITLAB_TOKEN"
        echo ""
        print_status "For more help:"
        echo "    $BINARY_NAME --help"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Main installation flow
main() {
    echo "GitLab Secrets Tool - Installation Script"
    echo "========================================"
    echo ""
    
    detect_platform
    get_latest_release
    install_tool
    check_path
    verify_installation
    
    echo ""
    print_success "Installation completed successfully!"
}

# Run main function
main "$@"
