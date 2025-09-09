// Firebase web config and initializer (shared)
// Update these values via your build/config process if needed.
window.firebaseConfig = {
  apiKey: "AIzaSyDnVr2y-CayvAgfBFzZxtGuz68dQn6249w",
  authDomain: "quanly20m.firebaseapp.com",
  projectId: "quanly20m",
  storageBucket: "quanly20m.firebasestorage.app",
  messagingSenderId: "696748829509",
  appId: "1:696748829509:web:8f3feee2ccdd85ac01ac2c",
  measurementId: "G-961GGE1WT3"
};

window.initFirebaseApp = function initFirebaseAppCompat() {
  // Requires firebase-app-compat.js loaded beforehand
  if (!window.firebase) {
    console.error('Firebase SDK not loaded');
    return null;
  }
  try {
    return firebase.initializeApp(window.firebaseConfig);
  } catch (e) {
    // If app already initialized, return existing
    try { return firebase.app(); } catch (_) { return null; }
  }
};


