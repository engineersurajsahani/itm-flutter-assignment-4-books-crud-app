# 📚 Books CRUD Application (Flutter + Node.js + Firebase)

A complete, full-stack cross-platform application for managing books inventory and cataloging. Built with **Flutter** (Dart), **Node.js + Express.js**, and **Firebase Firestore**.

---

## 🎯 Features

### 📱 Flutter Mobile & Web Frontend
- **Material 3 Design**: Modern, responsive interface with customized indigo theme, smooth transitions, and rounded card UI.
- **State Management**: Reactive state management with **Provider** (`ChangeNotifier`).
- **Live Search & Filter**: Real-time search across titles, authors, genres, and ISBNs, plus horizontal genre chip carousel.
- **Inventory & Stock Tracking**: Dynamic badges for *In Stock*, *Low Stock (<= 5)*, and *Out of Stock*.
- **Comprehensive CRUD Screens**:
  - 📖 **Book List Screen**: Filterable grid/list with quick stats and pull-to-refresh.
  - ➕ **Add Book Screen**: Full form with validation, price/quantity checks, and date picker.
  - ✏️ **Edit Book Screen**: Pre-populated update form.
  - 🔍 **Book Detail Screen**: Hero view with metadata cards, publisher details, and timestamps.
  - 🗑️ **Delete Confirmation Dialog**: Safe deletion with instant UI sync and SnackBar feedback.

### ⚡ Node.js + Express + Firebase Backend
- **RESTful Endpoints**: Full CRUD endpoints mapped to `/api/books`.
- **Firebase Admin SDK**: Direct connection to live Firebase Firestore.
- **ISBN Uniqueness**: Validates and enforces unique ISBN across all records (HTTP 409 Conflict).
- **Data Validation & Sanitization**: Strict input validation before database writes.
- **CORS Configured**: Seamless communication across Flutter Web, iOS, Android, and Desktop.
- **Built-in Mock Fallback**: In-memory database store for testing even before Firebase keys are provided.

---

## 📁 Project Structure

```text
Assignment4/
├── backend/                       # Node.js + Express + Firebase API
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js        # Firebase Admin SDK & mock fallback
│   │   ├── controllers/
│   │   │   └── bookController.js  # CRUD controllers & search filters
│   │   ├── models/
│   │   │   └── bookModel.js       # Validation schemas & data formatters
│   │   └── routes/
│   │       └── bookRoutes.js      # Express /api/books routes
│   ├── serviceAccountKey.json     # Firebase service account private key
│   ├── server.js                  # Server entrypoint
│   ├── test_api.js                # Automated backend test suite
│   ├── package.json
│   └── README.md
├── lib/                           # Flutter Frontend App
│   ├── models/
│   │   └── book.dart              # Dart Book model & JSON serialization
│   ├── providers/
│   │   └── book_provider.dart     # Provider state manager
│   ├── screens/
│   │   ├── book_list.dart         # Books list, search, filters & stats
│   │   ├── add_book.dart          # Add book form with validation & datepicker
│   │   ├── edit_book.dart         # Edit book form
│   │   └── book_detail.dart       # Detailed book view & delete confirmation
│   ├── services/
│   │   └── api_service.dart       # HTTP REST service client
│   └── main.dart                  # Material 3 app config & theme
├── pubspec.yaml                   # Flutter dependencies
└── README.md                      # Full stack documentation
```

---

## 🚀 Getting Started

### 1. Start the Backend Server

```bash
cd backend
npm install
npm run dev
```
> The server will start on `http://localhost:5000` (or `http://localhost:5050` if port 5000 is occupied).
> Connected to Firebase project: `bookapp-55530`.

To run automated backend tests:
```bash
npm test
```

---

### 2. Run the Flutter App

From the project root:

```bash
# Get dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on macOS Desktop
flutter run -d macos

# Run on iOS Simulator or Android Emulator
flutter run
```

---

## 🔗 API Reference

**Base URL**: `http://localhost:5000/api/books`

| Method | Endpoint | Description | Request Body |
|---|---|---|---|
| `GET` | `/api/books` | Get all books (supports `?search=` and `?genre=`) | None |
| `GET` | `/api/books/:id` | Get book by ID | None |
| `POST` | `/api/books` | Add a new book | Book JSON object |
| `PUT` | `/api/books/:id` | Update existing book | Book JSON object |
| `DELETE` | `/api/books/:id` | Delete book | None |
| `GET` | `/api/health` | Health check & DB status | None |

---

## 🧪 Testing

### Backend Tests
```bash
cd backend && npm test
```
*Executes 25 automated assertions covering CRUD, validation, ISBN conflict rejection, search, and 404 responses.*

### Frontend Tests
```bash
flutter test
```
*Executes widget tests and smoke tests for the UI and state providers.*
