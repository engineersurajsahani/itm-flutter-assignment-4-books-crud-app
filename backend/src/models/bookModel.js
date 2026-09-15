/**
 * Book Model & Validation Utilities
 * Matching the Flutter Model:
 * class Book {
 *   String id;
 *   String title;
 *   String author;
 *   String isbn;
 *   String genre;
 *   double price;
 *   int quantity;
 *   String description;
 *   String publisher;
 *   DateTime publishedDate;
 * }
 */

class Book {
  constructor({
    id = '',
    title = '',
    author = '',
    isbn = '',
    genre = '',
    price = 0.0,
    quantity = 0,
    description = '',
    publisher = '',
    publishedDate = null,
    createdAt = null,
    updatedAt = null
  }) {
    this.id = id;
    this.title = title;
    this.author = author;
    this.isbn = isbn;
    this.genre = genre;
    this.price = Number(price) || 0.0;
    this.quantity = parseInt(quantity, 10) || 0;
    this.description = description;
    this.publisher = publisher;
    this.publishedDate = publishedDate;
    this.createdAt = createdAt || new Date().toISOString();
    this.updatedAt = updatedAt || new Date().toISOString();
  }

  /**
   * Validate book data for creation or update
   * @param {Object} data - Input request body
   * @param {Boolean} isUpdate - Whether this is an update operation
   * @returns {Object} { isValid: boolean, errors: string[], sanitized: Object }
   */
  static validate(data, isUpdate = false) {
    const errors = [];
    const sanitized = {};

    // Validate Title
    if (!isUpdate || data.title !== undefined) {
      if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
        errors.push('Title is required and must be a non-empty string.');
      } else {
        sanitized.title = data.title.trim();
      }
    }

    // Validate Author
    if (!isUpdate || data.author !== undefined) {
      if (!data.author || typeof data.author !== 'string' || data.author.trim().length === 0) {
        errors.push('Author is required and must be a non-empty string.');
      } else {
        sanitized.author = data.author.trim();
      }
    }

    // Validate ISBN
    if (data.isbn !== undefined) {
      if (typeof data.isbn !== 'string') {
        errors.push('ISBN must be a string.');
      } else {
        sanitized.isbn = data.isbn.trim();
      }
    } else if (!isUpdate) {
      sanitized.isbn = '';
    }

    // Validate Genre
    if (data.genre !== undefined) {
      sanitized.genre = typeof data.genre === 'string' ? data.genre.trim() : String(data.genre);
    } else if (!isUpdate) {
      sanitized.genre = '';
    }

    // Validate Price
    if (data.price !== undefined) {
      const numPrice = Number(data.price);
      if (isNaN(numPrice) || numPrice < 0) {
        errors.push('Price must be a valid non-negative number.');
      } else {
        sanitized.price = parseFloat(numPrice.toFixed(2));
      }
    } else if (!isUpdate) {
      sanitized.price = 0.0;
    }

    // Validate Quantity
    if (data.quantity !== undefined) {
      const intQty = parseInt(data.quantity, 10);
      if (isNaN(intQty) || intQty < 0) {
        errors.push('Quantity must be a valid non-negative integer.');
      } else {
        sanitized.quantity = intQty;
      }
    } else if (!isUpdate) {
      sanitized.quantity = 0;
    }

    // Validate Description
    if (data.description !== undefined) {
      sanitized.description = typeof data.description === 'string' ? data.description.trim() : '';
    } else if (!isUpdate) {
      sanitized.description = '';
    }

    // Validate Publisher
    if (data.publisher !== undefined) {
      sanitized.publisher = typeof data.publisher === 'string' ? data.publisher.trim() : '';
    } else if (!isUpdate) {
      sanitized.publisher = '';
    }

    // Validate PublishedDate
    if (data.publishedDate !== undefined) {
      if (data.publishedDate === null || data.publishedDate === '') {
        sanitized.publishedDate = null;
      } else {
        const parsedDate = new Date(data.publishedDate);
        if (isNaN(parsedDate.getTime())) {
          errors.push('PublishedDate must be a valid date or ISO string.');
        } else {
          sanitized.publishedDate = parsedDate.toISOString();
        }
      }
    } else if (!isUpdate) {
      sanitized.publishedDate = null;
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized
    };
  }

  /**
   * Helper to format a Firestore document or object to a standard Book response
   */
  static format(id, data = {}) {
    return {
      id: id || data.id || '',
      title: data.title || '',
      author: data.author || '',
      isbn: data.isbn || '',
      genre: data.genre || '',
      price: typeof data.price === 'number' ? data.price : Number(data.price) || 0.0,
      quantity: typeof data.quantity === 'number' ? data.quantity : parseInt(data.quantity, 10) || 0,
      description: data.description || '',
      publisher: data.publisher || '',
      publishedDate: data.publishedDate || null,
      createdAt: data.createdAt || null,
      updatedAt: data.updatedAt || null
    };
  }
}

module.exports = Book;
