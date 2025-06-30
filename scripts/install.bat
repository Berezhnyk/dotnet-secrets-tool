@echo off
REM GitLab Secrets Tool - Installation Script for Windows
REM This script downloads and installs the latest release

setlocal enabledelayedexpansion

set "REPO=berezhnyk/dotnet-secrets-tool"
set "INSTALL_DIR=%USERPROFILE%\.local\bin"
set "BINARY_NAME=SecretsTool.exe"

echo GitLab Secrets Tool - Installation Script
echo ==========================================
echo.

REM Create install directory
if not exist "%INSTALL_DIR%" (
    echo [INFO] Creating install directory: %INSTALL_DIR%
    mkdir "%INSTALL_DIR%"
)

REM Detect architecture
set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
if "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "ARCH=arm64"

set "PLATFORM=win-%ARCH%"
echo [INFO] Detected platform: %PLATFORM%

REM Get latest release tag (simplified - requires PowerShell)
echo [INFO] Fetching latest release information...
powershell -Command "& {$response = Invoke-RestMethod 'https://api.github.com/repos/%REPO%/releases/latest'; $response.tag_name}" > temp_tag.txt
set /p TAG_NAME=<temp_tag.txt
del temp_tag.txt

if "%TAG_NAME%"=="" (
    echo [ERROR] Could not fetch latest release information
    exit /b 1
)

echo [INFO] Latest release: %TAG_NAME%

REM Download URL
set "ASSET_NAME=secretstool-%PLATFORM%.zip"
set "DOWNLOAD_URL=https://github.com/%REPO%/releases/download/%TAG_NAME%/%ASSET_NAME%"

echo [INFO] Downloading %ASSET_NAME%...

REM Download using PowerShell
powershell -Command "& {Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%ASSET_NAME%'}"

if not exist "%ASSET_NAME%" (
    echo [ERROR] Failed to download %ASSET_NAME%
    exit /b 1
)

REM Extract using PowerShell
echo [INFO] Extracting archive...
powershell -Command "& {Expand-Archive '%ASSET_NAME%' -DestinationPath '.' -Force}"

REM Move binary to install directory
if exist "%BINARY_NAME%" (
    move "%BINARY_NAME%" "%INSTALL_DIR%\"
    echo [SUCCESS] GitLab Secrets Tool installed to %INSTALL_DIR%\%BINARY_NAME%
) else (
    echo [ERROR] Binary not found after extraction
    exit /b 1
)

REM Cleanup
del "%ASSET_NAME%"

REM Check if install directory is in PATH
echo %PATH% | find /i "%INSTALL_DIR%" >nul
if errorlevel 1 (
    echo [WARNING] Install directory %INSTALL_DIR% is not in your PATH
    echo [WARNING] Add %INSTALL_DIR% to your PATH environment variable
    echo [WARNING] Or run the tool with full path: %INSTALL_DIR%\%BINARY_NAME%
) else (
    echo [SUCCESS] Install directory is in PATH. You can now run: %BINARY_NAME%
)

REM Verify installation
if exist "%INSTALL_DIR%\%BINARY_NAME%" (
    echo [INFO] Verifying installation...
    "%INSTALL_DIR%\%BINARY_NAME%" --help | findstr "GitLab"
    echo [SUCCESS] Installation verified
    echo.
    echo [INFO] Usage example:
    echo     %BINARY_NAME% --project-id YOUR_PROJECT_ID --token YOUR_GITLAB_TOKEN
    echo.
    echo [INFO] For more help:
    echo     %BINARY_NAME% --help
) else (
    echo [ERROR] Installation verification failed
    exit /b 1
)

echo.
echo [SUCCESS] Installation completed successfully!
pause
