#!/bin/bash

# Script to run website-style mobile app
echo "🎨 Starting Website-Style Mobile App..."

# Check if emulator is running
echo "📱 Checking for running emulators..."
flutter devices

# Run the app
echo "🏃 Running website-style app on emulator..."
flutter run -d emulator-5554

echo "✅ Website-style app should now be running!"
echo "🎯 Features:"
echo "  - Header with gradient background"
echo "  - Tab navigation (Videos/Channels)"
echo "  - Priority filter chips"
echo "  - Video cards with thumbnails"
echo "  - Channel cards with avatars"
echo "  - Support page with contacts"
echo "  - Real-time data from Firebase"
echo "  - YouTube integration"
