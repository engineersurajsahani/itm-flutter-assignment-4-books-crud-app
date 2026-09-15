const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

let db;
let isMock = false;

try {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path.join(__dirname, 'serviceAccountKey.json');
  
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    db = admin.firestore();
    console.log('🔥 Firebase Admin initialized with service account certificate.');
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    db = admin.firestore();
    console.log('🔥 Firebase Admin initialized with Application Default Credentials.');
  } else {
    console.warn('⚠️ No Firebase service account file or GOOGLE_APPLICATION_CREDENTIALS found.');
    console.warn('⚠️ Operating with in-memory Firestore storage for seamless immediate testing.');
    isMock = true;
    db = createMockDb();
  }
} catch (error) {
  console.warn('⚠️ Firebase Admin initialization failed:', error.message);
  console.warn('⚠️ Falling back to in-memory store.');
  isMock = true;
  db = createMockDb();
}

function createMockDb() {
  const storage = new Map();

  // Initial seed data for convenience
  const sampleBooks = [
    {
      id: 'book-1',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '9780743273565',
      genre: 'Classic',
      price: 10.99,
      quantity: 15,
      description: 'A novel about the American Dream in the 1920s.',
      publisher: 'Scribner',
      publishedDate: new Date('1925-04-10').toISOString()
    },
    {
      id: 'book-2',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isbn: '9780061120084',
      genre: 'Fiction',
      price: 14.99,
      quantity: 20,
      description: 'A masterpiece on racism and injustice in America.',
      publisher: 'Harper Perennial',
      publishedDate: new Date('1960-07-11').toISOString()
    },
    {
      id: 'book-3',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      genre: 'Technology',
      price: 39.99,
      quantity: 8,
      description: 'A Handbook of Agile Software Craftsmanship.',
      publisher: 'Prentice Hall',
      publishedDate: new Date('2008-08-01').toISOString()
    }
  ];

  sampleBooks.forEach(b => storage.set(b.id, b));

  return {
    collection: (collName) => ({
      get: async () => ({
        docs: Array.from(storage.values()).map(data => ({
          id: data.id,
          data: () => data
        }))
      }),
      doc: (docId) => {
        const id = docId || `book-${Date.now()}`;
        return {
          id,
          get: async () => {
            const exists = storage.has(id);
            return {
              exists,
              id,
              data: () => storage.get(id)
            };
          },
          set: async (data, options) => {
            const merged = options && options.merge ? { ...storage.get(id), ...data } : { ...data, id };
            storage.set(id, merged);
            return true;
          },
          update: async (data) => {
            if (!storage.has(id)) throw new Error('Document not found');
            const existing = storage.get(id);
            storage.set(id, { ...existing, ...data });
            return true;
          },
          delete: async () => {
            storage.delete(id);
            return true;
          }
        };
      },
      add: async (data) => {
        const id = `book-${Date.now()}`;
        const newBook = { ...data, id };
        storage.set(id, newBook);
        return {
          id,
          get: async () => ({
            exists: true,
            id,
            data: () => newBook
          })
        };
      }
    })
  };
}

module.exports = { db, isMock };
