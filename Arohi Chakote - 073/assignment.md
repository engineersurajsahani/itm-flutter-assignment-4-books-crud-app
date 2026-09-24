# 📚 Books CRUD Application

**Full Stack Assignment - Flutter + Node.js + Firebase**

🎯 Flutter UI | ⚡ Node.js API | 🔥 Firebase

**Last Updated:** September 4, 2026

| Layer | Tech |
|---|---|
| 📱 Frontend | Flutter Mobile App |
| ⚙️ Backend | Node.js + Express.js |
| 🗄️ Database | Firebase Firestore |
| 🔗 API | RESTful CRUD APIs |

---

## 🎯 Learning Objectives

इस assignment को complete करने के बाद आप सीखेंगे:

### 📱 Frontend Skills
- Flutter में cross-platform app बनाना
- State management (Provider/GetX)
- API integration with HTTP
- Form validation and error handling
- Responsive UI design

### ⚡ Backend Skills
- REST API design and implementation
- Express.js routing and middleware
- Firebase Firestore integration
- Data validation and error handling
- Environment configuration

---

## 📋 Technical Requirements

### 🖥️ Frontend (Flutter)
- Flutter SDK 3.0+
- Dart 3.0+
- HTTP package for API calls

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.0
  image_picker: ^1.0.0
```

### 🔧 Backend (Node.js)
- Node.js 16+
- Express.js 4.x
- Firebase Admin SDK
- CORS for cross-origin requests
- dotenv for environment variables

```json
// package.json dependencies
"dependencies": {
  "express": "^4.18.2",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1",
  "firebase-admin": "^11.11.0"
}
```

---

## 📖 Book Model

### Field Description
| Field | Description |
|---|---|
| `id` | Unique identifier (auto-generated) |
| `title` | Book title (Required) |
| `author` | Author name (Required) |
| `isbn` | ISBN number (Unique) |
| `genre` | Book genre |
| `price` | Price in USD |
| `quantity` | Available quantity |
| `description` | Book description |
| `publisher` | Publisher name |
| `publishedDate` | Publication date |

### Dart Model

```dart
class Book {
  String id;
  String title;
  String author;
  String isbn;
  String genre;
  double price;
  int quantity;
  String description;
  String publisher;
  DateTime publishedDate;
}
```

---

## 🔗 API Endpoints

**Base URL:** `http://localhost:5000/api/books`

| Method | Endpoint | Description | Request Body |
|---|---|---|---|
| GET | `/` | Get all books | None |
| GET | `/:id` | Get a specific book | None |
| POST | `/` | Add a new book | Book object (JSON) |
| PUT | `/:id` | Update a book | Book object (JSON) |
| DELETE | `/:id` | Delete a book | None |

---

## 📱 Flutter Screens

### 🖼️ Required Screens
- **Book List Screen** – All books की list with search
- **Add Book Screen** – नई book add करने का form
- **Edit Book Screen** – Book edit करने का form
- **Book Detail Screen** – Book की detailed view
- **Delete Confirmation** – Delete से पहले confirmation

### ✨ UI Features
- Material Design components
- Form validation with error messages
- Loading indicators for API calls
- Toast/Snackbar notifications
- Pull to refresh functionality
- Search and filter books

---

## 📁 Project Structure

### 📱 Flutter Structure
```
lib/
├── models/
│   └── book.dart
├── screens/
│   ├── book_list.dart
│   ├── add_book.dart
│   ├── edit_book.dart
│   └── book_detail.dart
├── services/
│   └── api_service.dart
└── main.dart
```

### ⚡ Backend Structure
```
backend/
├── src/
│   ├── controllers/
│   │   └── bookController.js
│   ├── models/
│   │   └── bookModel.js
│   ├── routes/
│   │   └── bookRoutes.js
│   └── config/
│       └── firebase.js
├── .env
├── package.json
└── server.js
```

---

**📚 Books CRUD App Assignment**
Made with ❤️ for students
© 2026 - All Rights Reserved

*Source: https://itm-flutter-assignment-4-books-app.netlify.app/*
