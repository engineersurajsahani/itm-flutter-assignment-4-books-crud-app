const { db } = require('../config/firebase');
const Book = require('../models/bookModel');

const COLLECTION_NAME = 'books';

/**
 * @desc    Get all books (supports optional search and filter)
 * @route   GET /api/books
 * @access  Public
 */
const getAllBooks = async (req, res) => {
  try {
    const { search, genre, sortBy = 'createdAt', order = 'desc' } = req.query;

    const snapshot = await db.collection(COLLECTION_NAME).get();
    let books = [];

    snapshot.forEach(doc => {
      books.push(Book.format(doc.id, doc.data()));
    });

    // Optional Search Filter (Title, Author, or ISBN)
    if (search && search.trim().length > 0) {
      const term = search.trim().toLowerCase();
      books = books.filter(b => 
        (b.title && b.title.toLowerCase().includes(term)) ||
        (b.author && b.author.toLowerCase().includes(term)) ||
        (b.isbn && b.isbn.toLowerCase().includes(term)) ||
        (b.genre && b.genre.toLowerCase().includes(term))
      );
    }

    // Optional Genre Filter
    if (genre && genre.trim().length > 0) {
      const genreTerm = genre.trim().toLowerCase();
      books = books.filter(b => b.genre && b.genre.toLowerCase() === genreTerm);
    }

    // Sorting
    books.sort((a, b) => {
      let valA = a[sortBy];
      let valB = b[sortBy];

      if (valA === undefined || valA === null) valA = '';
      if (valB === undefined || valB === null) valB = '';

      if (typeof valA === 'string') {
        return order.toLowerCase() === 'asc' 
          ? valA.localeCompare(valB) 
          : valB.localeCompare(valA);
      } else {
        return order.toLowerCase() === 'asc' 
          ? (valA > valB ? 1 : -1) 
          : (valA < valB ? 1 : -1);
      }
    });

    return res.status(200).json({
      success: true,
      count: books.length,
      data: books
    });
  } catch (error) {
    console.error('Error fetching books:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve books',
      error: error.message
    });
  }
};

/**
 * @desc    Get single book by ID
 * @route   GET /api/books/:id
 * @access  Public
 */
const getBookById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || id.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Book ID is required'
      });
    }

    const doc = await db.collection(COLLECTION_NAME).doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: `Book not found with id: ${id}`
      });
    }

    return res.status(200).json({
      success: true,
      data: Book.format(doc.id, doc.data())
    });
  } catch (error) {
    console.error(`Error fetching book with ID ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve book',
      error: error.message
    });
  }
};

/**
 * @desc    Add a new book
 * @route   POST /api/books
 * @access  Public
 */
const createBook = async (req, res) => {
  try {
    const { isValid, errors, sanitized } = Book.validate(req.body, false);

    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors
      });
    }

    // Check for unique ISBN if an ISBN is provided
    if (sanitized.isbn && sanitized.isbn.length > 0) {
      const existingIsbnQuery = await db.collection(COLLECTION_NAME)
        .where('isbn', '==', sanitized.isbn)
        .get();

      if (!existingIsbnQuery.empty) {
        return res.status(409).json({
          success: false,
          message: `A book with ISBN '${sanitized.isbn}' already exists.`
        });
      }
    }

    const timestamp = new Date().toISOString();
    const bookData = {
      ...sanitized,
      createdAt: timestamp,
      updatedAt: timestamp
    };

    const docRef = await db.collection(COLLECTION_NAME).add(bookData);

    return res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: Book.format(docRef.id, bookData)
    });
  } catch (error) {
    console.error('Error creating book:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create book',
      error: error.message
    });
  }
};

/**
 * @desc    Update a book
 * @route   PUT /api/books/:id
 * @access  Public
 */
const updateBook = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || id.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Book ID is required'
      });
    }

    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({
        success: false,
        message: `Book not found with id: ${id}`
      });
    }

    const { isValid, errors, sanitized } = Book.validate(req.body, true);

    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors
      });
    }

    // If ISBN is being updated, verify it is not already taken by another book
    if (sanitized.isbn && sanitized.isbn !== existingDoc.data().isbn) {
      const isbnConflict = await db.collection(COLLECTION_NAME)
        .where('isbn', '==', sanitized.isbn)
        .get();

      const conflictingDoc = isbnConflict.docs ? isbnConflict.docs.find(d => d.id !== id) : null;
      if (conflictingDoc) {
        return res.status(409).json({
          success: false,
          message: `Another book already exists with ISBN '${sanitized.isbn}'.`
        });
      }
    }

    sanitized.updatedAt = new Date().toISOString();

    await docRef.update(sanitized);

    const updatedData = {
      ...existingDoc.data(),
      ...sanitized
    };

    return res.status(200).json({
      success: true,
      message: 'Book updated successfully',
      data: Book.format(id, updatedData)
    });
  } catch (error) {
    console.error(`Error updating book ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to update book',
      error: error.message
    });
  }
};

/**
 * @desc    Delete a book
 * @route   DELETE /api/books/:id
 * @access  Public
 */
const deleteBook = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || id.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Book ID is required'
      });
    }

    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: `Book not found with id: ${id}`
      });
    }

    await docRef.delete();

    return res.status(200).json({
      success: true,
      message: 'Book deleted successfully',
      data: {
        id,
        title: doc.data()?.title || ''
      }
    });
  } catch (error) {
    console.error(`Error deleting book ${req.params.id}:`, error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete book',
      error: error.message
    });
  }
};

module.exports = {
  getAllBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook
};
