#!/bin/bash

# Cleanup script to remove sensitive files and build artifacts
# Run this before committing to ensure no sensitive files are included

echo "🧹 Cleaning up sensitive files and build artifacts..."

# Remove certificate and key files
if ls *.pem *.p12 *.csr *.cer 2>/dev/null; then
    echo "🔐 Removing certificate and key files:"
    rm -f *.pem *.p12 *.csr *.cer
    echo "   ✅ Certificate files removed"
else
    echo "   ✅ No certificate files found"
fi

# Remove build artifacts (if not in .gitignore)
if [ -d "publish" ]; then
    echo "🗂️  Removing publish directory:"
    rm -rf publish/
    echo "   ✅ Publish directory removed"
fi

if [ -d "dist" ]; then
    echo "🗂️  Removing dist directory:"
    rm -rf dist/
    echo "   ✅ Dist directory removed"
fi

# Remove temporary files
if ls *.tmp *.temp *.bak 2>/dev/null; then
    echo "🗂️  Removing temporary files:"
    rm -f *.tmp *.temp *.bak
    echo "   ✅ Temporary files removed"
else
    echo "   ✅ No temporary files found"
fi

# Remove macOS system files
if ls .DS_Store 2>/dev/null; then
    echo "🍎 Removing macOS system files:"
    rm -f .DS_Store
    echo "   ✅ .DS_Store removed"
else
    echo "   ✅ No macOS system files found"
fi

echo ""
echo "🎉 Cleanup complete!"
echo ""
echo "📋 Files that should NEVER be committed:"
echo "   • *.pem (private keys)"
echo "   • *.p12 (certificates)"
echo "   • *.csr (certificate requests)"
echo "   • *.cer (certificate files)"
echo "   • Build artifacts (bin/, obj/, publish/, dist/)"
echo ""
echo "✅ Safe to commit now!"
