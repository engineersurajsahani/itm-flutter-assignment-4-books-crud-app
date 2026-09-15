# Books CRUD Backend

Backend for the Flutter books assignment.

## Stack

- Node.js
- Express.js
- Firebase Firestore

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Create `.env` from `.env.example` and fill in your Firebase service account values.

3. Start the server:

   ```bash
   npm run dev
   ```

The API runs at `http://localhost:5000/api/books`.

## Endpoints

- `GET /api/books`
- `GET /api/books/:id`
- `POST /api/books`
- `PUT /api/books/:id`
- `DELETE /api/books/:id`

## Example payload

```json
{
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "isbn": "9780132350884",
  "genre": "Software Engineering",
  "price": 29.99,
  "quantity": 7,
  "description": "A practical guide to writing maintainable code.",
  "publisher": "Prentice Hall",
  "publishedDate": "2008-08-01"
}
```
