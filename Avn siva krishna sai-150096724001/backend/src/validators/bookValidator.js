/**
 * Book Validation Middleware
 */

function validateBook(req, res, next) {
  const { title, author, isbn, genre, price, quantity, publishedDate } = req.body;
  const errors = [];

  // Title validation
  if (!title || typeof title !== 'string' || title.trim() === '') {
    errors.push('Title is required');
  }

  // Author validation
  if (!author || typeof author !== 'string' || author.trim() === '') {
    errors.push('Author is required');
  }

  // ISBN validation
  if (!isbn || typeof isbn !== 'string' || isbn.trim() === '') {
    errors.push('ISBN is required');
  }

  // Genre validation
  if (!genre || typeof genre !== 'string' || genre.trim() === '') {
    errors.push('Genre is required');
  }

  // Price validation
  if (price === undefined || price === null || price === '') {
    errors.push('Price is required');
  } else {
    const numPrice = Number(price);
    if (isNaN(numPrice)) {
      errors.push('Price must be a valid number');
    } else if (numPrice < 0) {
      errors.push('Price must be greater than or equal to 0');
    }
  }

  // Quantity validation
  if (quantity === undefined || quantity === null || quantity === '') {
    errors.push('Quantity is required');
  } else {
    const numQuantity = Number(quantity);
    if (!Number.isInteger(numQuantity)) {
      errors.push('Quantity must be an integer');
    } else if (numQuantity < 0) {
      errors.push('Quantity must be greater than or equal to 0');
    }
  }

  // Published Date validation
  if (!publishedDate) {
    errors.push('Published date is required');
  } else {
    const parsedDate = new Date(publishedDate);
    if (isNaN(parsedDate.getTime())) {
      errors.push('Published date must be a valid date');
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: errors[0],
      errors: errors
    });
  }

  next();
}

module.exports = {
  validateBook
};
