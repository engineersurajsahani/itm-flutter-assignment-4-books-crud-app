require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 5001;

const server = app.listen(PORT, () => {
  console.log(`========================================`);
  console.log(`  Books CRUD API Server is running!`);
  console.log(`  Port: ${PORT}`);
  console.log(`  Health Check: http://localhost:${PORT}/api/health`);
  console.log(`  Books Base URL: http://localhost:${PORT}/api/books`);
  console.log(`========================================`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
