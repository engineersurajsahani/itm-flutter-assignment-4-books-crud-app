const { FieldValue } = require('firebase-admin/firestore');
const getDb = require('../config/db');

const COLLECTION_NAME = 'books';

function collection() {
  return getDb().collection(COLLECTION_NAME);
}

function toBook(doc) {
  return {
    id: doc.id,
    ...doc.data(),
  };
}

class Book {
  static async find() {
    const snapshot = await collection().orderBy('createdAt', 'desc').get();

    if (snapshot.empty) {
      return [];
    }

    return snapshot.docs.map(toBook);
  }

  static async findById(id) {
    const doc = await collection().doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return toBook(doc);
  }

  static async findByIsbn(isbn) {
    if (!isbn) {
      return null;
    }

    const snapshot = await collection().where('isbn', '==', isbn).limit(1).get();

    if (snapshot.empty) {
      return null;
    }

    return toBook(snapshot.docs[0]);
  }

  static async create(book) {
    const now = FieldValue.serverTimestamp();
    const docRef = await collection().add({
      ...book,
      createdAt: now,
      updatedAt: now,
    });
    const doc = await docRef.get();

    return toBook(doc);
  }

  static async findByIdAndUpdate(id, book) {
    const docRef = collection().doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return null;
    }

    await docRef.update({
      ...book,
      updatedAt: FieldValue.serverTimestamp(),
    });

    const updatedBook = await docRef.get();
    return toBook(updatedBook);
  }

  static async findByIdAndDelete(id) {
    const docRef = collection().doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return null;
    }

    await docRef.delete();
    return toBook(doc);
  }
}

module.exports = Book;
