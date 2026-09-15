require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bookRoutes = require('./src/routes/bookRoutes');
const { isUsingMock } = require('./src/config/firebase');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for Flutter mobile/web requests
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parser middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logger middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Root & Health check routes
app.get('/', (req, res) => {
  res.status(200).json({
    message: '📚 Books CRUD API is up and running!',
    version: '1.0.0',
    endpoints: {
      getAllBooks: 'GET /api/books',
      getBookById: 'GET /api/books/:id',
      createBook: 'POST /api/books',
      updateBook: 'PUT /api/books/:id',
      deleteBook: 'DELETE /api/books/:id',
      health: 'GET /api/health'
    },
    databaseStatus: isUsingMock() ? 'InMemory Mock Mode' : 'Connected to Firestore'
  });
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    database: isUsingMock() ? 'mock' : 'live-firestore'
  });
});

// API Routes
app.use('/api/books', bookRoutes);

// 404 Route Not Found Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route '${req.method} ${req.originalUrl}' not found.`
  });
});

// Global Error Handler Middleware
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  const status = err.statusCode || err.status || 500;
  res.status(status).json({
    success: false,
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start Server only when executed directly
if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`\n🚀 Server listening on port ${PORT}`);
    console.log(`🔗 Base URL: http://localhost:${PORT}/api/books`);
    console.log(`📊 Mode: ${process.env.NODE_ENV || 'development'}\n`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.warn(`\n⚠️  Port ${PORT} is already in use (e.g. macOS AirPlay Receiver).`);
      const fallbackPort = Number(PORT) === 5000 ? 5050 : Number(PORT) + 1;
      console.log(`🔄 Attempting to start on fallback port ${fallbackPort}...`);
      app.listen(fallbackPort, () => {
        console.log(`\n🚀 Server listening on fallback port ${fallbackPort}`);
        console.log(`🔗 Base URL: http://localhost:${fallbackPort}/api/books\n`);
      });
    } else {
      console.error('Server error:', err);
    }
  });
}

module.exports = app;
