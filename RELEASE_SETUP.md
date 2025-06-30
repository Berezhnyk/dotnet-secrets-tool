# Release Setup Summary

This document summarizes the GitHub Actions setup for automated builds and releases.

## 🎯 What's Configured

### 1. Continuous Integration (CI)
- **File**: `.github/workflows/ci.yml`
- **Triggers**: Push to main/develop, Pull Requests
- **Actions**: 
  - Build and test on Windows, macOS, Linux
  - Validate CLI functionality
  - Test cross-platform builds

### 2. Automated Releases
- **File**: `.github/workflows/release.yml`
- **Triggers**: Git tags (v*) or manual dispatch
- **Actions**:
  - Build binaries for all platforms
  - Create GitHub release with assets
  - Generate checksums
  - Support beta/alpha releases

### 3. Beta Release Creation
- **File**: `.github/workflows/beta-release.yml`
- **Triggers**: Manual workflow dispatch
- **Actions**:
  - Validate version format
  - Create git tag
  - Trigger release workflow

## 📦 Release Assets

Each release includes:

### Windows
- `secretstool-win-x64.zip` (Windows x64)
- `secretstool-win-arm64.zip` (Windows ARM64)

### macOS  
- `secretstool-macos-x64.tar.gz` (Intel Mac)
- `secretstool-macos-arm64.tar.gz` (Apple Silicon)

### Linux
- `secretstool-linux-x64.tar.gz` (Linux x64)

### Additional Files
- `checksums.txt` (SHA256 checksums)
- Auto-generated release notes

## 🚀 How to Create Releases

### Beta Release (Recommended for testing)

1. Go to **Actions** tab in GitHub
2. Select **"Create Beta Release"** workflow  
3. Click **"Run workflow"**
4. Enter version: `1.0.0-beta.1`
5. Add optional changelog
6. Click **"Run workflow"**

The workflow will:
- Validate version format
- Create git tag
- Trigger automated build
- Publish release with binaries

### Production Release

1. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. The release workflow automatically runs and publishes binaries

## 📥 Installation Options

### Quick Install (macOS/Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/ivanberezhnyk/SecretsTool/main/scripts/install.sh | bash
```

### Manual Download
1. Go to [Releases page](https://github.com/ivanberezhnyk/SecretsTool/releases)
2. Download appropriate binary for your platform
3. Extract and add to PATH

### Build from Source
```bash
git clone https://github.com/ivanberezhnyk/SecretsTool.git
cd SecretsTool
dotnet build --project SecretsTool.csproj
```

## ✅ Next Steps

To publish your first beta release:

1. **Push to GitHub**: Commit all files to your repository
2. **Create Beta**: Use the "Create Beta Release" workflow
3. **Test Installation**: Download and test the binary
4. **Share**: Send download links to users

## 🔧 Troubleshooting

### Common Issues

**Build Failures:**
- Check .NET 8 SDK availability in runner
- Verify project file syntax
- Review workflow logs

**Release Asset Missing:**
- Check if all platforms built successfully
- Verify asset names match expected patterns
- Review download/upload artifact steps

**Installation Issues:**
- Verify executable permissions (Unix systems)
- Check if install directory is in PATH
- Test with full path to executable

## 📋 Checklist for First Release

- [ ] All workflows are in `.github/workflows/`
- [ ] Project builds successfully locally
- [ ] README.md updated with installation instructions
- [ ] Repository pushed to GitHub
- [ ] Ready to create first beta release

You're all set for automated releases! 🎉
