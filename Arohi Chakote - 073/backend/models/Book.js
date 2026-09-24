const { db, isFirebaseConnected } = require('../config/db');

// Fallback in-memory store when Firebase service account is not provided
let inMemoryBooks = [
  {
    id: '1',
    title: 'Flutter in Action',
    author: 'Eric Windmill',
    isbn: '9781617296147',
    genre: 'Programming',
    price: 39.99,
    quantity: 15,
    description: 'A complete guide to building cross-platform mobile apps with Flutter and Dart.',
    publisher: 'Manning Publications',
    publishedDate: '2020-01-15',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: '2',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '9780132350884',
    genre: 'Software Engineering',
    price: 42.50,
    quantity: 10,
    description: 'A Handbook of Agile Software Craftsmanship.',
    publisher: 'Prentice Hall',
    publishedDate: '2008-08-01',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: '3',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    isbn: '9780743273565',
    genre: 'Classic Fiction',
    price: 14.99,
    quantity: 25,
    description: 'The story of the mysteriously wealthy Jay Gatsby and his love for Daisy Buchanan.',
    publisher: 'Scribner',
    publishedDate: '1925-04-10',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

class Book {
  static async getAllBooks() {
    if (isFirebaseConnected && db) {
      const snapshot = await db.collection('books').get();
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } else {
      return [...inMemoryBooks];
    }
  }

  static async getBookById(id) {
    if (isFirebaseConnected && db) {
      const doc = await db.collection('books').doc(id).get();
      if (!doc.exists) return null;
      return { id: doc.id, ...doc.data() };
    } else {
      const book = inMemoryBooks.find(b => b.id === id);
      return book ? { ...book } : null;
    }
  }

  static async findByIsbn(isbn) {
    if (!isbn) return null;
    if (isFirebaseConnected && db) {
      const snapshot = await db.collection('books').where('isbn', '==', isbn).get();
      if (snapshot.empty) return null;
      const doc = snapshot.docs[0];
      return { id: doc.id, ...doc.data() };
    } else {
      const book = inMemoryBooks.find(b => b.isbn === isbn);
      return book ? { ...book } : null;
    }
  }

  static async createBook(bookData) {
    if (isFirebaseConnected && db) {
      const docRef = await db.collection('books').add(bookData);
      return { id: docRef.id, ...bookData };
    } else {
      const newBook = {
        id: Date.now().toString(),
        ...bookData
      };
      inMemoryBooks.push(newBook);
      return newBook;
    }
  }

  static async updateBook(id, bookData) {
    if (isFirebaseConnected && db) {
      await db.collection('books').doc(id).update(bookData);
      return { id, ...bookData };
    } else {
      const index = inMemoryBooks.findIndex(b => b.id === id);
      if (index !== -1) {
        inMemoryBooks[index] = { ...inMemoryBooks[index], ...bookData, id };
        return inMemoryBooks[index];
      }
      return null;
    }
  }

  static async deleteBook(id) {
    if (isFirebaseConnected && db) {
      await db.collection('books').doc(id).delete();
      return { id, message: 'Book deleted successfully' };
    } else {
      inMemoryBooks = inMemoryBooks.filter(b => b.id !== id);
      return { id, message: 'Book deleted successfully' };
    }
  }
}

module.exports = Book;
