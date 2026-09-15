/**
 * Centralized Error Handling Middleware
 */

function notFoundHandler(req, res, next) {
  return res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`
  });
}

function errorHandler(err, req, res, next) {
  // Server-side logging for diagnostics
  console.error('[Error]', {
    method: req.method,
    url: req.originalUrl,
    message: err.message,
    stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined
  });

  const statusCode = err.statusCode || err.status || 500;
  let clientMessage = err.message || 'An unexpected error occurred';

  // Sanitize internal server errors
  if (statusCode === 500 && process.env.NODE_ENV === 'production') {
    clientMessage = 'Internal server error';
  }

  return res.status(statusCode).json({
    success: false,
    message: clientMessage
  });
}

module.exports = {
  notFoundHandler,
  errorHandler
};
