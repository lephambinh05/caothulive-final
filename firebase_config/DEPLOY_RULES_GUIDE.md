# 🔥 Deploy Firestore Rules Guide

## ✅ **Đã tạo Firestore rules để cho phép read access!**

### 🎯 **Vấn đề đã xác định:**
- **Error**: `[cloud_firestore/permission-denied] Missing or insufficient permissions`
- **Nguyên nhân**: Firestore rules chặn read access
- **Giải pháp**: Deploy rules cho phép read access

### 🔧 **Firestore Rules Created:**

#### **File**: `firebase_config/firestore.rules`
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to website_link collection for all users
    match /website_link/{document} {
      allow read: if true;
      allow write: if false; // Only allow read, not write
    }
    
    // Allow read access to youtube_links collection for all users
    match /youtube_links/{document} {
      allow read: if true;
      allow write: if false; // Only allow read, not write
    }
    
    // Allow read access to youtube_channels collection for all users
    match /youtube_channels/{document} {
      allow read: if true;
      allow write: if false; // Only allow read, not write
    }
    
    // Allow read access to settings collection for all users
    match /settings/{document} {
      allow read: if true;
      allow write: if false; // Only allow read, not write
    }
    
    // Deny all other collections
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 🚀 **Deploy Rules:**

#### **Option 1: Using Script (Recommended)**
```bash
# Linux/Mac
chmod +x firebase_config/deploy_rules.sh
./firebase_config/deploy_rules.sh

# Windows
.\firebase_config\deploy_rules.ps1
```

#### **Option 2: Manual Deploy**
```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

### 📱 **Expected Result After Deploy:**

#### **✅ Debug Logs Should Show:**
```
🔥 Firebase snapshot state: ConnectionState.active
🔥 Firebase snapshot hasData: true
🔥 Firebase snapshot hasError: false
🔥 Firebase docs count: 1
🔥 Link 0: 88bet - language - https://88bet9.net/
```

#### **✅ Navbar Should Display:**
- **Icon**: "language" (từ database)
- **Label**: "88bet" (từ database)
- **Tap**: Mở "https://88bet9.net/" trong external browser

### 🔍 **Security Notes:**

#### **✅ Read-Only Access:**
- **website_link**: Read only
- **youtube_links**: Read only
- **youtube_channels**: Read only
- **settings**: Read only
- **All other collections**: Denied

#### **✅ Benefits:**
- **Mobile app** có thể đọc data
- **No write access** - bảo mật
- **Admin panel** vẫn có thể edit qua server
- **Public read** - không cần authentication

### 🎯 **Next Steps:**

#### **1. Deploy Rules:**
- **Run script** hoặc manual deploy
- **Wait for** deployment to complete
- **Check** Firebase console

#### **2. Test Mobile App:**
- **Reload app** trong Chrome
- **Check console** logs
- **Verify** navbar shows "88bet"

#### **3. Verify Functionality:**
- **Tap navbar** → should open external link
- **Check** external browser opens
- **Verify** URL is correct

### 🎉 **Expected Final Result:**
- **Navbar shows**: "88bet" với icon "language"
- **Tap opens**: "https://88bet9.net/" trong Chrome
- **No more errors**: Permission denied resolved
- **Real-time data**: Từ Firebase

**🔥 Deploy Firestore rules để fix permission denied error!** 🚀

## 📁 **Files Created:**
- `firebase_config/firestore.rules` - Firestore rules
- `firebase_config/deploy_rules.sh` - Linux/Mac deploy script
- `firebase_config/deploy_rules.ps1` - Windows deploy script
- `firebase_config/DEPLOY_RULES_GUIDE.md` - This guide

**🎯 Deploy rules và test lại mobile app!** 📱
