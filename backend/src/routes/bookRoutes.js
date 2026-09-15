const express = require('express');

const {
  getBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook,
} = require('../controllers/bookController');

const router = express.Router();

// GET all books
router.get('/', getBooks);

// GET one book
router.get('/:id', getBookById);

// CREATE book
router.post('/', createBook);

// UPDATE book
router.put('/:id', updateBook);

// DELETE book
router.delete('/:id', deleteBook);

module.exports = router;