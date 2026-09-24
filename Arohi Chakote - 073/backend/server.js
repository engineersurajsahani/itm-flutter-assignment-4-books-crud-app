const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bookRouter = require('./router/bookRouter');

dotenv.config();

const app = express();
const DEFAULT_PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({ message: 'Books CRUD API is running successfully!' });
});

// Mount routes
app.use('/api/books', bookRouter);
app.use('/books', bookRouter);

// Function to start listening with fallback port handling
function startServer(port) {
  const server = app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      const fallbackPort = port + 1;
      console.warn(`Port ${port} is in use. Attempting port ${fallbackPort}...`);
      startServer(fallbackPort);
    } else {
      console.error('Server error:', err);
    }
  });
}

startServer(DEFAULT_PORT);
