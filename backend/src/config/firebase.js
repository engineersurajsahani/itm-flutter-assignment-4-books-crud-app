const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

let db;
let isMock = false;

// In-Memory Mock Database fallback for development if credentials are not yet configured
class MockFirestore {
  constructor() {
    this.storage = new Map();
    // Seed some initial sample data so endpoints return meaningful data immediately
    const sampleBooks = [
      {
        id: 'book_seed_1',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        isbn: '978-0132350884',
        genre: 'Software Engineering',
        price: 37.99,
        quantity: 15,
        description: 'A Handbook of Agile Software Craftsmanship',
        publisher: 'Prentice Hall',
        publishedDate: '2008-08-01T00:00:00.000Z',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: 'book_seed_2',
        title: 'The Pragmatic Programmer',
        author: 'David Thomas, Andrew Hunt',
        isbn: '978-0135957059',
        genre: 'Programming',
        price: 42.50,
        quantity: 8,
        description: 'Your Journey to Mastery, 20th Anniversary Edition',
        publisher: 'Addison-Wesley',
        publishedDate: '2019-09-13T00:00:00.000Z',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }
    ];

    for (const book of sampleBooks) {
      this.storage.set(book.id, { ...book });
    }
  }

  collection(name) {
    if (name !== 'books') {
      if (!this[name]) this[name] = new Map();
    }
    const store = name === 'books' ? this.storage : this[name];

    return {
      doc: (id) => ({
        get: async () => {
          const data = store.get(id);
          return {
            exists: !!data,
            id: id,
            data: () => (data ? { ...data } : undefined),
          };
        },
        set: async (data, options = {}) => {
          const existing = store.get(id) || {};
          const merged = options.merge ? { ...existing, ...data } : { ...data };
          store.set(id, merged);
          return { id };
        },
        update: async (data) => {
          const existing = store.get(id);
          if (!existing) {
            const err = new Error(`No document to update: ${id}`);
            err.code = 5;
            throw err;
          }
          const updated = { ...existing, ...data };
          store.set(id, updated);
          return { id };
        },
        delete: async () => {
          store.delete(id);
          return { id };
        }
      }),
      add: async (data) => {
        const id = 'book_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7);
        const docData = { ...data, id };
        store.set(id, docData);
        return {
          id,
          get: async () => ({
            exists: true,
            id,
            data: () => ({ ...docData }),
          }),
        };
      },
      get: async () => {
        const docs = Array.from(store.entries()).map(([id, data]) => ({
          id,
          exists: true,
          data: () => ({ ...data }),
        }));
        return {
          empty: docs.length === 0,
          size: docs.length,
          docs,
          forEach: (callback) => docs.forEach(callback),
        };
      },
      where: (field, op, value) => {
        return {
          get: async () => {
            const docs = Array.from(store.entries())
              .filter(([_, data]) => {
                if (op === '==') return data[field] === value;
                return true;
              })
              .map(([id, data]) => ({
                id,
                exists: true,
                data: () => ({ ...data }),
              }));
            return {
              empty: docs.length === 0,
              size: docs.length,
              docs,
              forEach: (callback) => docs.forEach(callback),
            };
          }
        };
      }
    };
  }
}

function initFirebase() {
  if (process.env.USE_MOCK_DB === 'true') {
    console.log('ℹ️ [Firebase Config] USE_MOCK_DB=true is set. Using in-memory mock database.');
    isMock = true;
    db = new MockFirestore();
    return { admin: null, db, isMock };
  }

  // Check candidate paths for serviceAccountKey.json
  const candidatePaths = [
    process.env.FIREBASE_SERVICE_ACCOUNT_KEY,
    path.join(__dirname, '../../serviceAccountKey.json'),
    path.join(__dirname, 'serviceAccountKey.json'),
    path.join(process.cwd(), 'serviceAccountKey.json')
  ].filter(Boolean);

  let keyFilePath = candidatePaths.find(p => fs.existsSync(p));

  if (keyFilePath) {
    try {
      const serviceAccount = require(path.resolve(keyFilePath));
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      db = admin.firestore();
      console.log(`✅ [Firebase Config] Connected to Firestore using service account: ${keyFilePath}`);
      return { admin, db, isMock: false };
    } catch (err) {
      console.error(`❌ [Firebase Config] Failed to initialize Firebase with ${keyFilePath}:`, err.message);
    }
  }

  // Check direct environment variables
  if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    try {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
        })
      });
      db = admin.firestore();
      console.log('✅ [Firebase Config] Connected to Firestore using environment variables.');
      return { admin, db, isMock: false };
    } catch (err) {
      console.error('❌ [Firebase Config] Failed to initialize Firebase using env vars:', err.message);
    }
  }

  // Check Google Application Default Credentials
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    try {
      admin.initializeApp();
      db = admin.firestore();
      console.log('✅ [Firebase Config] Connected to Firestore using GOOGLE_APPLICATION_CREDENTIALS.');
      return { admin, db, isMock: false };
    } catch (err) {
      console.error('❌ [Firebase Config] Failed to initialize Firebase with GOOGLE_APPLICATION_CREDENTIALS:', err.message);
    }
  }

  // Fallback: Notice and mock mode
  console.warn('\n===============================================================');
  console.warn('⚠️  [Firebase Config Notice]');
  console.warn('No valid Firebase credentials found.');
  console.warn('To connect to live Firebase:');
  console.warn('1. Download serviceAccountKey.json from Firebase Console:');
  console.warn('   Project Settings -> Service Accounts -> Generate New Private Key');
  console.warn('2. Place serviceAccountKey.json in the backend/ folder.');
  console.warn('⚡ Running in in-memory Mock Firestore mode so you can test immediately!');
  console.warn('===============================================================\n');

  isMock = true;
  db = new MockFirestore();
  return { admin: null, db, isMock };
}

const firebaseInstance = initFirebase();

module.exports = {
  admin: firebaseInstance.admin,
  db: firebaseInstance.db,
  isMock: () => firebaseInstance.isMock
};
