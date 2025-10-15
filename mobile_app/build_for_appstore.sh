#!/bin/bash

# Build iOS App for App Store
echo "🍎 Building Cao Thu Live for App Store..."

# Set Flutter path
export PATH="$PATH:$HOME/flutter/bin"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods not found. Please install CocoaPods first:"
    echo "   brew install cocoapods"
    echo "   or"
    echo "   sudo gem install cocoapods"
    exit 1
fi

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please add Flutter to PATH:"
    echo "   export PATH=\"\$PATH:\$HOME/flutter/bin\""
    exit 1
fi

echo "✅ CocoaPods found: $(pod --version)"
echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install iOS dependencies
echo "🍫 Installing iOS dependencies..."
cd ios
pod install
cd ..

# Build iOS app
echo "🔨 Building iOS app..."
flutter build ios --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ iOS build completed successfully!"
    
    # Build IPA
    echo "📱 Creating IPA file..."
    flutter build ipa --release
    
    if [ $? -eq 0 ]; then
        echo "✅ IPA file created successfully!"
        echo "📁 IPA location: build/ios/ipa/Runner.ipa"
        echo "📋 File size:"
        ls -lh build/ios/ipa/Runner.ipa
        
        echo ""
        echo "🎉 Your IPA is ready for App Store submission!"
        echo ""
        echo "📝 Next steps:"
        echo "1. Open Xcode: open ios/Runner.xcworkspace"
        echo "2. Configure Bundle ID and Team in Xcode"
        echo "3. Archive and upload to App Store Connect"
        echo "4. Or use the IPA file directly with Application Loader"
        echo ""
        echo "📖 See APP_STORE_BUILD_GUIDE.md for detailed instructions"
    else
        echo "❌ Failed to create IPA file"
        exit 1
    fi
else
    echo "❌ iOS build failed!"
    echo "💡 Try running: flutter doctor"
    exit 1
fi
