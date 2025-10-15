#!/bin/bash

# Simple iOS Build Script for App Store
echo "🚀 Building iOS App for App Store (Simple Method)..."

# Set Flutter path
export PATH="$PATH:$HOME/flutter/bin"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build iOS app without CocoaPods
echo "🔨 Building iOS app (no CocoaPods)..."
flutter build ios --release --no-codesign

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    echo "📁 Build output: build/ios/iphoneos/Runner.app"
    
    # Create IPA manually
    echo "📱 Creating IPA file manually..."
    
    # Create ipa directory
    mkdir -p build/ios/ipa/Payload
    
    # Copy app to Payload
    cp -r build/ios/iphoneos/Runner.app build/ios/ipa/Payload/
    
    # Create IPA
    cd build/ios/ipa
    zip -r Runner.ipa Payload/
    cd ../../..
    
    echo "✅ IPA file created successfully!"
    echo "📁 IPA location: build/ios/ipa/Runner.ipa"
    echo "📋 File size:"
    ls -lh build/ios/ipa/Runner.ipa
    
    echo ""
    echo "🎉 Your IPA is ready for App Store submission!"
    echo "📝 Note: You'll need to sign this IPA with your Apple Developer certificate"
    echo "📝 Use Xcode or Application Loader to upload to App Store Connect"
else
    echo "❌ iOS build failed!"
    exit 1
fi
