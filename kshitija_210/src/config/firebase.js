const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

let db;

function getServiceAccountFromFile() {
  const serviceAccountPath = path.resolve(__dirname, "../../serviceAccountKey.json");

  if (!fs.existsSync(serviceAccountPath)) {
    return null;
  }

  return require(serviceAccountPath);
}

function getFirebaseApp() {
  if (!admin.apps.length) {
    const serviceAccount = getServiceAccountFromFile();
    const privateKey = process.env.FIREBASE_PRIVATE_KEY;

    const credential = serviceAccount
      ? admin.credential.cert(serviceAccount)
      : admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: privateKey ? privateKey.replace(/\\n/g, "\n") : undefined,
        });

    if (
      !serviceAccount &&
      (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_CLIENT_EMAIL || !privateKey)
    ) {
      throw new Error(
        "Firebase credentials are missing. Add backend/serviceAccountKey.json or set backend/.env."
      );
    }

    admin.initializeApp({
      credential,
      storageBucket:
        process.env.FIREBASE_STORAGE_BUCKET || (serviceAccount && `${serviceAccount.project_id}.appspot.com`),
    });
  }

  return admin.app();
}

function getDb() {
  if (!db) {
    getFirebaseApp();
    db = admin.firestore();
  }

  return db;
}

module.exports = { getDb };
