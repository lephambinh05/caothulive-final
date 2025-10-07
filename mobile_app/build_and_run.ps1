# PowerShell script to build and run mobile app
Write-Host "🚀 Building and Running Mobile App..." -ForegroundColor Green

# Clean project
Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Check devices
Write-Host "📱 Checking available devices..." -ForegroundColor Yellow
flutter devices

# Try to run on emulator first
Write-Host "🤖 Trying to run on Android emulator..." -ForegroundColor Yellow
try {
    flutter run -d emulator-5556
} catch {
    Write-Host "❌ Emulator not available, trying web..." -ForegroundColor Red
    
    # Fallback to web
    Write-Host "🌐 Running on web browser..." -ForegroundColor Yellow
    flutter run -d chrome
}

Write-Host "✅ App should now be running!" -ForegroundColor Green
Write-Host "🎯 Features:" -ForegroundColor Cyan
Write-Host "  - Header with gradient background" -ForegroundColor White
Write-Host "  - Tab navigation (Trực tiếp/Đăng ký kênh)" -ForegroundColor White
Write-Host "  - Video cards with thumbnails" -ForegroundColor White
Write-Host "  - Channel cards with avatars" -ForegroundColor White
Write-Host "  - Support page with contacts" -ForegroundColor White
Write-Host "  - Real-time data from Firebase" -ForegroundColor White
Write-Host "  - YouTube integration" -ForegroundColor White
