# 📚 Books CRUD Application - Backend (Node.js + Express + Firebase)

Backend REST API for the Books CRUD mobile application, built with **Express.js** and **Firebase Firestore** using the **Firebase Admin SDK**.

---

## 📁 Directory Structure

```
backend/
├── src/
│   ├── config/
│   │   └── firebase.js       # Firebase Admin initialization & fallback handler
│   ├── controllers/
│   │   └── bookController.js # CRUD business logic, validation & filtering
│   ├── models/
│   │   └── bookModel.js      # Book schema matching Flutter model
│   └── routes/
│       └── bookRoutes.js     # Express router for /api/books
├── .env                      # Local environment variables
├── .env.example              # Example environment configuration
├── .gitignore
├── package.json
├── README.md
└── server.js                 # App entry point & middleware
```

---

## ⚡ Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Configuration
The `.env` file is pre-created. You can adjust the port if needed:
```env
PORT=5000
NODE_ENV=development
FIREBASE_SERVICE_ACCOUNT_KEY=./serviceAccountKey.json
```

### 3. Connect to Firebase Firestore (Recommended)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create or select your Firebase project.
3. In the left sidebar, click **Build > Firestore Database** and click **Create database** (start in Test mode or Production mode).
4. Click the gear icon ⚙️ next to **Project Overview** and select **Project Settings**.
5. Switch to the **Service accounts** tab.
6. Click **Generate new private key** and confirm by clicking **Generate key**.
7. Rename the downloaded JSON file to `serviceAccountKey.json` and place it directly inside the `backend/` directory:
   ```
   backend/serviceAccountKey.json
   ```

> 💡 **Instant Testing / Mock Mode**:
> If you start the server before placing `serviceAccountKey.json`, the backend automatically runs in **Mock in-memory mode** with seeded books. This lets you test the API and Flutter UI immediately without waiting for Firebase setup!

### 4. Start the Server
```bash
# Production start
npm start

# Or Development with auto-reload (nodemon)
npm run dev
```

---

## 🔗 API Endpoints

Base URL: `http://localhost:5000/api/books`

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| `GET` | `/api/books` | Get all books (supports `search`, `genre`, `sortBy`, `order`) | None |
| `GET` | `/api/books/:id` | Get single book by ID | None |
| `POST` | `/api/books` | Create a new book | Book JSON object |
| `PUT` | `/api/books/:id` | Update an existing book | Book JSON object |
| `DELETE`| `/api/books/:id` | Delete a book | None |

---

## 📖 Book Data Schema

Matching the Flutter Dart model:

```json
{
  "id": "auto-generated-string",
  "title": "Flutter in Action",
  "author": "Eric Windmill",
  "isbn": "978-1617296147",
  "genre": "Mobile Development",
  "price": 39.99,
  "quantity": 12,
  "description": "Teach yourself Flutter and Dart from scratch.",
  "publisher": "Manning Publications",
  "publishedDate": "2020-01-07T00:00:00.000Z",
  "createdAt": "2026-09-04T08:00:00.000Z",
  "updatedAt": "2026-09-04T08:00:00.000Z"
}
```

---

## 🧪 cURL Testing Examples

### 1. Health Check
```bash
curl -X GET http://localhost:5000/
```

### 2. Get All Books
```bash
curl -X GET http://localhost:5000/api/books
```

### 3. Search & Filter Books
```bash
# Search by title/author/isbn
curl -X GET "http://localhost:5000/api/books?search=Clean"

# Filter by genre
curl -X GET "http://localhost:5000/api/books?genre=Programming"
```

### 4. Create a Book
```bash
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Design Patterns: Elements of Reusable Object-Oriented Software",
    "author": "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
    "isbn": "978-0201633610",
    "genre": "Software Engineering",
    "price": 49.99,
    "quantity": 10,
    "description": "Classic book on object-oriented software design patterns.",
    "publisher": "Addison-Wesley Professional",
    "publishedDate": "1994-10-31"
  }'
```

### 5. Get Book by ID
```bash
curl -X GET http://localhost:5000/api/books/book_seed_1
```

### 6. Update a Book
```bash
curl -X PUT http://localhost:5000/api/books/book_seed_1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 34.99,
    "quantity": 20
  }'
```

### 7. Delete a Book
```bash
curl -X DELETE http://localhost:5000/api/books/book_seed_1
```
