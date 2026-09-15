require('dotenv').config();

const express = require('express');
const cors = require('cors');

const { db } = require('./src/config/firebase');
const bookRoutes = require('./src/routes/bookRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Books CRUD API is running',
  });
});

app.use('/api/books', bookRoutes);

const PORT = process.env.PORT || 5050;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});