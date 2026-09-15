const db = require('../config/db');

class Book {
  static async getAllBooks() {
    const snapshot = await db.collection('books').get();
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }

  static async getBookById(id) {
    const doc = await db.collection('books').doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return {
      id: doc.id,
      ...doc.data()
    };
  }

  static async findByIsbn(isbn) {
    if (!isbn) return null;
    const snapshot = await db.collection('books').where('isbn', '==', isbn).get();
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  static async createBook(bookData) {
    const docRef = await db.collection('books').add(bookData);
    return {
      id: docRef.id,
      ...bookData
    };
  }

  static async updateBook(id, bookData) {
    await db.collection('books').doc(id).update(bookData);
    return {
      id,
      ...bookData
    };
  }

  static async deleteBook(id) {
    await db.collection('books').doc(id).delete();
    return { id, message: 'Book deleted successfully' };
  }
}

module.exports = Book;
