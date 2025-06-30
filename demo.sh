#!/bin/bash

# Example usage script for GitLab Secrets Tool
# This script demonstrates various ways to use the tool

echo "=== GitLab Secrets Tool Demo ==="
echo ""

# Build the project first
echo "Building the project..."
dotnet build --project SecretsTool.csproj

echo ""
echo "=== Usage Examples ==="
echo ""

echo "1. Show help:"
echo "dotnet run --project SecretsTool.csproj -- --help"
echo ""

echo "2. Basic usage (requires GITLAB_TOKEN environment variable):"
echo "export GITLAB_TOKEN=your_gitlab_token"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345"
echo ""

echo "3. With explicit token and prefix filter:"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --token your_token --prefix SECRET_"
echo ""

echo "4. Filter by environment (e.g., production):"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --environment production"
echo ""

echo "5. Combine filters (prefix and environment):"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --prefix API_ --environment staging"
echo ""

echo "6. Using custom GitLab instance:"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --gitlab-url https://gitlab.company.com"
echo ""

echo "7. Only add new variables (don't overwrite existing):"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --only-new"
echo ""

echo "8. With explicit UserSecretsId:"
echo "dotnet run --project SecretsTool.csproj -- --project-id 12345 --user-secrets-id my-custom-secrets-id"
echo ""

echo "Note: Replace 'your_gitlab_token' and '12345' with actual values."
echo "The tool will automatically detect UserSecretsId from .csproj files if not provided explicitly."
