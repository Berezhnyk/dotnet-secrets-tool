# GitLab Secrets Tool

A .NET 8 CLI tool that fetches GitLab CI/CD project-level variables via the GitLab API and writes them into the .NET user secrets storage.

## Installation

### Option 1: Download Pre-built Binaries (Recommended)

Download the latest release from the [GitHub Releases page](https://github.com/berezhnyk/dotnet-secrets-tool/releases).

#### Quick Install Scripts

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/berezhnyk/dotnet-secrets-tool/main/scripts/install.sh | bash
```

**Windows (PowerShell):**
```powershell
# Download and run install.bat manually from GitHub releases
```

#### Manual Installation

1. Go to [Releases](https://github.com/berezhnyk/dotnet-secrets-tool/releases)
2. Download the appropriate archive for your platform:
   - `secretstool-win-x64.zip` - Windows x64
   - `secretstool-win-arm64.zip` - Windows ARM64
   - `secretstool-macos-x64.tar.gz` - macOS Intel
   - `secretstool-macos-arm64.tar.gz` - macOS Apple Silicon
   - `secretstool-linux-x64.tar.gz` - Linux x64
3. Extract the executable
4. Add to your PATH or run directly

##### macOS Code Signing and Notarization

If you encounter the error "Apple could not verify 'SecretsTool' is free of malware that may harm your Mac or compromise your privacy", this is due to macOS Gatekeeper security. Here are the solutions:

**For End Users (Quick Fix):**
```bash
# Remove quarantine flag
xattr -d com.apple.quarantine ~/Downloads/SecretsTool

# Move to bin folder (requires sudo)
sudo mv ~/Downloads/SecretsTool /usr/local/bin/SecretsTool

# Make executable (only if you encounter permission errors)
sudo chmod +x /usr/local/bin/SecretsTool
```

**For Developers with Apple Developer Account:**

If you're building from source and have an Apple Developer account, you can properly code sign the application:

**Option A: Local Code Signing**
1. **Install your Apple Developer Certificate:**
   - Download your "Developer ID Application" certificate from Apple Developer Portal
   - Double-click to install it in your Keychain

2. **Build and sign the application:**
   ```bash
   # Build for your platform
   make publish
   
   # Sign the binary (requires Apple Developer Certificate)
   ./scripts/codesign-macos.sh ./publish/osx-arm64/SecretsTool
   
   # Optional: Notarize for wider distribution
   export APPLE_ID="your-apple-id@example.com"
   export APPLE_PASSWORD="your-app-specific-password"
   export APPLE_TEAM_ID="YOUR_TEAM_ID"
   ./scripts/notarize-macos.sh ./publish/osx-arm64/SecretsTool
   ```

**Option B: GitHub Actions Code Signing (Recommended)**
1. **Set up certificates for automated signing:**
   ```bash
   # Export your certificate for GitHub Actions
   ./scripts/export-certificate.sh
   
   # Convert to base64 for GitHub secrets
   base64 -i developer_id_certificate.p12 | pbcopy
   ```

2. **Add GitHub Secrets:**
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Add these secrets:
     - `APPLE_CERTIFICATE`: (paste the base64 certificate)
     - `APPLE_CERTIFICATE_PASSWORD`: (password you used when exporting)
     - `APPLE_TEAM_ID`: (your Team ID from Apple Developer Portal)

3. **Create signed releases:**
   ```bash
   # Create a new release - GitHub Actions will automatically sign it
   git tag v1.0.3
   git push origin v1.0.3
   ```

See `GITHUB_ACTIONS_SETUP.md` for detailed setup instructions.

**Setting up App-Specific Password:**
1. Go to [Apple ID Account Management](https://appleid.apple.com/account/manage)
2. Sign in with your Apple ID
3. In the "Security" section, click "Generate Password" under "App-Specific Passwords"
4. Enter a label (e.g., "SecretsTool Notarization")
5. Use this password for the `APPLE_PASSWORD` environment variable

**Benefits of Code Signing:**
- Eliminates Gatekeeper warnings
- Users can run the application without security prompts
- Builds trust with your users
- Required for Mac App Store distribution (if applicable)

##### macOS Quarantine Workaround (Alternative)

If you encounter the error "Apple could not verify 'SecretsTool' is free of malware that may harm your Mac or compromise your privacy", you can resolve this by removing the quarantine flag and installing the tool manually:

```bash
# Remove quarantine flag
xattr -d com.apple.quarantine ~/Downloads/SecretsTool

# Move to bin folder (requires sudo)
sudo mv ~/Downloads/SecretsTool /usr/local/bin/SecretsTool

# Make executable (only if you encounter permission errors)
sudo chmod +x /usr/local/bin/SecretsTool
```

After these steps, you should be able to run `SecretsTool` from anywhere in your terminal.

### Option 2: Build from Source

1. Clone this repository
2. Build the project:
   ```bash
   dotnet build --project SecretsTool.csproj
   ```

### Option 3: Using Make (macOS/Linux)

```bash
# Build for current platform
make build

# Build and publish for current platform
make publish

# Build for all platforms
make publish-all

# Create distribution archives
make dist

# Create signed distribution (macOS with Developer Certificate)
make dist-signed
```

**Available Make targets:**
- `make build` - Build the project
- `make publish` - Publish single-file executable for current platform
- `make publish-all` - Publish for all platforms
- `make codesign-macos` - Code sign macOS binaries (requires Apple Developer Certificate)
- `make dist` - Create distribution archives
- `make dist-signed` - Create signed distribution archives (macOS only)
- `make install` - Install locally for testing
- `make clean` - Clean build artifacts
- `make help` - Show all available targets

### Option 4: Publish Self-Contained Executables

To create standalone executables for different platforms:

```bash
make publish
```

This will create executables in the `./publish/` directory for:
- Windows (x64 and ARM64)
- macOS (x64 and ARM64)
- Linux (x64)

## Usage

```bash
dotnet run -- --project-id <PROJECT_ID> [OPTIONS]
```

### Required Arguments

- `--project-id`: GitLab project ID

### Optional Arguments

- `--token`: GitLab Personal Access Token (can also be set via `GITLAB_TOKEN` environment variable)
- `--gitlab-url`: Base URL for GitLab API (default: `https://gitlab.com`)
- `--prefix`: Prefix to filter variables (e.g., `SECRET_`). Default: no filtering
- `--environment`: Filter variables by environment scope (includes variables that apply to all environments)
- `--user-secrets-id`: Explicit UserSecretsId. If not provided, the tool will try to find a `.csproj` file in the current directory and extract the `<UserSecretsId>` from it
- `--only-new`: If set, only add variables that do not already exist in secrets.json

### Examples

1. Basic usage with environment variable:
   ```bash
   export GITLAB_TOKEN=your_gitlab_token
   dotnet run -- --project-id 12345
   ```

2. With explicit token and prefix filter:
   ```bash
   dotnet run -- --project-id 12345 --token your_token --prefix SECRET_
   ```

3. Filter by environment (e.g., production):
   ```bash
   dotnet run -- --project-id 12345 --environment production
   ```

4. Combine filters (prefix and environment):
   ```bash
   dotnet run -- --project-id 12345 --prefix API_ --environment staging
   ```

5. Using custom GitLab instance and explicit UserSecretsId:
   ```bash
   dotnet run -- --project-id 12345 --gitlab-url https://gitlab.company.com --user-secrets-id my-secrets-id
   ```

6. Only add new variables (don't overwrite existing):
   ```bash
   dotnet run -- --project-id 12345 --only-new
   ```

## Features

- **Cross-platform**: Works on Windows, macOS, and Linux
- **Smart UserSecretsId detection**: Automatically finds UserSecretsId from .csproj files
- **Flexible authentication**: Use token argument or environment variable
- **Variable filtering**: Filter variables by prefix and/or environment scope
- **Environment-aware**: Includes variables that apply to all environments when filtering by specific environment
- **Safe merging**: Option to only add new variables without overwriting existing ones
- **Comprehensive error handling**: Meaningful error messages for common issues
- **Summary reporting**: Shows how many variables were fetched, added, or skipped

## User Secrets Path Resolution

The tool correctly resolves the secrets path for each platform:

- **Windows**: `%APPDATA%\Microsoft\UserSecrets\<UserSecretsId>\secrets.json`
- **macOS/Linux**: `~/.microsoft/usersecrets/<UserSecretsId>/secrets.json`

## Requirements

- .NET 8.0 or later
- GitLab Personal Access Token with `api` scope
- Project must have UserSecretsId configured (either in .csproj or provided via argument)

## Error Handling

The tool provides clear error messages for common scenarios:

- Missing GitLab token
- Missing project ID
- UserSecretsId not found
- GitLab API errors
- File system access issues

## GitLab API

The tool uses the GitLab API endpoint: `GET /projects/:id/variables`

Make sure your Personal Access Token has the `api` scope to access project variables.

### Environment Filtering

When using the `--environment` option, the tool will include:

1. **Variables specific to the requested environment**: Variables with `environment_scope` matching the specified environment
2. **Global variables**: Variables with `environment_scope` set to `*` (wildcard) or empty/null (applies to all environments)

This ensures you get both environment-specific variables and global variables that should be available in all environments.

**Example GitLab Variable Scopes:**
- `environment_scope: "*"` → Included in all environment filters
- `environment_scope: "production"` → Only included when filtering for "production"
- `environment_scope: "staging"` → Only included when filtering for "staging"
- `environment_scope: null/empty` → Included in all environment filters

## Development

### Creating Releases

This project uses GitHub Actions for automated builds and releases.

#### Beta Releases

To create a beta release:

1. Go to the [Actions tab](https://github.com/berezhnyk/dotnet-secrets-tool/actions)
2. Select "Create Beta Release" workflow
3. Click "Run workflow"
4. Enter a version like `1.0.0-beta.1`
5. Optionally add changelog notes

#### Production Releases

To create a production release:

1. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. The release workflow will automatically build and publish binaries

### GitHub Actions Workflows

- **CI**: Runs on every push and PR to test builds across platforms
- **Release**: Triggered by tags, builds and publishes release binaries
- **Beta Release**: Manual workflow to create beta releases

All releases include:
- Cross-platform binaries (Windows, macOS, Linux)
- SHA256 checksums
- Automated release notes
