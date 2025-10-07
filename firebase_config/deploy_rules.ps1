# PowerShell script to deploy Firebase rules
# Run this script to update your Firebase Security Rules

Write-Host "🔥 Deploying Firebase Security Rules..." -ForegroundColor Yellow

# Check if Firebase CLI is installed
if (!(Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g firebase-tools" -ForegroundColor Cyan
    exit 1
}

# Check if user is logged in
$firebaseUser = firebase login:list 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Please login to Firebase first:" -ForegroundColor Red
    Write-Host "firebase login" -ForegroundColor Cyan
    exit 1
}

Write-Host "📋 Current Firebase user:" -ForegroundColor Green
firebase login:list

# Deploy Firestore rules
Write-Host "`n📄 Deploying Firestore rules..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Firestore rules deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy Firestore rules" -ForegroundColor Red
    exit 1
}

# Deploy Storage rules
Write-Host "`n💾 Deploying Storage rules..." -ForegroundColor Yellow
firebase deploy --only storage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Storage rules deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy Storage rules" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 All Firebase rules deployed successfully!" -ForegroundColor Green
Write-Host "Your app is now secure and ready to use!" -ForegroundColor Cyan