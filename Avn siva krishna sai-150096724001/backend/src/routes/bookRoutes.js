const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { validateBook } = require('../validators/bookValidator');

// GET /api/books - Get all books
router.get('/', (req, res, next) => bookController.getAllBooks(req, res, next));

// GET /api/books/:id - Get single book by ID
router.get('/:id', (req, res, next) => bookController.getBookById(req, res, next));

// POST /api/books - Create a new book
router.post('/', validateBook, (req, res, next) => bookController.createBook(req, res, next));

// PUT /api/books/:id - Update an existing book
router.put('/:id', validateBook, (req, res, next) => bookController.updateBook(req, res, next));

// DELETE /api/books/:id - Delete a book
router.delete('/:id', (req, res, next) => bookController.deleteBook(req, res, next));

module.exports = router;
