// Firebase configuration for Sitara777 Web App
const firebaseConfig = {
  apiKey: "AIzaSyAFJyMqo3Q8W7JWTiXfRM00vMAWyba0k_0",
  authDomain: "sitara777-47f86.firebaseapp.com",
  projectId: "sitara777-47f86",
  storageBucket: "sitara777-47f86.firebasestorage.app",
  messagingSenderId: "321518983520",
  appId: "1:321518983520:web:abc123def456",
  databaseURL: "https://sitara777-47f86-default-rtdb.firebaseio.com"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Export for use in other files
window.firebaseConfig = firebaseConfig; 