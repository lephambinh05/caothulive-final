#!/bin/bash

# Script to build and run mobile app
echo "🚀 Building and Running Mobile App..."

# Clean project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check devices
echo "📱 Checking available devices..."
flutter devices

# Try to run on emulator first
echo "🤖 Trying to run on Android emulator..."
if flutter run -d emulator-5556; then
    echo "✅ Running on emulator!"
else
    echo "❌ Emulator not available, trying web..."
    
    # Fallback to web
    echo "🌐 Running on web browser..."
    flutter run -d chrome
fi

echo "✅ App should now be running!"
echo "🎯 Features:"
echo "  - Header with gradient background"
echo "  - Tab navigation (Trực tiếp/Đăng ký kênh)"
echo "  - Video cards with thumbnails"
echo "  - Channel cards with avatars"
echo "  - Support page with contacts"
echo "  - Real-time data from Firebase"
echo "  - YouTube integration"
