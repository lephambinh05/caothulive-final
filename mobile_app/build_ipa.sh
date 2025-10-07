#!/bin/bash

# Script để build IPA trên macOS
echo "🚀 Building iOS App for App Store..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install CocoaPods
echo "🍫 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

# Build iOS app
echo "🔨 Building iOS app..."
flutter build ios --release

# Create IPA
echo "📱 Creating IPA file..."
flutter build ipa --release

echo "✅ Build completed!"
echo "📁 IPA file location: build/ios/ipa/"
echo "📋 Files in IPA directory:"
ls -la build/ios/ipa/

echo ""
echo "🎉 Your IPA is ready for App Store submission!"
