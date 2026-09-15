const express = require('express');
const cors = require('cors');
require('dotenv').config();

const bookRoutes = require('./src/routes/bookRoutes');
const { isMock } = require('./src/config/firebase');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors({
  origin: '*', // Allow Flutter app / web / emulators
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Root / Health Check Route
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'online',
    message: '📚 Books CRUD API Server is running',
    timestamp: new Date().toISOString(),
    databaseMode: isMock() ? 'Mock In-Memory (No credentials detected)' : 'Firebase Firestore Connected',
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

// 404 Not Found Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Cannot ${req.method} ${req.originalUrl} - Endpoint not found`
  });
});

// Global Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start Server
if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`\n🚀 Server listening on port ${PORT}`);
    console.log(`🔗 Base URL: http://localhost:${PORT}`);
    console.log(`📖 Books API: http://localhost:${PORT}/api/books\n`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.warn(`\n⚠️  Port ${PORT} is already in use (macOS AirPlay Receiver occupies port 5000 by default).`);
      const fallbackPort = Number(PORT) === 5000 ? 5001 : Number(PORT) + 1;
      console.log(`🔄 Attempting to start on fallback port ${fallbackPort}...`);
      const fallbackServer = app.listen(fallbackPort, () => {
        console.log(`\n🚀 Server listening on fallback port ${fallbackPort}`);
        console.log(`🔗 Base URL: http://localhost:${fallbackPort}`);
        console.log(`📖 Books API: http://localhost:${fallbackPort}/api/books\n`);
        console.log(`💡 Tip: To free port 5000 on macOS, turn off 'AirPlay Receiver' in System Settings > General > AirDrop & AirPlay.\n`);
      });
      fallbackServer.on('error', (fallbackErr) => {
        console.error('❌ Failed to start on fallback port:', fallbackErr.message);
      });
    } else {
      console.error('Server error:', err);
    }
  });
}

module.exports = app;
