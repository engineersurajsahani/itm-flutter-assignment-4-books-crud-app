const { db } = require('../config/firebase');
const Book = require('../models/bookModel');

const booksCollection = db.collection('books');

// GET all books
const getBooks = async (req, res) => {
  try {
    const snapshot = await booksCollection.get();

    const books = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(books);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({
      message: 'Failed to fetch books',
      error: error.message,
    });
  }
};

// GET one book by ID
const getBookById = async (req, res) => {
  try {
    const doc = await booksCollection.doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({
        message: 'Book not found',
      });
    }

    res.status(200).json({
      id: doc.id,
      ...doc.data(),
    });
  } catch (error) {
    console.error('Error fetching book:', error);
    res.status(500).json({
      message: 'Failed to fetch book',
      error: error.message,
    });
  }
};

// CREATE a book
const createBook = async (req, res) => {
  try {
    const {
      title,
      author,
      isbn,
      genre,
      price,
      quantity,
      description,
      publisher,
      publishedDate,
    } = req.body;

    // Required field validation
    if (!title || !title.trim()) {
      return res.status(400).json({
        message: 'Title is required',
      });
    }

    if (!author || !author.trim()) {
      return res.status(400).json({
        message: 'Author is required',
      });
    }

    if (!isbn || !isbn.trim()) {
      return res.status(400).json({
        message: 'ISBN is required',
      });
    }

    // Check ISBN uniqueness
    const existingBook = await booksCollection
      .where('isbn', '==', isbn.trim())
      .limit(1)
      .get();

    if (!existingBook.empty) {
      return res.status(409).json({
        message: 'A book with this ISBN already exists',
      });
    }

    const book = new Book({
      title: title.trim(),
      author: author.trim(),
      isbn: isbn.trim(),
      genre,
      price,
      quantity,
      description,
      publisher,
      publishedDate,
    });

    const docRef = await booksCollection.add({
      ...book,
    });

    res.status(201).json({
      id: docRef.id,
      ...book,
    });
  } catch (error) {
    console.error('Error creating book:', error);
    res.status(500).json({
      message: 'Failed to create book',
      error: error.message,
    });
  }
};

// UPDATE a book
const updateBook = async (req, res) => {
  try {
    const bookId = req.params.id;

    const bookRef = booksCollection.doc(bookId);
    const existingDoc = await bookRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({
        message: 'Book not found',
      });
    }

    const {
      title,
      author,
      isbn,
      genre,
      price,
      quantity,
      description,
      publisher,
      publishedDate,
    } = req.body;

    // Required field validation
    if (!title || !title.trim()) {
      return res.status(400).json({
        message: 'Title is required',
      });
    }

    if (!author || !author.trim()) {
      return res.status(400).json({
        message: 'Author is required',
      });
    }

    if (!isbn || !isbn.trim()) {
      return res.status(400).json({
        message: 'ISBN is required',
      });
    }

    // Check ISBN uniqueness excluding current book
    const isbnSnapshot = await booksCollection
      .where('isbn', '==', isbn.trim())
      .limit(1)
      .get();

    if (
      !isbnSnapshot.empty &&
      isbnSnapshot.docs[0].id !== bookId
    ) {
      return res.status(409).json({
        message: 'A book with this ISBN already exists',
      });
    }

    const updatedBook = new Book({
      title: title.trim(),
      author: author.trim(),
      isbn: isbn.trim(),
      genre,
      price,
      quantity,
      description,
      publisher,
      publishedDate,
    });

    await bookRef.update({
      ...updatedBook,
    });

    res.status(200).json({
      id: bookId,
      ...updatedBook,
    });
  } catch (error) {
    console.error('Error updating book:', error);
    res.status(500).json({
      message: 'Failed to update book',
      error: error.message,
    });
  }
};

// DELETE a book
const deleteBook = async (req, res) => {
  try {
    const bookId = req.params.id;

    const bookRef = booksCollection.doc(bookId);
    const existingDoc = await bookRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({
        message: 'Book not found',
      });
    }

    await bookRef.delete();

    res.status(200).json({
      message: 'Book deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting book:', error);
    res.status(500).json({
      message: 'Failed to delete book',
      error: error.message,
    });
  }
};

module.exports = {
  getBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook,
};