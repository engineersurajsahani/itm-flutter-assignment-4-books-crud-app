const express = require('express');
const cors = require('cors');
const books = require('./src/routes/bookRoutes');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/api/books', books);
app.get('/health', (req, res) => res.json({ status: 'ok' }));

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`Books API running on port ${port}`));
