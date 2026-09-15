# 📚 Books CRUD Backend API (Node.js + Express + Firebase Firestore)

A production-grade RESTful CRUD backend API for the **Books Management Application**, designed for seamless integration with Flutter mobile and web apps.

---

## 🚀 Features

- **Full RESTful CRUD operations**: Create, Read (List & Detail), Update, and Delete books.
- **Firebase Firestore Integration**: Powered by Firebase Admin SDK.
- **Data Validation & Sanitization**: Strict validation for required fields, numeric constraints, and date formatting.
- **ISBN Uniqueness Enforcement**: Prevents duplicate book records.
- **Search & Filtering**: Search across title, author, genre, and ISBN, with sorting support.
- **CORS Configured**: Ready for Flutter Web, iOS Simulator, and Android Emulator connections.
- **Built-in Mock Fallback Mode**: If Firebase credentials are not yet configured, the server automatically starts using an in-memory mock Firestore store for instant local testing without crashing.

---

## 📁 Directory Structure

```text
backend/
├── src/
│   ├── config/
│   │   └── firebase.js          # Firebase Admin SDK & mock fallback configuration
│   ├── controllers/
│   │   └── bookController.js    # Business logic & CRUD endpoint handlers
│   ├── models/
│   │   └── bookModel.js         # Validation schemas, sanitization & data formatters
│   └── routes/
│       └── bookRoutes.js        # Express routing for /api/books
├── .env                         # Local environment variables
├── .env.example                 # Environment configuration template
├── .gitignore                   # Ignores node_modules, .env, serviceAccountKey.json
├── package.json                 # Dependencies & scripts
├── server.js                    # Express app entrypoint & middleware
├── test_api.js                  # Automated test runner for all endpoints
└── README.md                    # Project documentation
```

---

## 🛠️ Installation & Setup

### 1. Prerequisites
- Node.js version 16.x or higher
- npm version 8.x or higher

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Firebase Configuration

You have **two options** to connect your Firebase Firestore database:

#### Option A: Service Account JSON file (Recommended)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project -> **Project settings** (⚙️ gear icon) -> **Service accounts**.
3. Click **Generate new private key** and download the `.json` file.
4. Rename the file to `serviceAccountKey.json` and place it in the `backend/` directory:
   ```bash
   backend/serviceAccountKey.json
   ```
5. In your Firebase Console, make sure **Cloud Firestore** is enabled (in Test mode or with read/write rules).

#### Option B: Environment Variables
Alternatively, open `backend/.env` and specify credentials directly:
```env
PORT=5000
NODE_ENV=development

FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

> 💡 **Note**: If you don't have Firebase credentials yet, you can still start the server immediately! It will run in **InMemory Mock Mode** and switch to Firestore automatically when credentials are provided.

---

## 🏃 Running the Application

### Start Development Server (Auto-reload with Nodemon)
```bash
npm run dev
```

### Start Production Server
```bash
npm start
```

### Run Automated API Tests
```bash
npm test
```

---

## 🔗 API Reference

**Base URL**: `http://localhost:5000/api/books`

### Book Schema
| Field | Type | Required | Description |
|---|---|---|---|
| `id` | String | Auto | Unique Firestore Document ID |
| `title` | String | Yes | Book title |
| `author` | String | Yes | Author name |
| `isbn` | String | Yes (Unique) | ISBN identifier |
| `genre` | String | No | Book category / genre |
| `price` | Number | No | Price in USD (>= 0) |
| `quantity` | Integer | No | Available stock quantity (>= 0) |
| `description` | String | No | Book summary / synopsis |
| `publisher` | String | No | Publishing company name |
| `publishedDate`| ISO Date / String | No | Date of publication |
| `createdAt` | ISO Timestamp | Auto | Creation timestamp |
| `updatedAt` | ISO Timestamp | Auto | Last update timestamp |

---

### Endpoints

#### 1. Get All Books
- **Method**: `GET`
- **Path**: `/api/books`
- **Query Parameters**:
  - `search` *(optional)*: Filter by title, author, isbn, or genre (e.g., `?search=clean`)
  - `genre` *(optional)*: Filter by exact genre
  - `sortBy` *(optional)*: Field to sort by (`title`, `price`, `publishedDate`, default: `title`)
  - `sortOrder` *(optional)*: `asc` or `desc` (default: `asc`)
- **Response**: `200 OK`
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": "c1f7a2d8",
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "isbn": "978-0132350884",
      "genre": "Software Engineering",
      "price": 37.99,
      "quantity": 15,
      "description": "A handbook of agile software craftsmanship.",
      "publisher": "Prentice Hall",
      "publishedDate": "2008-08-01T00:00:00.000Z",
      "createdAt": "2026-09-04T13:00:00.000Z",
      "updatedAt": "2026-09-04T13:00:00.000Z"
    }
  ]
}
```

---

#### 2. Get Single Book by ID
- **Method**: `GET`
- **Path**: `/api/books/:id`
- **Response**:
  - `200 OK`: Returns book object
  - `404 Not Found`: If book does not exist

---

#### 3. Add a New Book
- **Method**: `POST`
- **Path**: `/api/books`
- **Header**: `Content-Type: application/json`
- **Request Body**:
```json
{
  "title": "The Pragmatic Programmer",
  "author": "Andrew Hunt & David Thomas",
  "isbn": "978-0201616224",
  "genre": "Software Engineering",
  "price": 45.50,
  "quantity": 10,
  "description": "Your journey to mastery.",
  "publisher": "Addison-Wesley",
  "publishedDate": "1999-10-30"
}
```
- **Response**:
  - `201 Created`: Book created successfully
  - `400 Bad Request`: Missing required fields or invalid types
  - `409 Conflict`: A book with this ISBN already exists

---

#### 4. Update a Book
- **Method**: `PUT`
- **Path**: `/api/books/:id`
- **Header**: `Content-Type: application/json`
- **Request Body**: (Pass only fields you wish to update)
```json
{
  "price": 42.00,
  "quantity": 8
}
```
- **Response**:
  - `200 OK`: Book updated successfully
  - `400 Bad Request`: Validation failure
  - `404 Not Found`: Book ID not found
  - `409 Conflict`: New ISBN already in use by another book

---

#### 5. Delete a Book
- **Method**: `DELETE`
- **Path**: `/api/books/:id`
- **Response**:
  - `200 OK`: Book deleted successfully
  - `404 Not Found`: Book ID not found

---

## 🧪 Testing with cURL

### 1. Create a Book
```bash
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Design Patterns",
    "author": "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
    "isbn": "978-0201633610",
    "genre": "Computer Science",
    "price": 49.99,
    "quantity": 5,
    "description": "Elements of Reusable Object-Oriented Software.",
    "publisher": "Addison-Wesley",
    "publishedDate": "1994-10-21"
  }'
```

### 2. Fetch All Books
```bash
curl http://localhost:5000/api/books
```

### 3. Search Books
```bash
curl "http://localhost:5000/api/books?search=Design"
```

### 4. Fetch Book By ID
```bash
curl http://localhost:5000/api/books/<BOOK_ID>
```

### 5. Update Book
```bash
curl -X PUT http://localhost:5000/api/books/<BOOK_ID> \
  -H "Content-Type: application/json" \
  -d '{ "price": 44.99, "quantity": 12 }'
```

### 6. Delete Book
```bash
curl -X DELETE http://localhost:5000/api/books/<BOOK_ID>
```

---

## 📱 Connecting from Flutter

When connecting your Flutter frontend to this backend:

| Flutter Platform | Base URL |
|---|---|
| **Flutter Web / macOS Desktop** | `http://localhost:5000/api/books` |
| **iOS Simulator** | `http://127.0.0.1:5000/api/books` |
| **Android Emulator** | `http://10.0.2.2:5000/api/books` |
| **Physical Mobile Device** | `http://<YOUR_LOCAL_IP>:5000/api/books` (Ensure both on same Wi-Fi) |
