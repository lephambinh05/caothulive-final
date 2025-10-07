# Firebase Security Rules

This directory contains Firebase Security Rules for your application.

## 📁 Files

- `firestore.rules` - Firestore database security rules
- `storage.rules` - Firebase Storage security rules
- `deploy_rules.ps1` - PowerShell script to deploy rules (Windows)
- `deploy_rules.sh` - Bash script to deploy rules (Linux/Mac)

## 🔐 Security Rules Overview

### Firestore Rules
- **Public Collections**: `youtube_links`, `youtube_channels`, `website_links`, `downloads`, `settings`
  - ✅ Anyone can read
  - 🔒 Only authenticated admin can write

- **Admin Collections**: `admins`
  - 🔒 Only authenticated admin can read/write

- **Support Messages**: `support_messages`
  - ✅ Anyone can create (submit support request)
  - 🔒 Only admin can read/update

### Storage Rules
- **Downloads Folder**: `/downloads/{fileName}`
  - ✅ Anyone can read (public downloads)
  - 🔒 Only authenticated admin can upload/delete
  - ✅ File validation (max 100MB, .ipa/.apk only)

## 🚀 How to Deploy

### Option 1: Using Scripts (Recommended)

**Windows (PowerShell):**
```powershell
cd firebase_config
.\deploy_rules.ps1
```

**Linux/Mac (Bash):**
```bash
cd firebase_config
chmod +x deploy_rules.sh
./deploy_rules.sh
```

### Option 2: Manual Deployment

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

## ⚠️ Important Notes

1. **Admin Authentication**: Make sure your admin users have `admin: true` in their custom claims
2. **File Validation**: Storage rules validate file size (max 100MB) and extensions (.ipa/.apk only)
3. **Public Access**: Downloads are publicly accessible for users to download apps
4. **Security**: All write operations require admin authentication

## 🔧 Custom Claims Setup

To set admin custom claims for a user:

```javascript
// In Firebase Admin SDK
admin.auth().setCustomUserClaims(uid, { admin: true });
```

## 📝 Rule Structure

### Firestore Rules Pattern
```javascript
match /collection/{document} {
  allow read: if condition;
  allow write: if condition;
}
```

### Storage Rules Pattern
```javascript
match /b/{bucket}/o/path/{fileName} {
  allow read: if condition;
  allow write: if condition;
}
```

## 🛡️ Security Features

- ✅ Public read access for content
- 🔒 Admin-only write access
- 📁 File type validation
- 📏 File size limits
- 🔐 Authentication required for admin operations
- 🚫 Default deny for unknown paths

## 📞 Support

If you need to modify these rules, update the respective `.rules` files and redeploy using the scripts above.