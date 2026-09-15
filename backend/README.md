# Books CRUD Backend API

Production-ready REST API built with Node.js, Express.js, and Firebase Admin SDK (Cloud Firestore) for managing books.

## Architecture

```
Client (Flutter Mobile App)
          │
          │ HTTP / REST (JSON)
          ▼
Express Server (Port 5000)
    │
    ├── Routes (src/routes/bookRoutes.js)
    ├── Validators (src/validators/bookValidator.js)
    ├── Controllers (src/controllers/bookController.js)
    └── Services (src/services/bookService.js)
          │
          │ Firebase Admin SDK
          ▼
Firebase Cloud Firestore (Collection: 'books')
```

## Features

- **Standard REST Endpoints**: GET all, GET single, POST create, PUT update, DELETE by ID.
- **ISBN Uniqueness**: Validates that ISBN is unique across the collection on creation and on update.
- **Input Validation**: Validates required fields, non-negative price, non-negative integer quantity, and valid date format.
- **Robust Error Handling**: Centralized error middleware returning clean, predictable JSON responses.
- **Health Check Endpoint**: `/api/health` for uptime monitoring.
- **Database Seeding**: Ready-to-run seed script (`npm run seed`) with sample classics and technology books.
- **Automated Test Suite**: Integrated test runner (`npm test`) executing end-to-end endpoint tests.
- **Credential Fallback**: Automatically connects to Firestore when credentials exist in `.env`, or runs an in-memory Firestore-compatible store for offline development/testing.

## Prerequisites

- Node.js >= 18 (Tested on v24.13.0)
- npm >= 9

## Setup & Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure Environment Variables:
   Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

4. Configure Firebase Credentials (Choose Option A or Option B):
   
   **Option A: Individual Environment Variables**
   ```env
   PORT=5000
   NODE_ENV=development
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project-id.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgI...\n-----END PRIVATE KEY-----\n"
   ```

   **Option B: Service Account JSON File**
   Download your service account key from the Firebase Console (*Project Settings -> Service Accounts -> Generate new private key*), save it as `serviceAccountKey.json` inside the `backend/` directory, and specify:
   ```env
   FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
   ```

## Running the Server

- **Development Mode (with auto-reload)**:
  ```bash
  npm run dev
  ```

- **Production Mode**:
  ```bash
  npm start
  ```

- **Run Automated API Tests**:
  ```bash
  npm test
  ```

- **Seed Database with Sample Books**:
  ```bash
  npm run seed
  ```

## API Documentation

Base URL: `http://localhost:5000/api/books`

### 1. Health Check
- **Endpoint**: `GET /api/health`
- **Response** (200 OK):
  ```json
  {
    "success": true,
    "message": "API is running"
  }
  ```

### 2. Get All Books
- **Endpoint**: `GET /api/books`
- **Response** (200 OK):
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "abc123xyz",
        "title": "The Alchemist",
        "author": "Paulo Coelho",
        "isbn": "9780061122415",
        "genre": "Fiction",
        "price": 14.99,
        "quantity": 12,
        "description": "A magical fable about following your dream.",
        "publisher": "HarperOne",
        "publishedDate": "1993-04-25T00:00:00.000Z",
        "createdAt": "2026-01-10T12:00:00.000Z",
        "updatedAt": "2026-01-10T12:00:00.000Z"
      }
    ]
  }
  ```

### 3. Get Single Book
- **Endpoint**: `GET /api/books/:id`
- **Success Response** (200 OK):
  ```json
  {
    "success": true,
    "data": { ...book object... }
  }
  ```
- **Error Response** (404 Not Found):
  ```json
  {
    "success": false,
    "message": "Book not found"
  }
  ```

### 4. Create Book
- **Endpoint**: `POST /api/books`
- **Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "isbn": "9780132350884",
    "genre": "Technology",
    "price": 34.50,
    "quantity": 8,
    "description": "A handbook of agile software craftsmanship.",
    "publisher": "Prentice Hall",
    "publishedDate": "2008-08-01T00:00:00.000Z"
  }
  ```
- **Success Response** (201 Created):
  ```json
  {
    "success": true,
    "message": "Book created successfully",
    "data": { "id": "...", ... }
  }
  ```
- **Conflict Response** (409 Conflict):
  ```json
  {
    "success": false,
    "message": "ISBN already exists"
  }
  ```
- **Validation Error** (400 Bad Request):
  ```json
  {
    "success": false,
    "message": "Price must be greater than or equal to 0"
  }
  ```

### 5. Update Book
- **Endpoint**: `PUT /api/books/:id`
- **Success Response** (200 OK):
  ```json
  {
    "success": true,
    "message": "Book updated successfully",
    "data": { ...updated book... }
  }
  ```

### 6. Delete Book
- **Endpoint**: `DELETE /api/books/:id`
- **Success Response** (200 OK):
  ```json
  {
    "success": true,
    "message": "Book deleted successfully"
  }
  ```
