const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

let db;
let isUsingMock = false;

// Determine service account file path
const envPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json';
const resolvedPath = path.isAbsolute(envPath)
  ? envPath
  : path.resolve(__dirname, '../../', envPath);

try {
  if (fs.existsSync(resolvedPath)) {
    const serviceAccount = require(resolvedPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    db = admin.firestore();
    console.log(`✅ [Firebase] Successfully connected using serviceAccountKey at: ${resolvedPath}`);
  } else if (
    process.env.FIREBASE_PROJECT_ID &&
    process.env.FIREBASE_CLIENT_EMAIL &&
    process.env.FIREBASE_PRIVATE_KEY
  ) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
      })
    });
    db = admin.firestore();
    console.log(`✅ [Firebase] Successfully connected using environment credentials for project: ${process.env.FIREBASE_PROJECT_ID}`);
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    db = admin.firestore();
    console.log('✅ [Firebase] Successfully connected using GOOGLE_APPLICATION_CREDENTIALS');
  } else {
   
    isUsingMock = true;
    console.warn('\n⚠️  -------------------------------------------------------');
    console.warn('⚠️  [Firebase Warning] No Firebase credentials detected.');
    console.warn('⚠️  To use real Firestore:');
    console.warn('⚠️  1. Download serviceAccountKey.json from Firebase Console.');
    console.warn('⚠️  2. Place it in backend/serviceAccountKey.json or set .env.');
    console.warn('⚠️  Starting with built-in InMemory Firestore Mock for now.');
    console.warn('⚠️  -------------------------------------------------------\n');

    db = createInMemoryFirestoreMock();
  }
} catch (error) {
  console.error('❌ [Firebase Error] Failed to initialize Firebase Admin SDK:', error.message);
  console.warn('⚠️  Falling back to InMemory Firestore Mock.');
  isUsingMock = true;
  db = createInMemoryFirestoreMock();
}

/**
 * Creates an in-memory Firestore-compatible mock interface
 * to allow full API CRUD operations before user configures Firebase credentials.
 */
function createInMemoryFirestoreMock() {
  const store = new Map(); // collectionName -> Map<id, docData>

  function getCollection(name) {
    if (!store.has(name)) {
      store.set(name, new Map());
    }
    return store.get(name);
  }

  return {
    collection: (colName) => {
      const col = getCollection(colName);

      return {
        doc: (docId) => {
          const id = docId || ('mock_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6));
          return {
            id,
            get: async () => {
              const data = col.get(id);
              return {
                id,
                exists: !!data,
                data: () => (data ? { ...data } : undefined)
              };
            },
            set: async (data, options = {}) => {
              if (options.merge && col.has(id)) {
                const existing = col.get(id);
                col.set(id, { ...existing, ...data });
              } else {
                col.set(id, { ...data });
              }
              return { id };
            },
            update: async (data) => {
              if (!col.has(id)) {
                const err = new Error(`No document to update: ${id}`);
                err.code = 5; // NOT_FOUND
                throw err;
              }
              const existing = col.get(id);
              col.set(id, { ...existing, ...data });
              return { id };
            },
            delete: async () => {
              col.delete(id);
              return { id };
            }
          };
        },
        add: async (data) => {
          const id = 'mock_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
          col.set(id, { ...data });
          return {
            id,
            get: async () => ({
              id,
              exists: true,
              data: () => ({ ...data })
            })
          };
        },
        get: async () => {
          const docs = [];
          for (const [id, data] of col.entries()) {
            docs.push({
              id,
              exists: true,
              data: () => ({ ...data })
            });
          }
          return {
            empty: docs.length === 0,
            size: docs.length,
            docs
          };
        },
        where: (field, op, val) => {
          return {
            get: async () => {
              const docs = [];
              for (const [id, data] of col.entries()) {
                let match = false;
                if (op === '==' && data[field] === val) match = true;
                if (match) {
                  docs.push({
                    id,
                    exists: true,
                    data: () => ({ ...data })
                  });
                }
              }
              return {
                empty: docs.length === 0,
                size: docs.length,
                docs
              };
            }
          };
        }
      };
    }
  };
}

module.exports = {
  admin,
  db,
  isUsingMock: () => isUsingMock
};
