# 🚀 Books CRUD Backend (Node.js + Express + Firebase Firestore)

REST API backend for the Books CRUD Application.

---

## 🛠️ Setup & Running

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Firebase Credentials
Place your `serviceAccountKey.json` inside this `backend/` folder.

### 3. Seed Database (Optional)
Populate your Cloud Firestore with 8 sample books:
```bash
npm run seed
```

### 4. Start Server
```bash
# Production mode
npm start

# Development mode (auto-reload on save)
npm run dev
```

Server runs on: **`http://localhost:5050`**

---

## 📡 API Endpoints

- **`GET /api/health`** — Health check
- **`GET /api/books`** — Get all books
- **`GET /api/books/:id`** — Get single book
- **`POST /api/books`** — Create new book (enforces unique ISBN)
- **`PUT /api/books/:id`** — Update book
- **`DELETE /api/books/:id`** — Delete book

---

## 🧪 Tests
```bash
npm test
```
