const { getDb } = require('../config/firebase');
const Book = require('../models/bookModel');

const COLLECTION_NAME = 'books';

class BookService {
  /**
   * Fetch all books sorted alphabetically by title
   */
  async getAllBooks() {
    const db = getDb();
    const snapshot = await db.collection(COLLECTION_NAME).get();

    const books = [];
    snapshot.docs.forEach((doc) => {
      books.push(Book.fromFirestore(doc).toJSON());
    });

    // Sort alphabetically by title
    books.sort((a, b) => a.title.localeCompare(b.title));

    return books;
  }

  /**
   * Fetch a single book by ID
   */
  async getBookById(id) {
    if (!id || typeof id !== 'string') {
      return null;
    }

    const db = getDb();
    const doc = await db.collection(COLLECTION_NAME).doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return Book.fromFirestore(doc).toJSON();
  }

  /**
   * Create a new book with unique ISBN validation
   */
  async createBook(bookData) {
    const db = getDb();
    const cleanIsbn = bookData.isbn.trim();

    // Check if ISBN already exists
    const existingSnapshot = await db
      .collection(COLLECTION_NAME)
      .where('isbn', '==', cleanIsbn)
      .get();

    if (!existingSnapshot.empty && existingSnapshot.docs.length > 0) {
      const error = new Error('ISBN already exists');
      error.statusCode = 409;
      throw error;
    }

    const newBook = new Book({
      ...bookData,
      isbn: cleanIsbn,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    const docRef = await db.collection(COLLECTION_NAME).add(newBook.toFirestore());
    newBook.id = docRef.id;

    return newBook.toJSON();
  }

  /**
   * Update an existing book with ISBN conflict detection
   */
  async updateBook(id, updateData) {
    if (!id || typeof id !== 'string') {
      const error = new Error('Book not found');
      error.statusCode = 404;
      throw error;
    }

    const db = getDb();
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      const error = new Error('Book not found');
      error.statusCode = 404;
      throw error;
    }

    const existingData = existingDoc.data();
    const cleanIsbn = updateData.isbn ? updateData.isbn.trim() : existingData.isbn;

    // If ISBN is changing, check whether another book already uses it
    if (cleanIsbn !== existingData.isbn) {
      const isbnConflictSnapshot = await db
        .collection(COLLECTION_NAME)
        .where('isbn', '==', cleanIsbn)
        .get();

      const conflictingDoc = isbnConflictSnapshot.docs.find((doc) => doc.id !== id);
      if (conflictingDoc) {
        const error = new Error('ISBN already exists');
        error.statusCode = 409;
        throw error;
      }
    }

    const updatedBook = new Book({
      ...existingData,
      ...updateData,
      id,
      isbn: cleanIsbn,
      createdAt: existingData.createdAt,
      updatedAt: new Date().toISOString()
    });

    await docRef.set(updatedBook.toFirestore(), { merge: true });

    return updatedBook.toJSON();
  }

  /**
   * Delete an existing book by ID
   */
  async deleteBook(id) {
    if (!id || typeof id !== 'string') {
      const error = new Error('Book not found');
      error.statusCode = 404;
      throw error;
    }

    const db = getDb();
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      const error = new Error('Book not found');
      error.statusCode = 404;
      throw error;
    }

    await docRef.delete();
    return true;
  }
}

module.exports = new BookService();
