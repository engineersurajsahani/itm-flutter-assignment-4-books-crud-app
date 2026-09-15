require('dotenv').config({ quiet: true });

const express = require('express');
const cors = require('cors');
const bookRouter = require('./router/bookRouter');

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

app.get('/health', (request, response) => {
  response.status(200).json({
    success: true,
    message: 'Books API is running',
  });
});

app.use('/api/books', bookRouter);

app.use((request, response) => {
  response.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
