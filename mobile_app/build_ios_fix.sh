#!/bin/bash

echo "🔧 Fixing CocoaPods and building iOS app..."

# Clean everything
echo "🧹 Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..

# Try different approaches
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Method 1: Try with specific CocoaPods version
echo "🍫 Trying CocoaPods 1.15.2..."
cd ios
pod _1.15.2_ install
if [ $? -eq 0 ]; then
    echo "✅ CocoaPods 1.15.2 worked!"
    cd ..
    flutter build ios --release
    exit 0
fi
cd ..

# Method 2: Try without CocoaPods
echo "🚀 Trying direct build without CocoaPods..."
flutter build ios --release --no-codesign

# Method 3: Try with Xcode directly
echo "🔨 Trying Xcode build..."
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS build
cd ..

echo "✅ Build process completed!"
