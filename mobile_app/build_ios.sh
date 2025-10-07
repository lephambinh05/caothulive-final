#!/bin/bash

# Build iOS App Script
echo "🚀 Building iOS App..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS app
echo "📱 Building iOS app..."
flutter build ios --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    echo "📁 Build output: build/ios/iphoneos/Runner.app"
    
    # Create IPA if needed
    echo "📦 Creating IPA file..."
    cd ios
    xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath Runner.xcarchive archive
    xcodebuild -exportArchive -archivePath Runner.xcarchive -exportPath ../build/ios/ipa -exportOptionsPlist ExportOptions.plist
    
    if [ $? -eq 0 ]; then
        echo "✅ IPA file created successfully!"
        echo "📁 IPA location: build/ios/ipa/Runner.ipa"
    else
        echo "❌ Failed to create IPA file"
    fi
else
    echo "❌ iOS build failed!"
    exit 1
fi
