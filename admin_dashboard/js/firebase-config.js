// Drift_Mind Firebase v10 Configuration
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyAGP27vpPObuEzdEsfbLYYGM8mtSgJKbQQ",
  authDomain: "driftmind-9ab16.firebaseapp.com",
  projectId: "driftmind-9ab16",
  storageBucket: "driftmind-9ab16.firebasestorage.app",
  messagingSenderId: "186245141458",
  appId: "1:186245141458:web:9fa78c3adef81c9ed32e0b"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
console.log("🔥 Firebase initialized successfully for project:", firebaseConfig.projectId);
