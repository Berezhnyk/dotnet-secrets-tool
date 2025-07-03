# Repository Security - Clean Files Guide

## Files That Should NEVER Be Committed

### 🔐 Certificate and Key Files
- `*.pem` - Private keys
- `*.p12` - Certificate packages
- `*.csr` - Certificate signing requests
- `*.cer` - Certificate files
- `*.key` - Private keys
- `*.cert` - Certificate files

### 🗂️ Build Artifacts
- `bin/` - Compiled binaries
- `obj/` - Build objects
- `publish/` - Published applications
- `dist/` - Distribution packages

### 🗃️ Temporary Files
- `*.tmp` - Temporary files
- `*.temp` - Temporary files
- `*.cache` - Cache files
- `*.bak` - Backup files
- `*.swp` - Vim swap files
- `*.swo` - Vim swap files
- `*~` - Backup files

### 🍎 System Files
- `.DS_Store` - macOS system files
- `Thumbs.db` - Windows system files

## Cleanup Commands

### Manual Cleanup
```bash
# Remove all sensitive files
rm -f *.pem *.p12 *.csr *.cer *.key *.cert

# Remove build artifacts
rm -rf bin obj publish dist

# Remove temporary files
rm -f *.tmp *.temp *.bak *.swp *.swo *~

# Remove system files
rm -f .DS_Store Thumbs.db
```

### Automated Cleanup
```bash
# Run cleanup script
./scripts/cleanup.sh

# Or use Makefile
make clean-all
```

## Git Protection

The `.gitignore` file is configured to automatically ignore these files:

```gitignore
# Ignore build artifacts
bin/
obj/
publish/
dist/

# Ignore IDE files
.vs/
.vscode/
*.user
*.suo

# Ignore NuGet packages
*.nupkg
*.snupkg

# Ignore OS generated files
.DS_Store
Thumbs.db

# Ignore logs
*.log

# Ignore temporary files
*.tmp
*.temp
*.cache
*.bak
*.swp
*.swo
*~

# Ignore certificates and private keys
*.pem
*.p12
*.csr
*.cer
*.key
*.cert
```

## Best Practices

1. **Always run cleanup before committing:**
   ```bash
   ./scripts/cleanup.sh
   git add .
   git commit -m "Your commit message"
   ```

2. **Check git status before committing:**
   ```bash
   git status
   # Make sure no sensitive files are listed
   ```

3. **Use the cleanup script regularly:**
   ```bash
   # Add to your development workflow
   make clean-all
   ```

## Emergency: If You Accidentally Commit Sensitive Files

If you accidentally commit sensitive files, you need to remove them from git history:

```bash
# Remove file from git history (WARNING: This rewrites history)
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch *.pem *.p12 *.csr *.cer' --prune-empty --tag-name-filter cat -- --all

# Force push (WARNING: This affects all collaborators)
git push origin --force --all
```

**Note:** This is dangerous and should only be done if absolutely necessary.

## Safe Development Workflow

1. **Create certificates locally** (not in repo directory):
   ```bash
   cd ~/certificates
   # Work with certificates here
   ```

2. **Copy files when needed:**
   ```bash
   # Copy to project only when signing
   cp ~/certificates/cert.p12 ./
   # Sign your app
   ./scripts/codesign-macos.sh
   # Clean up immediately
   rm cert.p12
   ```

3. **Use environment variables:**
   ```bash
   export CERT_PATH="~/certificates/cert.p12"
   # Reference in scripts
   ```

4. **Always run cleanup:**
   ```bash
   ./scripts/cleanup.sh
   ```

This ensures your repository stays clean and secure! 🔐✅
