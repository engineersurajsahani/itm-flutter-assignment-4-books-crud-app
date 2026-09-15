const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

const books = [
  {
    id: '1',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '9780132350884',
    genre: 'Programming',
    price: 29.99,
    quantity: 12,
    description: 'A handbook of agile software craftsmanship.',
    publisher: 'Prentice Hall',
    publishedDate: '2008-08-11T00:00:00.000Z'
  },
  {
    id: '2',
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt',
    isbn: '9780201616224',
    genre: 'Programming',
    price: 34.5,
    quantity: 8,
    description: 'A practical guide to better software development.',
    publisher: 'Addison-Wesley',
    publishedDate: '1999-10-20T00:00:00.000Z'
  },
  {
    id: '3',
    title: 'Flutter in Action',
    author: 'Eric Windmill',
    isbn: '9781617298223',
    genre: 'Mobile',
    price: 42.0,
    quantity: 5,
    description: 'Learn how to build mobile apps with Flutter.',
    publisher: 'Manning',
    publishedDate: '2021-06-01T00:00:00.000Z'
  }
];

app.get('/api/books', (req, res) => {
  res.json(books);
});

app.get('/api/books/:id', (req, res) => {
  const book = books.find((item) => item.id === req.params.id);
  if (!book) {
    return res.status(404).json({ message: 'Book not found' });
  }
  return res.json(book);
});

app.post('/api/books', (req, res) => {
  const book = { ...req.body, id: Date.now().toString() };
  books.unshift(book);
  return res.status(201).json(book);
});

app.put('/api/books/:id', (req, res) => {
  const index = books.findIndex((item) => item.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Book not found' });
  }

  books[index] = { ...books[index], ...req.body };
  return res.json(books[index]);
});

app.delete('/api/books/:id', (req, res) => {
  const index = books.findIndex((item) => item.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Book not found' });
  }

  books.splice(index, 1);
  return res.status(200).json({ message: 'Book deleted' });
});

app.listen(PORT, () => {
  console.log(`Books backend running on http://localhost:${PORT}`);
});
