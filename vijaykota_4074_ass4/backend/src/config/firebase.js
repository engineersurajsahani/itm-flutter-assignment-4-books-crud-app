const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');

let app;

// Ensure you have downloaded the Firebase service account JSON file
// and set its path in the environment variable FIREBASE_SERVICE_ACCOUNT
// or provide credentials manually here for local testing.

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const serviceAccountPath = path.resolve(process.cwd(), process.env.FIREBASE_SERVICE_ACCOUNT);
    const serviceAccount = require(serviceAccountPath);
    app = initializeApp({
        credential: cert(serviceAccount)
    });
} else {
    console.warn("Firebase service account path not provided in .env. Initializing with default app.");
    // In some environments, this might work if credentials are set via GOOGLE_APPLICATION_CREDENTIALS
    app = initializeApp();
}

const db = getFirestore(app);

module.exports = { db };
