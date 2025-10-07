#!/bin/bash

# Script to run mobile app on Android emulator
echo "🚀 Starting Mobile App on Android Emulator..."

# Check if emulator is running
echo "📱 Checking for running emulators..."
flutter devices

# Run the app
echo "🏃 Running app on emulator..."
flutter run -d emulator-5554

echo "✅ App should now be running on your Android emulator!"
