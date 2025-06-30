# Windows Compatibility Fix for CI Workflow

## Issue Fixed

The GitHub Actions CI workflow was failing on Windows runners because it used Unix-specific commands like `ls -la` and `find`, which don't work on Windows PowerShell.

**Error encountered:**
```
Run ls -la bin/Release/net8.0/
Get-ChildItem: D:\a\_temp\204d123b-8ad4-404c-8f37-9c4038016190.ps1:2
Line |
   2 |  ls -la bin/Release/net8.0/
     |     ~~~
     | A parameter cannot be found that matches parameter name 'la'.
Error: Process completed with exit code 1.
```

## Solution Applied

### 1. Updated CI Workflow (`.github/workflows/ci.yml`)

**Before:**
```yaml
- name: Test build artifacts
  run: |
    ls -la bin/Release/net8.0/

- name: Test cross-platform builds
  run: |
    # ... build commands ...
    find ./test-publish -name "SecretsTool*" -type f
```

**After:**
```yaml
- name: Test build artifacts
  shell: pwsh
  run: |
    Write-Host "Build artifacts:"
    Get-ChildItem bin/Release/net8.0/ -Recurse | Select-Object Name, Length

- name: Test cross-platform builds
  shell: pwsh
  run: |
    # ... build commands ...
    Write-Host "Build artifacts:"
    Get-ChildItem ./test-publish -Recurse -Name "SecretsTool*"
```

### 2. Changes Made

1. **Added `shell: pwsh`**: Explicitly use PowerShell Core which is available on all GitHub Actions runners (Windows, macOS, Linux)

2. **Replaced Unix commands with PowerShell equivalents**:
   - `ls -la` → `Get-ChildItem` with `Select-Object`
   - `find ... -name` → `Get-ChildItem ... -Name`
   - `echo` → `Write-Host`

3. **Cross-platform compatibility**: PowerShell Core works consistently across all platforms

### 3. Why This Works

- **PowerShell Core (`pwsh`)** is pre-installed on all GitHub Actions runners
- **Consistent behavior** across Windows, macOS, and Linux
- **No platform-specific conditionals** needed
- **Better output formatting** with PowerShell objects

### 4. Release Workflow Status

The release workflow (`.github/workflows/release.yml`) was not affected because:
- It runs on `ubuntu-latest` only for the release job
- Build jobs use platform-appropriate commands with proper conditionals
- Windows-specific commands (like `7z`) are properly guarded with `if: runner.os == 'Windows'`

## Testing

- ✅ Local build verification completed
- ✅ PowerShell commands tested (where available)
- ✅ Workflow syntax validated
- ✅ No breaking changes to existing functionality

The CI workflow should now pass on all platforms including Windows runners.
