const express = require('express');
const Book = require('../models/Book');
const router = express.Router();

// GET all books
router.get('/', async (req, res) => {
  try {
    const books = await Book.getAllBooks();
    res.status(200).json(books);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ error: 'Failed to retrieve books', details: error.message });
  }
});

// GET book by ID
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.getBookById(req.params.id);
    if (!book) {
      return res.status(404).json({ error: `Book with ID ${req.params.id} not found` });
    }
    res.status(200).json(book);
  } catch (error) {
    console.error('Error fetching book:', error);
    res.status(500).json({ error: 'Failed to retrieve book', details: error.message });
  }
});

// POST create book
router.post('/', async (req, res) => {
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
      publishedDate
    } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: 'Title is required' });
    }
    if (!author || author.trim() === '') {
      return res.status(400).json({ error: 'Author is required' });
    }

    if (isbn && isbn.trim() !== '') {
      const existing = await Book.findByIsbn(isbn.trim());
      if (existing) {
        return res.status(400).json({ error: 'Book with this ISBN already exists' });
      }
    }

    const bookData = {
      title: title.trim(),
      author: author.trim(),
      isbn: isbn ? isbn.trim() : '',
      genre: genre ? genre.trim() : '',
      price: price !== undefined && price !== '' ? parseFloat(price) : 0.0,
      quantity: quantity !== undefined && quantity !== '' ? parseInt(quantity, 10) : 0,
      description: description ? description.trim() : '',
      publisher: publisher ? publisher.trim() : '',
      publishedDate: publishedDate || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    const newBook = await Book.createBook(bookData);
    res.status(201).json({ message: 'Book created successfully', book: newBook });
  } catch (error) {
    console.error('Error creating book:', error);
    res.status(500).json({ error: 'Failed to create book', details: error.message });
  }
});

// PUT update book
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const existingBook = await Book.getBookById(id);
    if (!existingBook) {
      return res.status(404).json({ error: `Book with ID ${id} not found` });
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
      publishedDate
    } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: 'Title is required' });
    }
    if (!author || author.trim() === '') {
      return res.status(400).json({ error: 'Author is required' });
    }

    const updateData = {
      title: title.trim(),
      author: author.trim(),
      isbn: isbn !== undefined ? isbn.trim() : existingBook.isbn,
      genre: genre !== undefined ? genre.trim() : existingBook.genre,
      price: price !== undefined && price !== '' ? parseFloat(price) : existingBook.price,
      quantity: quantity !== undefined && quantity !== '' ? parseInt(quantity, 10) : existingBook.quantity,
      description: description !== undefined ? description.trim() : existingBook.description,
      publisher: publisher !== undefined ? publisher.trim() : existingBook.publisher,
      publishedDate: publishedDate !== undefined ? publishedDate : existingBook.publishedDate,
      updatedAt: new Date().toISOString()
    };

    const updatedBook = await Book.updateBook(id, updateData);
    res.status(200).json({ message: 'Book updated successfully', book: updatedBook });
  } catch (error) {
    console.error('Error updating book:', error);
    res.status(500).json({ error: 'Failed to update book', details: error.message });
  }
});

// DELETE book
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const existingBook = await Book.getBookById(id);
    if (!existingBook) {
      return res.status(404).json({ error: `Book with ID ${id} not found` });
    }

    await Book.deleteBook(id);
    res.status(200).json({ message: 'Book deleted successfully', id });
  } catch (error) {
    console.error('Error deleting book:', error);
    res.status(500).json({ error: 'Failed to delete book', details: error.message });
  }
});

module.exports = router;
