const admin = require('firebase-admin');

let db = null;
let firebaseInitialized = false;

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  try {
    // Try to use service account key file
    const serviceAccount = require('./quanly20m-firebase-adminsdk-fbsvc-f1f937f039.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'quanly20m'
    });
    db = admin.firestore();
    firebaseInitialized = true;
    console.log('✅ Firebase Admin initialized with service account key');
  } catch (error) {
    console.log('❌ Service account key not found or invalid:', error.message);
    console.log('📋 Please follow these steps:');
    console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
    console.log('2. Select project: quanly20m');
    console.log('3. Go to Project Settings > Service accounts');
    console.log('4. Click "Generate new private key"');
    console.log('5. Download the JSON file');
    console.log('6. Rename it to "serviceAccountKey.json"');
    console.log('7. Place it in the server/ directory');
    console.log('');
    console.log('🚫 Server cannot start without Firebase configuration');
    process.exit(1);
  }
} else {
  db = admin.firestore();
  firebaseInitialized = true;
  console.log('✅ Firebase Admin already initialized');
}

module.exports = { admin, db, firebaseInitialized };
