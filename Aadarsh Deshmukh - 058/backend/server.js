const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bookRouter = require('./router/bookRouter');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({ message: 'Books CRUD API is running successfully!' });
});

// Mount routes
app.use('/api/books', bookRouter);
app.use('/books', bookRouter);

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
