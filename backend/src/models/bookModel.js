/**
 * Book Model & Validation Utilities
 */

/**
 * Validates book data for creation or update.
 * @param {Object} data - Input payload
 * @param {boolean} isUpdate - Whether this is a partial or full update
 * @returns {{ isValid: boolean, errors: string[] }}
 */
function validateBook(data, isUpdate = false) {
  const errors = [];

  if (!isUpdate) {
    if (!data.title || typeof data.title !== 'string' || data.title.trim() === '') {
      errors.push('Title is required and must be a non-empty string.');
    }
    if (!data.author || typeof data.author !== 'string' || data.author.trim() === '') {
      errors.push('Author is required and must be a non-empty string.');
    }
    if (!data.isbn || typeof data.isbn !== 'string' || data.isbn.trim() === '') {
      errors.push('ISBN is required and must be a non-empty string.');
    }
  } else {
    // In update, if field is passed, it must not be blank
    if (data.title !== undefined && (typeof data.title !== 'string' || data.title.trim() === '')) {
      errors.push('Title must be a non-empty string.');
    }
    if (data.author !== undefined && (typeof data.author !== 'string' || data.author.trim() === '')) {
      errors.push('Author must be a non-empty string.');
    }
    if (data.isbn !== undefined && (typeof data.isbn !== 'string' || data.isbn.trim() === '')) {
      errors.push('ISBN must be a non-empty string.');
    }
  }

  // Price validation
  if (data.price !== undefined) {
    const priceNum = Number(data.price);
    if (isNaN(priceNum) || priceNum < 0) {
      errors.push('Price must be a valid non-negative number.');
    }
  }

  // Quantity validation
  if (data.quantity !== undefined) {
    const quantityNum = Number(data.quantity);
    if (isNaN(quantityNum) || !Number.isInteger(quantityNum) || quantityNum < 0) {
      errors.push('Quantity must be a valid non-negative integer.');
    }
  }

  // PublishedDate validation
  if (data.publishedDate !== undefined && data.publishedDate !== null && data.publishedDate !== '') {
    const parsedDate = new Date(data.publishedDate);
    if (isNaN(parsedDate.getTime())) {
      errors.push('PublishedDate must be a valid date format (e.g. YYYY-MM-DD or ISO 8601 string).');
    }
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

/**
 * Sanitizes and formats input payload for Firestore storage.
 * @param {Object} data - Raw request body
 * @returns {Object} Cleaned book object
 */
function sanitizeBookPayload(data) {
  const sanitized = {};

  if (data.title !== undefined) sanitized.title = data.title.trim();
  if (data.author !== undefined) sanitized.author = data.author.trim();
  if (data.isbn !== undefined) sanitized.isbn = data.isbn.trim();
  if (data.genre !== undefined) sanitized.genre = data.genre ? data.genre.trim() : '';
  if (data.description !== undefined) sanitized.description = data.description ? data.description.trim() : '';
  if (data.publisher !== undefined) sanitized.publisher = data.publisher ? data.publisher.trim() : '';

  if (data.price !== undefined) {
    sanitized.price = parseFloat(Number(data.price).toFixed(2));
  }
  if (data.quantity !== undefined) {
    sanitized.quantity = parseInt(data.quantity, 10);
  }

  if (data.publishedDate !== undefined) {
    sanitized.publishedDate = data.publishedDate ? new Date(data.publishedDate).toISOString() : null;
  }

  return sanitized;
}

/**
 * Formats a Firestore document into a standardized Book object for API responses.
 * @param {string} id - Firestore Document ID
 * @param {Object} data - Document data
 * @returns {Object} Standardized book response
 */
function formatBook(id, data = {}) {
  let publishedDateFormatted = null;
  if (data.publishedDate) {
    if (typeof data.publishedDate.toDate === 'function') {
      publishedDateFormatted = data.publishedDate.toDate().toISOString();
    } else if (data.publishedDate instanceof Date) {
      publishedDateFormatted = data.publishedDate.toISOString();
    } else {
      publishedDateFormatted = new Date(data.publishedDate).toISOString();
    }
  }

  return {
    id,
    title: data.title || '',
    author: data.author || '',
    isbn: data.isbn || '',
    genre: data.genre || '',
    price: data.price !== undefined ? Number(data.price) : 0.0,
    quantity: data.quantity !== undefined ? parseInt(data.quantity, 10) : 0,
    description: data.description || '',
    publisher: data.publisher || '',
    publishedDate: publishedDateFormatted,
    createdAt: data.createdAt || null,
    updatedAt: data.updatedAt || null
  };
}

module.exports = {
  validateBook,
  sanitizeBookPayload,
  formatBook
};
