#!/bin/bash

# Install CocoaPods for iOS development
echo "🍫 Installing CocoaPods..."

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    echo "✅ Homebrew found, installing CocoaPods via Homebrew..."
    brew install cocoapods
elif command -v gem &> /dev/null; then
    echo "✅ Ruby gem found, installing CocoaPods via gem..."
    echo "⚠️  This may require sudo password"
    sudo gem install cocoapods
else
    echo "❌ Neither Homebrew nor Ruby gem found"
    echo "Please install Homebrew first:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Verify installation
if command -v pod &> /dev/null; then
    echo "✅ CocoaPods installed successfully!"
    echo "Version: $(pod --version)"
    echo ""
    echo "🚀 You can now run: ./build_for_appstore.sh"
else
    echo "❌ CocoaPods installation failed"
    echo "Please try manual installation:"
    echo "1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "2. Install CocoaPods: brew install cocoapods"
    exit 1
fi
