# 📚 Books CRUD Application (Assignment 4)
Full Stack Assignment - Flutter + Node.js + Firebase Firestore

> **Student Name**: Om Sawant  
> **Assignment**: Assignment 4 - Books CRUD Application  

---

## 🎯 Overview

This is a Full Stack Books Management CRUD Application built using:
- 📱 **Frontend**: Flutter Mobile App (Dart 3.0+, Material Design 3, Provider State Management, HTTP REST client)
- ⚡ **Backend**: Node.js + Express.js REST API
- 🔥 **Database**: Firebase Cloud Firestore (`firebase-admin` SDK)

---

## 📱 Features

- 📖 **Book List Screen**: Displays all books with real-time search, genre filter chips, stock status badges, pull-to-refresh, empty state, and Floating Action Button (FAB).
- ➕ **Add Book Screen**: Input form with validation for Title, Author, ISBN, Genre, Price, Quantity, Publisher, Description, and Date Picker.
- ✏️ **Edit Book Screen**: Form pre-filled with existing book details for seamless updating.
- 🔍 **Book Detail Screen**: Detailed metadata view with stock status and action buttons.
- 🗑️ **Delete Confirmation**: Modal alert dialog before deleting a book.

---

## 🛠️ Project Structure

```
.
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js          # Firebase Admin SDK & Firestore initialization
│   │   ├── controllers/
│   │   │   └── bookController.js    # Request handlers with validation
│   │   ├── models/
│   │   │   └── bookModel.js         # Firestore CRUD operations
│   │   └── routes/
│   │       └── bookRoutes.js        # Express router mapping /api/books
│   ├── .env                         # Server port configuration (PORT=5001)
│   ├── package.json                 # Express, CORS, Dotenv, Firebase-Admin
│   └── server.js                    # Express app server entry point
├── lib/
│   ├── models/
│   │   └── book.dart                # Book Dart model class with serialization
│   ├── providers/
│   │   └── book_provider.dart       # State management Provider (ChangeNotifier)
│   ├── screens/
│   │   ├── add_book.dart            # Add Book form widget
│   │   ├── book_detail.dart         # Book Detail widget & delete dialog
│   │   ├── book_list.dart           # Main list view with search & genre filter
│   │   └── edit_book.dart           # Edit Book form widget
│   ├── services/
│   │   └── api_service.dart         # REST client API service using http
│   └── main.dart                    # App entry point with MultiProvider
├── pubspec.yaml                     # Dependencies (http, provider, image_picker, intl)
└── README.md
```

---

## 🚀 How to Run locally

### 1. Start Node.js Express Backend
```bash
cd backend
npm install
npm start
```
*Server runs on `http://localhost:5001`.*

### 2. Run Flutter App
```bash
flutter pub get
flutter run
```

---

## 🔗 API Endpoints

| Method | Endpoint | Description | Request Body |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/books` | Get all books | None |
| **GET** | `/api/books/:id` | Get specific book details | None |
| **POST** | `/api/books` | Add new book | Book JSON object |
| **PUT** | `/api/books/:id` | Update existing book | Book JSON object |
| **DELETE**| `/api/books/:id` | Delete book by ID | None |
