# PowerShell script to run mobile app on Android emulator
Write-Host "🚀 Starting Mobile App on Android Emulator..." -ForegroundColor Green

# Check if emulator is running
Write-Host "📱 Checking for running emulators..." -ForegroundColor Yellow
flutter devices

# Run the app
Write-Host "🏃 Running app on emulator..." -ForegroundColor Yellow
flutter run -d emulator-5554

Write-Host "✅ App should now be running on your Android emulator!" -ForegroundColor Green
