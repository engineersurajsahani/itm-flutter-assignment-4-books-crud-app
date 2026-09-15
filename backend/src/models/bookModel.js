const { db } = require('../config/firebase');

const COLLECTION_NAME = 'books';

class BookModel {
  static async getAll() {
    const snapshot = await db.collection(COLLECTION_NAME).get();
    const books = [];
    snapshot.docs.forEach(doc => {
      books.push({
        id: doc.id,
        ...doc.data()
      });
    });
    return books;
  }

  static async getById(id) {
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      return null;
    }
    return {
      id: doc.id,
      ...doc.data()
    };
  }

  static async create(bookData) {
    const docRef = await db.collection(COLLECTION_NAME).add({
      title: bookData.title,
      author: bookData.author,
      isbn: bookData.isbn || '',
      genre: bookData.genre || 'Uncategorized',
      price: parseFloat(bookData.price) || 0.0,
      quantity: parseInt(bookData.quantity, 10) || 0,
      description: bookData.description || '',
      publisher: bookData.publisher || '',
      publishedDate: bookData.publishedDate || new Date().toISOString(),
      createdAt: new Date().toISOString()
    });

    const doc = await docRef.get();
    return {
      id: doc.id,
      ...doc.data()
    };
  }

  static async update(id, bookData) {
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return null;
    }

    const updatedFields = {
      ...(bookData.title !== undefined && { title: bookData.title }),
      ...(bookData.author !== undefined && { author: bookData.author }),
      ...(bookData.isbn !== undefined && { isbn: bookData.isbn }),
      ...(bookData.genre !== undefined && { genre: bookData.genre }),
      ...(bookData.price !== undefined && { price: parseFloat(bookData.price) }),
      ...(bookData.quantity !== undefined && { quantity: parseInt(bookData.quantity, 10) }),
      ...(bookData.description !== undefined && { description: bookData.description }),
      ...(bookData.publisher !== undefined && { publisher: bookData.publisher }),
      ...(bookData.publishedDate !== undefined && { publishedDate: bookData.publishedDate }),
      updatedAt: new Date().toISOString()
    };

    await docRef.update(updatedFields);

    const updatedDoc = await docRef.get();
    return {
      id: updatedDoc.id,
      ...updatedDoc.data()
    };
  }

  static async delete(id) {
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return false;
    }

    await docRef.delete();
    return true;
  }
}

module.exports = BookModel;
