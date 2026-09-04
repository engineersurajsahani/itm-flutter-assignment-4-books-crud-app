const express = require('express');
const cors = require('cors');
const bookRoutes = require('./routes/bookRoutes');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

const app = express();

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API is running'
  });
});

// Books CRUD Routes
app.use('/api/books', bookRoutes);

// Centralized 404 handler
app.use(notFoundHandler);

// Centralized Error handler
app.use(errorHandler);

module.exports = app;
