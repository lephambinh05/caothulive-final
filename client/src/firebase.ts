import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyDnVr2y-CayvAgfBFzZxtGuz68dQn6249w",
  authDomain: "quanly20m.firebaseapp.com",
  projectId: "quanly20m",
  storageBucket: "quanly20m.firebasestorage.app",
  messagingSenderId: "696748829509",
  appId: "1:696748829509:web:8f3feee2ccdd85ac01ac2c",
  measurementId: "G-961GGE1WT3"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);

export default app;
