const express = require('express');
const cors = require('cors');
require('dotenv').config();

const bookRoutes = require('./src/routes/bookRoutes');

const app = express();
const PORT = process.env.PORT || 5001;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check route
app.get('/', (req, res) => {
  res.json({
    message: '📚 Books CRUD API Server is running',
    version: '1.0.0',
    endpoints: {
      getAllBooks: 'GET /api/books',
      getBookById: 'GET /api/books/:id',
      createBook: 'POST /api/books',
      updateBook: 'PUT /api/books/:id',
      deleteBook: 'DELETE /api/books/:id'
    }
  });
});

// API Routes
app.use('/api/books', bookRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📚 Books API available at http://localhost:${PORT}/api/books`);
});
