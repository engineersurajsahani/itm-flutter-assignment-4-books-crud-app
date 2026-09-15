const { db } = require('../config/firebase');
const { validateBook, sanitizeBookPayload, formatBook } = require('../models/bookModel');

const COLLECTION_NAME = 'books';

/**
 * @route   GET /api/books
 * @desc    Get all books (with optional search and genre filtering)
 * @access  Public
 */
async function getAllBooks(req, res, next) {
  try {
    const { search, genre, sortBy = 'title', sortOrder = 'asc' } = req.query;

    const snapshot = await db.collection(COLLECTION_NAME).get();

    let books = [];
    snapshot.docs.forEach((doc) => {
      books.push(formatBook(doc.id, doc.data()));
    });

    // Optional Filter: Genre
    if (genre && genre.trim() !== '') {
      const genreLower = genre.trim().toLowerCase();
      books = books.filter((b) => b.genre && b.genre.toLowerCase() === genreLower);
    }

    // Optional Filter: Search query (matches title, author, isbn, or genre)
    if (search && search.trim() !== '') {
      const searchLower = search.trim().toLowerCase();
      books = books.filter((b) => {
        return (
          (b.title && b.title.toLowerCase().includes(searchLower)) ||
          (b.author && b.author.toLowerCase().includes(searchLower)) ||
          (b.isbn && b.isbn.toLowerCase().includes(searchLower)) ||
          (b.genre && b.genre.toLowerCase().includes(searchLower))
        );
      });
    }

    // Sorting
    books.sort((a, b) => {
      let valA = a[sortBy] !== undefined ? a[sortBy] : '';
      let valB = b[sortBy] !== undefined ? b[sortBy] : '';

      if (typeof valA === 'string') valA = valA.toLowerCase();
      if (typeof valB === 'string') valB = valB.toLowerCase();

      if (valA < valB) return sortOrder === 'desc' ? 1 : -1;
      if (valA > valB) return sortOrder === 'desc' ? -1 : 1;
      return 0;
    });

    return res.status(200).json({
      success: true,
      count: books.length,
      data: books
    });
  } catch (error) {
    next(error);
  }
}

/**
 * @route   GET /api/books/:id
 * @desc    Get a single book by ID
 * @access  Public
 */
async function getBookById(req, res, next) {
  try {
    const { id } = req.params;

    if (!id || id.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Book ID is required'
      });
    }

    const doc = await db.collection(COLLECTION_NAME).doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: `Book with ID '${id}' not found`
      });
    }

    return res.status(200).json({
      success: true,
      data: formatBook(doc.id, doc.data())
    });
  } catch (error) {
    next(error);
  }
}

/**
 * @route   POST /api/books
 * @desc    Add a new book
 * @access  Public
 */
async function createBook(req, res, next) {
  try {
    const validation = validateBook(req.body, false);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: validation.errors
      });
    }

    const trimmedIsbn = req.body.isbn.trim();

    // Check for ISBN uniqueness
    const isbnQuery = await db.collection(COLLECTION_NAME).where('isbn', '==', trimmedIsbn).get();
    if (!isbnQuery.empty) {
      return res.status(409).json({
        success: false,
        message: `A book with ISBN '${trimmedIsbn}' already exists.`
      });
    }

    const sanitizedData = sanitizeBookPayload(req.body);
    const now = new Date().toISOString();
    const newBookData = {
      ...sanitizedData,
      createdAt: now,
      updatedAt: now
    };

    const docRef = await db.collection(COLLECTION_NAME).add(newBookData);

    return res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: formatBook(docRef.id, newBookData)
    });
  } catch (error) {
    next(error);
  }
}

/**
 * @route   PUT /api/books/:id
 * @desc    Update a book by ID
 * @access  Public
 */
async function updateBook(req, res, next) {
  try {
    const { id } = req.params;

    if (!id || id.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Book ID is required'
      });
    }

    // Verify existing book
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({
        success: false,
        message: `Book with ID '${id}' not found`
      });
    }

    const validation = validateBook(req.body, true);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: validation.errors
      });
    }

    // If ISBN is being changed, check if new ISBN is already in use by another book
    if (req.body.isbn) {
      const trimmedIsbn = req.body.isbn.trim();
      const isbnQuery = await db.collection(COLLECTION_NAME).where('isbn', '==', trimmedIsbn).get();
      const conflict = isbnQuery.docs.find((d) => d.id !== id);
      if (conflict) {
        return res.status(409).json({
          success: false,
          message: `Another book with ISBN '${trimmedIsbn}' already exists.`
        });
      }
    }

    const sanitizedUpdates = sanitizeBookPayload(req.body);
    sanitizedUpdates.updatedAt = new Date().toISOString();

    await docRef.update(sanitizedUpdates);

    const updatedDoc = await docRef.get();

    return res.status(200).json({
      success: true,
      message: 'Book updated successfully',
      data: formatBook(id, updatedDoc.data())
    });
  } catch (error) {
    next(error);
  }
}

/**
 * @route   DELETE /api/books/:id
 * @desc    Delete a book by ID
 * @access  Public
 */
async function deleteBook(req, res, next) {
  try {
    const { id } = req.params;

    if (!id || id.trim() === '') {
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
        message: `Book with ID '${id}' not found`
      });
    }

    await docRef.delete();

    return res.status(200).json({
      success: true,
      message: 'Book deleted successfully',
      id
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getAllBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook
};
