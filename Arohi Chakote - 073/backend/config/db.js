const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

let db = null;
let isFirebaseConnected = false;

const serviceAccountPath = path.resolve(__dirname, '../serviceAccountKey.json');

try {
  if (!getApps().length) {
    if (fs.existsSync(serviceAccountPath)) {
      const serviceAccount = require(serviceAccountPath);
      initializeApp({
        credential: cert(serviceAccount)
      });
      console.log('Firebase Admin initialized successfully');
      db = getFirestore();
      isFirebaseConnected = true;
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      initializeApp({
        credential: cert(serviceAccount)
      });
      console.log('Firebase Admin initialized via env variable');
      db = getFirestore();
      isFirebaseConnected = true;
    } else {
      console.warn('Warning: serviceAccountKey.json not found. Operating with fallback in-memory store.');
    }
  } else {
    db = getFirestore();
    isFirebaseConnected = true;
  }
} catch (error) {
  console.warn('Firebase initialization skipped/failed:', error.message);
}

module.exports = { db, isFirebaseConnected };
