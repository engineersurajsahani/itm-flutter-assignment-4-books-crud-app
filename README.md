# Books CRUD Full-Stack Application

A full-stack book management application with a **Flutter mobile client**, a **Node.js/Express REST API**, and **Firebase Cloud Firestore** database persistence.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                       │
│    (Material Design 3, Provider State Management, HTTP)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ REST API (HTTP / JSON)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Node.js + Express Server                    │
│      (Validation, ISBN Uniqueness, Central Error Handler)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ Firebase Admin SDK
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   Firebase Cloud Firestore                  │
│                (Collection: "books/{docId}")                │
└─────────────────────────────────────────────────────────────┘
```

> **Security Note**: The Flutter client never communicates directly with Firestore and contains zero Firebase secrets or service accounts. All database interactions are mediated by the Express API.

---

## Features

1. **View All Books**: Browse books with cards displaying Title, Author, Genre badge, Price, Quantity in stock, and ISBN.
2. **Search Books**: Fast dynamic search by Title, Author, ISBN, or Genre with a one-tap clear button.
3. **Filter Books**: Filter dynamically by Genre using horizontally scrollable chips.
4. **View Book Details**: Dedicated screen with organized book specifications, stock status, and description.
5. **Add New Book**: Reusable form with strict validation, numeric keyboards, and published date picker.
6. **Edit Existing Book**: Pre-populated form allowing seamless book modification.
7. **Delete Book**: Safety confirmation dialog before deletion.
8. **Pull-to-Refresh**: Easily refresh the book list using `RefreshIndicator`.
9. **State Feedback**: Polished loading indicators, contextual empty states, error states with retry buttons, and Floating SnackBars.
10. **ISBN Uniqueness**: Backend rejects duplicate ISBNs with HTTP 409 Conflict.

---

## Technology Stack

- **Frontend**: Flutter 3, Dart, Material Design 3, `provider`, `http`, `intl`
- **Backend**: Node.js, Express.js, `cors`, `dotenv`, `firebase-admin`
- **Database**: Firebase Cloud Firestore
- **Tooling**: Nodemon, Flutter Analyzer, Jest/HTTP test runner

---

## Project Structure

```
Assignment-4/
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js          # Firebase Admin SDK & DB connection
│   │   ├── controllers/
│   │   │   └── bookController.js    # Express route handlers
│   │   ├── middleware/
│   │   │   └── errorHandler.js      # Centralized error handler & 404
│   │   ├── models/
│   │   │   └── bookModel.js         # Book entity & serialization
│   │   ├── routes/
│   │   │   └── bookRoutes.js        # REST endpoint routes
│   │   ├── services/
│   │   │   └── bookService.js       # Firestore CRUD & ISBN conflict logic
│   │   ├── validators/
│   │   │   └── bookValidator.js     # Request payload validator
│   │   └── app.js                   # Express app configuration
│   ├── scripts/
│   │   ├── seed.js                  # Database seeder script
│   │   └── test-api.js              # Automated endpoint test suite
│   ├── server.js                    # Server startup entry point
│   ├── package.json                 # Backend dependencies & scripts
│   ├── .env.example                 # Environment variables template
│   ├── .gitignore                   # Backend ignore rules
│   └── README.md
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   │   └── book.dart            # Dart Book model (fromJson, toJson, copyWith)
│   │   ├── providers/
│   │   │   └── book_provider.dart   # Provider state management
│   │   ├── services/
│   │   │   └── api_service.dart     # HTTP client for REST communication
│   │   ├── screens/
│   │   │   ├── book_list_screen.dart    # Catalog screen (Search, Filter, List)
│   │   │   ├── book_detail_screen.dart  # Detailed specifications & actions
│   │   │   ├── add_book_screen.dart     # Create book screen
│   │   │   └── edit_book_screen.dart    # Update book screen
│   │   ├── widgets/
│   │   │   ├── book_card.dart       # Book card widget
│   │   │   ├── book_form.dart       # Reusable form component
│   │   │   ├── empty_state.dart     # Context-aware empty state
│   │   │   ├── error_state.dart     # Error state with retry
│   │   │   └── loading_view.dart    # Progress indicator
│   │   ├── utils/
│   │   │   ├── constants.dart       # Central configuration & base URLs
│   │   │   ├── app_theme.dart       # Material 3 design system
│   │   │   └── validators.dart      # Input validation utilities
│   │   └── main.dart                # Application entry point
│   ├── test/
│   │   ├── book_test.dart           # Model and validator tests
│   │   └── widget_test.dart         # Widget smoke test
│   ├── pubspec.yaml                 # Flutter dependencies
│   └── README.md
│
├── .gitignore                       # Root ignore rules
└── README.md                        # Master documentation
```

---

## Getting Started

### 1. Prerequisites
- [Node.js](https://nodejs.org/) (v18 or higher)
- [Flutter SDK](https://flutter.dev/) (v3.22 or higher)

---

### 2. Backend Setup

1. Open a terminal in the `backend/` directory:
   ```bash
   cd backend
   npm install
   ```

2. Setup environment variables:
   ```bash
   cp .env.example .env
   ```

3. Configure Firebase credentials in `backend/.env`:
   - **Option A (Environment Variables)**:
     ```env
     PORT=5000
     FIREBASE_PROJECT_ID=your-project-id
     FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project-id.iam.gserviceaccount.com
     FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgI...\n-----END PRIVATE KEY-----\n"
     ```
   - **Option B (Service Account JSON)**:
     Download your service account key from the Firebase Console (*Project Settings -> Service Accounts -> Generate new private key*), place it at `backend/serviceAccountKey.json`, and set:
     ```env
     FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
     ```

   *(Note: If no Firebase credentials are provided yet, the backend automatically uses an in-memory Firestore-compatible store so you can test immediately.)*

4. Start the backend:
   ```bash
   npm run dev
   ```
   Server will run at: `http://localhost:5000`

5. (Optional) Populate sample books:
   ```bash
   npm run seed
   ```

6. Run automated API tests:
   ```bash
   npm test
   ```

---

### 3. Frontend Setup

1. Open a new terminal in the `frontend/` directory:
   ```bash
   cd frontend
   flutter pub get
   ```

2. Verify code quality:
   ```bash
   flutter analyze
   flutter test
   ```

3. Launch the application:
   - **macOS Desktop**:
     ```bash
     flutter run -d macos
     ```
   - **iOS Simulator**:
     ```bash
     flutter run -d iphone
     ```
   - **Android Emulator**:
     ```bash
     flutter run -d android
     ```
   - **Chrome Web**:
     ```bash
     flutter run -d chrome
     ```

---

## API Configuration & Host Resolution

The Flutter app automatically detects the host environment:
| Environment | Base URL |
|---|---|
| **Android Emulator** | `http://10.0.2.2:5000/api/books` |
| **iOS Simulator / macOS / Web** | `http://localhost:5000/api/books` |
| **Physical Device (Custom LAN)** | `--dart-define=API_BASE_URL=http://<YOUR_LAN_IP>:5000/api/books` |

---

## REST API Specification

### Endpoints Overview

| Method | Endpoint | Description | Status Codes |
|---|---|---|---|
| `GET` | `/api/health` | Service health check | 200 |
| `GET` | `/api/books` | Fetch all books | 200 |
| `GET` | `/api/books/:id` | Fetch single book by ID | 200, 404 |
| `POST` | `/api/books` | Create a new book | 201, 400, 409 |
| `PUT` | `/api/books/:id` | Update an existing book | 200, 400, 404, 409 |
| `DELETE` | `/api/books/:id` | Delete a book by ID | 200, 404 |

### Example cURL Requests

#### Create a Book
```bash
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "isbn": "9780132350884",
    "genre": "Technology",
    "price": 34.50,
    "quantity": 8,
    "description": "A handbook of agile software craftsmanship.",
    "publisher": "Prentice Hall",
    "publishedDate": "2008-08-01T00:00:00.000Z"
  }'
```

#### Get All Books
```bash
curl http://localhost:5000/api/books
```

#### Update a Book
```bash
curl -X PUT http://localhost:5000/api/books/<BOOK_ID> \
  -H "Content-Type: application/json" \
  -d '{
    "price": 29.99,
    "quantity": 12
  }'
```

#### Delete a Book
```bash
curl -X DELETE http://localhost:5000/api/books/<BOOK_ID>
```

---

## Troubleshooting

1. **Connection refused on Android Emulator**:
   - Ensure the server is running on port 5000.
   - Use `http://10.0.2.2:5000/api/books` (already handled automatically in `AppConstants.defaultBaseUrl`).

2. **Network issues on physical mobile devices**:
   - Ensure both your mobile phone and computer are on the same Wi-Fi network.
   - Run the app using: `flutter run --dart-define=API_BASE_URL=http://<COMPUTER_LOCAL_IP>:5000/api/books`.

3. **Firebase private key newline issue**:
   - In `.env`, ensure the private key includes `\n` or is wrapped in double quotes. The backend automatically parses and replaces escaped `\n` characters.
