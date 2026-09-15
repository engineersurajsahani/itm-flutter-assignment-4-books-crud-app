const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const admin = require('firebase-admin');

let db = null;
let isMockDb = false;

function initializeFirebase() {
  // 1. Try service account JSON file from FIREBASE_SERVICE_ACCOUNT_PATH or default location
  let serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './serviceAccountKey.json';
  if (serviceAccountPath) {
    let resolvedPath = path.isAbsolute(serviceAccountPath)
      ? serviceAccountPath
      : path.resolve(process.cwd(), serviceAccountPath);

    if (!fs.existsSync(resolvedPath)) {
      resolvedPath = path.resolve(__dirname, '../../', serviceAccountPath);
    }

    if (fs.existsSync(resolvedPath)) {
      try {
        const serviceAccount = JSON.parse(fs.readFileSync(resolvedPath, 'utf8'));
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount)
        });
        db = admin.firestore();
        console.log('[Firebase] Initialized with service account file:', resolvedPath);
        return db;
      } catch (err) {
        console.error('[Firebase] Failed to load service account file:', err.message);
      }
    }
  }

  // 2. Try individual environment variables
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  let privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (projectId && clientEmail && privateKey) {
    try {
      privateKey = privateKey.replace(/\\n/g, '\n');
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey
        })
      });
      db = admin.firestore();
      console.log('[Firebase] Initialized with environment variables for project:', projectId);
      return db;
    } catch (err) {
      console.error('[Firebase] Failed to initialize with environment variables:', err.message);
    }
  }

  // 3. Try default application credentials if explicitly configured
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)) {
    try {
      admin.initializeApp();
      db = admin.firestore();
      console.log('[Firebase] Initialized with GOOGLE_APPLICATION_CREDENTIALS.');
      return db;
    } catch (err) {
      console.error('[Firebase] Failed with GOOGLE_APPLICATION_CREDENTIALS:', err.message);
    }
  }

  // 4. Fallback in-memory Firestore-compatible adapter for local testing when credentials are not yet configured
  console.warn('\n================================================================');
  console.warn('[Firebase] WARNING: No valid Firebase credentials detected.');
  console.warn('[Firebase] Running with an in-memory Firestore-compatible store.');
  console.warn('[Firebase] To connect to live Firestore, provide credentials in .env:');
  console.warn('           FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY');
  console.warn('           or FIREBASE_SERVICE_ACCOUNT_PATH');
  console.warn('================================================================\n');

  isMockDb = true;
  const memoryStore = new Map();

  db = {
    collection: (collName) => ({
      doc: (docId) => {
        const id = docId || ('mem_' + Math.random().toString(36).substring(2, 11) + Date.now().toString(36));
        return {
          id,
          get: async () => {
            const data = memoryStore.get(`${collName}/${id}`);
            return {
              id,
              exists: !!data,
              data: () => (data ? { ...data } : undefined)
            };
          },
          set: async (data, options = {}) => {
            if (options.merge) {
              const existing = memoryStore.get(`${collName}/${id}`) || {};
              memoryStore.set(`${collName}/${id}`, { ...existing, ...data });
            } else {
              memoryStore.set(`${collName}/${id}`, { ...data });
            }
            return { writeTime: new Date() };
          },
          update: async (data) => {
            const existing = memoryStore.get(`${collName}/${id}`);
            if (!existing) {
              const error = new Error(`No document to update: ${collName}/${id}`);
              error.code = 5; // NOT_FOUND in Firestore
              throw error;
            }
            memoryStore.set(`${collName}/${id}`, { ...existing, ...data });
            return { writeTime: new Date() };
          },
          delete: async () => {
            memoryStore.delete(`${collName}/${id}`);
            return { writeTime: new Date() };
          }
        };
      },
      add: async (data) => {
        const id = 'mem_' + Math.random().toString(36).substring(2, 11) + Date.now().toString(36);
        memoryStore.set(`${collName}/${id}`, { ...data });
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
        for (const [key, value] of memoryStore.entries()) {
          if (key.startsWith(`${collName}/`)) {
            const id = key.substring(collName.length + 1);
            docs.push({
              id,
              data: () => ({ ...value })
            });
          }
        }
        return { docs };
      },
      where: (field, op, value) => ({
        get: async () => {
          const docs = [];
          for (const [key, docData] of memoryStore.entries()) {
            if (key.startsWith(`${collName}/`)) {
              let match = false;
              if (op === '==' && docData[field] === value) match = true;
              if (match) {
                const id = key.substring(collName.length + 1);
                docs.push({
                  id,
                  data: () => ({ ...docData })
                });
              }
            }
          }
          return { docs };
        }
      })
    })
  };

  return db;
}

db = initializeFirebase();

module.exports = {
  getDb: () => db,
  isMockDb: () => isMockDb,
  admin
};
