const fs = require('fs');
const path = require('path');
const { initializeApp, cert, applicationDefault, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

let db;

function getCredentialPath() {
  return process.env.GOOGLE_APPLICATION_CREDENTIALS
    ? path.resolve(process.env.GOOGLE_APPLICATION_CREDENTIALS)
    : path.join(__dirname, '..', 'ServiceAccountKey.json');
}

function initializeFirebase() {
  if (db) {
    return db;
  }

  if (!getApps().length) {
    const credentialPath = getCredentialPath();

    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      initializeApp({
        credential: applicationDefault(),
      });
    } else if (fs.existsSync(credentialPath)) {
      const serviceAccount = require(credentialPath);

      initializeApp({
        credential: cert(serviceAccount),
      });
    } else {
      throw new Error(
        `Firebase service account not found. Set GOOGLE_APPLICATION_CREDENTIALS or place ServiceAccountKey.json at ${credentialPath}.`
      );
    }
  }

  db = getFirestore();
  return db;
}

module.exports = initializeFirebase;
