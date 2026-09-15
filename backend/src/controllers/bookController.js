const BookModel = require('../models/bookModel');

// GET /api/books - Get all books
const getAllBooks = async (req, res) => {
  try {
    const books = await BookModel.getAll();
    return res.status(200).json({
      success: true,
      count: books.length,
      data: books
    });
  } catch (error) {
    console.error('Error in getAllBooks:', error);
    return res.status(500).json({
      success: false,
      message: 'Server Error: Failed to fetch books',
      error: error.message
    });
  }
};

// GET /api/books/:id - Get a specific book
const getBookById = async (req, res) => {
  try {
    const { id } = req.params;
    const book = await BookModel.getById(id);

    if (!book) {
      return res.status(404).json({
        success: false,
        message: `Book with id ${id} not found`
      });
    }

    return res.status(200).json({
      success: true,
      data: book
    });
  } catch (error) {
    console.error('Error in getBookById:', error);
    return res.status(500).json({
      success: false,
      message: 'Server Error: Failed to fetch book',
      error: error.message
    });
  }
};

// POST /api/books - Add a new book
const createBook = async (req, res) => {
  try {
    const { title, author, isbn, genre, price, quantity, description, publisher, publishedDate } = req.body;

    // Validation
    if (!title || title.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Validation Error: Title is required'
      });
    }

    if (!author || author.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Validation Error: Author is required'
      });
    }

    const newBook = await BookModel.create({
      title: title.trim(),
      author: author.trim(),
      isbn: isbn ? isbn.trim() : '',
      genre: genre ? genre.trim() : 'General',
      price: price !== undefined ? price : 0,
      quantity: quantity !== undefined ? quantity : 0,
      description: description ? description.trim() : '',
      publisher: publisher ? publisher.trim() : '',
      publishedDate: publishedDate || new Date().toISOString()
    });

    return res.status(201).json({
      success: true,
      message: 'Book created successfully',
      data: newBook
    });
  } catch (error) {
    console.error('Error in createBook:', error);
    return res.status(500).json({
      success: false,
      message: 'Server Error: Failed to create book',
      error: error.message
    });
  }
};

// PUT /api/books/:id - Update a book
const updateBook = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, author, isbn, genre, price, quantity, description, publisher, publishedDate } = req.body;

    const existingBook = await BookModel.getById(id);
    if (!existingBook) {
      return res.status(404).json({
        success: false,
        message: `Book with id ${id} not found`
      });
    }

    const updatedBook = await BookModel.update(id, {
      title,
      author,
      isbn,
      genre,
      price,
      quantity,
      description,
      publisher,
      publishedDate
    });

    return res.status(200).json({
      success: true,
      message: 'Book updated successfully',
      data: updatedBook
    });
  } catch (error) {
    console.error('Error in updateBook:', error);
    return res.status(500).json({
      success: false,
      message: 'Server Error: Failed to update book',
      error: error.message
    });
  }
};

// DELETE /api/books/:id - Delete a book
const deleteBook = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await BookModel.delete(id);
    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: `Book with id ${id} not found`
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Book deleted successfully',
      id
    });
  } catch (error) {
    console.error('Error in deleteBook:', error);
    return res.status(500).json({
      success: false,
      message: 'Server Error: Failed to delete book',
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
