# ============================================
# Script: Generate App Icons - CaoThuLive
# Mô tả: Tự động generate app icons cho iOS và Android
# ============================================

Write-Host "🎨 CaoThuLive - App Icon Generator" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra Flutter đã cài chưa
Write-Host "🔍 Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter is installed!" -ForegroundColor Green
        Write-Host $flutterVersion[0] -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Flutter SDK: https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Kiểm tra file icon
$iconPath = "assets\icon\CAOTHULIVE.png"
Write-Host "🔍 Checking icon file..." -ForegroundColor Yellow
if (Test-Path $iconPath) {
    Write-Host "✅ Icon file found: $iconPath" -ForegroundColor Green
    
    # Lấy kích thước icon (optional - cần System.Drawing)
    try {
        Add-Type -AssemblyName System.Drawing
        $img = [System.Drawing.Image]::FromFile((Resolve-Path $iconPath))
        Write-Host "   📐 Icon size: $($img.Width)×$($img.Height) pixels" -ForegroundColor Gray
        
        if ($img.Width -lt 1024 -or $img.Height -lt 1024) {
            Write-Host "   ⚠️  Warning: Icon should be at least 1024×1024 pixels!" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ Icon size is good!" -ForegroundColor Green
        }
        $img.Dispose()
    } catch {
        Write-Host "   ℹ️  Could not read image dimensions" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Icon file not found: $iconPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎨 Generating app icons..." -ForegroundColor Yellow
Write-Host "This may take a few moments..." -ForegroundColor Gray

# Try both commands (different Flutter versions)
$generateSuccess = $false

# Try method 1: dart run
Write-Host "   Trying: dart run flutter_launcher_icons" -ForegroundColor Gray
dart run flutter_launcher_icons 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $generateSuccess = $true
    Write-Host "   ✅ Generated using 'dart run'" -ForegroundColor Green
}

# Try method 2: flutter pub run (if first failed)
if (-not $generateSuccess) {
    Write-Host "   Trying: flutter pub run flutter_launcher_icons" -ForegroundColor Gray
    flutter pub run flutter_launcher_icons 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $generateSuccess = $true
        Write-Host "   ✅ Generated using 'flutter pub run'" -ForegroundColor Green
    }
}

if (-not $generateSuccess) {
    Write-Host "❌ Failed to generate icons!" -ForegroundColor Red
    Write-Host "Please run manually:" -ForegroundColor Yellow
    Write-Host "  dart run flutter_launcher_icons" -ForegroundColor Yellow
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host "  flutter pub run flutter_launcher_icons" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✅ Icons generated successfully!" -ForegroundColor Green
Write-Host ""

# Kiểm tra output files
Write-Host "📂 Checking generated files..." -ForegroundColor Yellow

$androidIconPath = "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
$iosIconPath = "ios\Runner\Assets.xcassets\AppIcon.appiconset"

if (Test-Path $androidIconPath) {
    Write-Host "   ✅ Android icons: $androidIconPath" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Android icons not found at expected location" -ForegroundColor Yellow
}

if (Test-Path $iosIconPath) {
    Write-Host "   ✅ iOS icons: $iosIconPath" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  iOS icons not found at expected location" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Icon generation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Clean project: flutter clean" -ForegroundColor White
Write-Host "   2. Get dependencies: flutter pub get" -ForegroundColor White
Write-Host "   3. For iOS: cd ios && pod install && cd .." -ForegroundColor White
Write-Host "   4. Build and test the app" -ForegroundColor White
Write-Host ""
Write-Host "Bundle ID: com.caothulive.newsapp" -ForegroundColor Gray
Write-Host ""

# Prompt để chạy flutter clean
$response = Read-Host "Do you want to run 'flutter clean' now? (y/n)"
if ($response -eq 'y' -or $response -eq 'Y') {
    Write-Host ""
    Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
    flutter clean
    Write-Host "✅ Project cleaned!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    Write-Host "✅ Dependencies installed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ All done! Happy coding! 🚀" -ForegroundColor Green
