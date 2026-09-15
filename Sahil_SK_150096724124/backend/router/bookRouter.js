const express = require('express');
const Book = require('../models/Book');

const router = express.Router();

const ALLOWED_FIELDS = [
  'title',
  'author',
  'isbn',
  'genre',
  'price',
  'quantity',
  'description',
  'publisher',
  'publishedDate',
];

function cleanBookPayload(payload) {
  return ALLOWED_FIELDS.reduce((book, field) => {
    if (payload[field] !== undefined) {
      book[field] = typeof payload[field] === 'string' ? payload[field].trim() : payload[field];
    }

    return book;
  }, {});
}

function validateBookPayload(book, options = { requireTitleAuthor: true }) {
  const errors = [];

  if (options.requireTitleAuthor) {
    if (!book.title) {
      errors.push('title is required');
    }

    if (!book.author) {
      errors.push('author is required');
    }
  } else {
    if (Object.prototype.hasOwnProperty.call(book, 'title') && !book.title) {
      errors.push('title cannot be empty');
    }

    if (Object.prototype.hasOwnProperty.call(book, 'author') && !book.author) {
      errors.push('author cannot be empty');
    }
  }

  if (Object.prototype.hasOwnProperty.call(book, 'price')) {
    const price = Number(book.price);

    if (!Number.isFinite(price) || price < 0) {
      errors.push('price must be a valid non-negative number');
    } else {
      book.price = price;
    }
  }

  if (Object.prototype.hasOwnProperty.call(book, 'quantity')) {
    const quantity = Number(book.quantity);

    if (!Number.isInteger(quantity) || quantity < 0) {
      errors.push('quantity must be a valid non-negative integer');
    } else {
      book.quantity = quantity;
    }
  }

  return errors;
}

function isFirebaseCredentialError(error) {
  return error.message && error.message.includes('Firebase service account not found');
}

function sendError(response, error) {
  const statusCode = isFirebaseCredentialError(error) ? 503 : 500;

  response.status(statusCode).json({
    success: false,
    message: error.message,
  });
}

router.get('/', async (request, response) => {
  try {
    const books = await Book.find();
    response.status(200).json(books);
  } catch (error) {
    sendError(response, error);
  }
});

router.get('/:id', async (request, response) => {
  try {
    const book = await Book.findById(request.params.id);

    if (!book) {
      return response.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }

    response.status(200).json(book);
  } catch (error) {
    sendError(response, error);
  }
});

router.post('/', async (request, response) => {
  try {
    const bookData = cleanBookPayload(request.body);
    const errors = validateBookPayload(bookData);

    if (errors.length) {
      return response.status(400).json({
        success: false,
        errors,
      });
    }

    if (bookData.isbn) {
      const existingBook = await Book.findByIsbn(bookData.isbn);

      if (existingBook) {
        return response.status(409).json({
          success: false,
          message: 'isbn must be unique',
        });
      }
    }

    const book = await Book.create(bookData);

    response.status(201).json({
      success: true,
      message: 'Book created successfully',
      book,
    });
  } catch (error) {
    sendError(response, error);
  }
});

router.put('/:id', async (request, response) => {
  try {
    const currentBook = await Book.findById(request.params.id);

    if (!currentBook) {
      return response.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }

    const bookData = cleanBookPayload(request.body);
    const errors = validateBookPayload(bookData, { requireTitleAuthor: false });

    if (errors.length) {
      return response.status(400).json({
        success: false,
        errors,
      });
    }

    if (bookData.isbn && bookData.isbn !== currentBook.isbn) {
      const existingBook = await Book.findByIsbn(bookData.isbn);

      if (existingBook && existingBook.id !== request.params.id) {
        return response.status(409).json({
          success: false,
          message: 'isbn must be unique',
        });
      }
    }

    const book = await Book.findByIdAndUpdate(request.params.id, bookData);

    response.status(200).json({
      success: true,
      message: 'Book updated successfully',
      book,
    });
  } catch (error) {
    sendError(response, error);
  }
});

router.delete('/:id', async (request, response) => {
  try {
    const book = await Book.findByIdAndDelete(request.params.id);

    if (!book) {
      return response.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }

    response.status(200).json({
      success: true,
      message: 'Book deleted successfully',
      book,
    });
  } catch (error) {
    sendError(response, error);
  }
});

module.exports = router;
