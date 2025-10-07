# PowerShell script to run website-style mobile app
Write-Host "🎨 Starting Website-Style Mobile App..." -ForegroundColor Green

# Check if emulator is running
Write-Host "📱 Checking for running emulators..." -ForegroundColor Yellow
flutter devices

# Run the app
Write-Host "🏃 Running website-style app on emulator..." -ForegroundColor Yellow
flutter run -d emulator-5554

Write-Host "✅ Website-style app should now be running!" -ForegroundColor Green
Write-Host "🎯 Features:" -ForegroundColor Cyan
Write-Host "  - Header with gradient background" -ForegroundColor White
Write-Host "  - Tab navigation (Videos/Channels)" -ForegroundColor White
Write-Host "  - Priority filter chips" -ForegroundColor White
Write-Host "  - Video cards with thumbnails" -ForegroundColor White
Write-Host "  - Channel cards with avatars" -ForegroundColor White
Write-Host "  - Support page with contacts" -ForegroundColor White
Write-Host "  - Real-time data from Firebase" -ForegroundColor White
Write-Host "  - YouTube integration" -ForegroundColor White
