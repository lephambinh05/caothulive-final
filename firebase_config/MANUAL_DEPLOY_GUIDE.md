# 🔥 Manual Firebase Rules Deployment Guide

## Vấn đề hiện tại
- Firebase CLI cần interactive login
- Không thể chạy `firebase login` trong non-interactive mode

## Giải pháp Manual Deploy

### Bước 1: Login Firebase (Manual)
```bash
# Mở terminal/command prompt và chạy:
firebase login
```

### Bước 2: Set Project
```bash
# Set project ID
firebase use quanly20m
```

### Bước 3: Deploy Rules
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules  
firebase deploy --only storage
```

## Hoặc sử dụng Firebase Console

### Firestore Rules:
1. Truy cập: https://console.firebase.google.com/project/quanly20m/firestore/rules
2. Copy nội dung từ `firestore.rules`
3. Paste vào editor
4. Click "Publish"

### Storage Rules:
1. Truy cập: https://console.firebase.google.com/project/quanly20m/storage/rules
2. Copy nội dung từ `storage.rules`
3. Paste vào editor
4. Click "Publish"

## Nội dung Rules

### Firestore Rules (firestore.rules):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin collection - only authenticated admins can access
    match /admins/{adminId} {
      allow read, write: if request.auth != null 
        && request.auth.token.admin == true;
    }
    
    // YouTube links - public read, admin write
    match /youtube_links/{linkId} {
      allow read: if true;
      allow write: if request.auth != null 
        && request.auth.token.admin == true;
    }
    
    // Website links - public read, admin write
    match /website_links/{linkId} {
      allow read: if true;
      allow write: if request.auth != null 
        && request.auth.token.admin == true;
    }
    
    // Downloads - public read, admin write
    match /downloads/{downloadId} {
      allow read: if true;
      allow write: if request.auth != null 
        && request.auth.token.admin == true;
    }
    
    // Support messages - public write, admin read
    match /support_messages/{messageId} {
      allow read: if request.auth != null 
        && request.auth.token.admin == true;
      allow write: if true;
    }
  }
}
```

### Storage Rules (storage.rules):
```
rules_version = '2';

// Firebase Storage Rules for Downloads
service firebase.storage {
  match /b/{bucket}/o {
    
    // Downloads folder - for mobile app files
    match /downloads/{fileName} {
      // Allow read access to everyone (public downloads)
      allow read: if true;
      
      // Allow write access only to authenticated admin users
      allow write: if request.auth != null 
        && request.auth.token.admin == true
        && isValidDownloadFile(request.resource);
      
      // Allow delete only to authenticated admin users
      allow delete: if request.auth != null 
        && request.auth.token.admin == true;
    }
    
    // Helper function to validate download files
    function isValidDownloadFile(resource) {
      // Check file size (max 100MB)
      let fileSizeValid = resource.size < 100 * 1024 * 1024;
      
      // Check file extension (.ipa or .apk)
      let extensionValid = resource.name.matches('.*\\.(ipa|apk)$');
      
      // Check content type
      let contentTypeValid = resource.contentType in [
        'application/octet-stream',
        'application/vnd.android.package-archive',
        'application/iphone'
      ];
      
      // Check metadata exists
      let hasMetadata = resource.metadata != null
        && resource.metadata.platform != null
        && resource.metadata.version != null;
      
      return fileSizeValid && extensionValid && contentTypeValid && hasMetadata;
    }
    
    // Default rule - deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## Kiểm tra sau khi deploy

### Test Firestore:
```bash
# Test read access
curl "https://firestore.googleapis.com/v1/projects/quanly20m/databases/(default)/documents/youtube_links"
```

### Test Storage:
```bash
# Test read access
curl "https://storage.googleapis.com/quanly20m.appspot.com/downloads/test.apk"
```

## Lưu ý
- Rules sẽ có hiệu lực ngay lập tức sau khi deploy
- Backup rules cũ trước khi deploy
- Test thoroughly sau khi deploy

