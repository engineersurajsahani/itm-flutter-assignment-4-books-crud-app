# 📚 Books CRUD Application

A full-stack Mobile & Web Book Management application built using **Flutter**, **Node.js (Express.js)**, and **Firebase Cloud Firestore**.

---

## 📌 Project Overview

This project provides a full CRUD (Create, Read, Update, Delete) system for managing books in a library or bookstore setting. It features a modern, responsive **Flutter** client interface backed by a RESTful **Node.js Express** API that seamlessly synchronizes data with **Google Cloud Firestore**.

---

## 🏗️ Architecture & Technology Stack

```
vijaykota_4074_ass4/
├── backend/                  # Node.js + Express.js + Firebase Admin SDK API
│   ├── src/
│   │   ├── config/           # Firebase Admin initialization
│   │   ├── controllers/      # Business logic & Firestore database queries
│   │   ├── models/           # Book Data Model
│   │   └── routes/           # Express router endpoints
│   ├── .env                  # Environment configuration
│   ├── server.js             # API Server entry point (Port 5005)
│   └── package.json
│
└── frontend/                 # Flutter Application
    ├── lib/
    │   ├── models/           # Book Dart Model (JSON parsing)
    │   ├── services/         # API Service (HTTP client)
    │   ├── providers/        # Provider State Management & Search logic
    │   ├── screens/          # UI Components
    │   │   ├── book_list.dart # Book Listing + Search + Pull-to-Refresh
    │   │   ├── book_detail.dart# Detailed Book View
    │   │   └── book_form.dart  # Form screen for Adding & Editing Books
    │   └── main.dart         # Flutter Application Entrypoint
    └── pubspec.yaml
```

### **Technologies Used**
- **Frontend**: Flutter (Dart 3.x), `provider` for State Management, `http` for REST integration, `intl` for date formatting.
- **Backend**: Node.js, Express.js, `dotenv`, `cors`.
- **Database**: Google Firebase Cloud Firestore (`firebase-admin` SDK).

---

## 📖 Book Data Model Specification

Each book record contains the following fields:

| Field Name | Type | Description | Required |
| :--- | :--- | :--- | :--- |
| `id` | `String` | Unique auto-generated document ID | Yes (Auto) |
| `title` | `String` | Title of the book | Yes |
| `author` | `String` | Author name | Yes |
| `isbn` | `String` | Unique International Standard Book Number | No |
| `genre` | `String` | Book genre (e.g., Fiction, Classic, Tech) | No |
| `price` | `double` | Retail price in USD | No (Default: 0.0) |
| `quantity` | `int` | Available quantity in stock | No (Default: 0) |
| `description` | `String` | Overview or summary of the book | No |
| `publisher` | `String` | Publishing company name | No |
| `publishedDate`| `String` | Publication date (`YYYY-MM-DD`) | No |

---

## 🔗 Backend REST API Documentation

Base URL: `http://localhost:5005/api/books`

### **Endpoints**

#### **1. Get All Books**
- **URL**: `GET /api/books`
- **Description**: Retrieves all book documents from Cloud Firestore.
- **Response**: `200 OK`
```json
[
  {
    "id": "2bDK182LcMbmdrhIaUfp",
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "isbn": "9780743273565",
    "genre": "Classic",
    "price": 12.99,
    "quantity": 10,
    "description": "A novel set in the Jazz Age.",
    "publisher": "Scribner",
    "publishedDate": "1925-04-10"
  }
]
```

#### **2. Get Book by ID**
- **URL**: `GET /api/books/:id`
- **Description**: Fetches a single book document by its ID.
- **Response**: `200 OK` or `404 Not Found`.

#### **3. Add New Book**
- **URL**: `POST /api/books`
- **Description**: Creates a new book document in Firestore.
- **Body**: JSON object containing book details.
- **Response**: `201 Created`
```json
{
  "message": "Book created successfully",
  "id": "2bDK182LcMbmdrhIaUfp"
}
```

#### **4. Update Book**
- **URL**: `PUT /api/books/:id`
- **Description**: Updates an existing book document.
- **Body**: JSON object with fields to update.
- **Response**: `200 OK`

#### **5. Delete Book**
- **URL**: `DELETE /api/books/:id`
- **Description**: Deletes a book document from Firestore.
- **Response**: `200 OK`

---

## 🚀 Getting Started & Setup Guide

### **Prerequisites**
- Node.js (v16+) installed
- Flutter SDK (v3.0+) installed
- Firebase Project with **Cloud Firestore** enabled.

---

### **1. Backend Setup**

1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Place your Firebase Admin Service Account JSON file in the `backend/` directory (e.g. `book-crud-app-c863e-firebase-adminsdk-fbsvc-50cd991b2f.json`).
4. Ensure `.env` specifies the service account path and port:
   ```env
   PORT=5005
   FIREBASE_SERVICE_ACCOUNT=./book-crud-app-c863e-firebase-adminsdk-fbsvc-50cd991b2f.json
   ```
5. Start the backend server:
   ```bash
   npm start
   # or node server.js
   ```
   The API will start at `http://localhost:5005`.

---

### **2. Frontend Setup**

1. Navigate to the frontend folder:
   ```bash
   cd frontend
   ```
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   - For **Chrome / Web**:
     ```bash
     flutter run -d chrome
     ```
   - For **macOS / Mobile**:
     ```bash
     flutter run
     ```

---

## 📱 Mobile Screens Overview

1. **Book List Screen (`book_list.dart`)**:
   - Displays all books in card widgets.
   - Interactive search bar filtering by Title, Author, Genre, or ISBN.
   - Pull-to-refresh gesture support.
   - Action buttons to edit or open delete confirmation modal.
2. **Book Detail Screen (`book_detail.dart`)**:
   - Visual card with book info, price badge, inventory quantity, description, and metadata.
3. **Book Form Screen (`book_form.dart`)**:
   - Combined form used for creating and updating books.
   - Field validations and date picker for publication date.

---


Project discrption:https://itm-flutter-assignment-4-books-app.netlify.app/
