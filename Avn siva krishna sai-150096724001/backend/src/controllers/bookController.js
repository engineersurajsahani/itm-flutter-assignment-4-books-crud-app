const bookService = require('../services/bookService');

class BookController {
  /**
   * GET /api/books
   * Retrieve all books
   */
  async getAllBooks(req, res, next) {
    try {
      const books = await bookService.getAllBooks();
      return res.status(200).json({
        success: true,
        data: books
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/books/:id
   * Retrieve a single book by ID
   */
  async getBookById(req, res, next) {
    try {
      const { id } = req.params;
      const book = await bookService.getBookById(id);

      if (!book) {
        return res.status(404).json({
          success: false,
          message: 'Book not found'
        });
      }

      return res.status(200).json({
        success: true,
        data: book
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/books
   * Create a new book
   */
  async createBook(req, res, next) {
    try {
      const bookData = req.body;
      const createdBook = await bookService.createBook(bookData);

      return res.status(201).json({
        success: true,
        message: 'Book created successfully',
        data: createdBook
      });
    } catch (error) {
      if (error.statusCode === 409) {
        return res.status(409).json({
          success: false,
          message: error.message || 'ISBN already exists'
        });
      }
      next(error);
    }
  }

  /**
   * PUT /api/books/:id
   * Update an existing book
   */
  async updateBook(req, res, next) {
    try {
      const { id } = req.params;
      const updateData = req.body;
      const updatedBook = await bookService.updateBook(id, updateData);

      return res.status(200).json({
        success: true,
        message: 'Book updated successfully',
        data: updatedBook
      });
    } catch (error) {
      if (error.statusCode === 404) {
        return res.status(404).json({
          success: false,
          message: 'Book not found'
        });
      }
      if (error.statusCode === 409) {
        return res.status(409).json({
          success: false,
          message: error.message || 'ISBN already exists'
        });
      }
      next(error);
    }
  }

  /**
   * DELETE /api/books/:id
   * Delete an existing book
   */
  async deleteBook(req, res, next) {
    try {
      const { id } = req.params;
      await bookService.deleteBook(id);

      return res.status(200).json({
        success: true,
        message: 'Book deleted successfully'
      });
    } catch (error) {
      if (error.statusCode === 404) {
        return res.status(404).json({
          success: false,
          message: 'Book not found'
        });
      }
      next(error);
    }
  }
}

module.exports = new BookController();
