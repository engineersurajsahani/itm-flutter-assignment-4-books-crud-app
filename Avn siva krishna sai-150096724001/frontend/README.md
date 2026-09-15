# Books CRUD Flutter Application

A production-quality Flutter mobile application utilizing Material Design 3, Provider state management, and clean architecture to manage books via a Node.js REST API.

## Features

- **Book Catalog**: Browse all books with cards displaying Title, Author, Genre, Price, Stock status, and ISBN.
- **Dynamic Search**: Instant client-side search by title, author, ISBN, or genre with a single-tap clear button.
- **Genre Filtering**: Horizontal interactive filter chips with auto-detected unique genres.
- **Pull-to-Refresh**: Standard `RefreshIndicator` on the book catalog.
- **Add Book**: Reusable form with strict client-side validation, numeric keyboards, and published date picker.
- **Edit Book**: Pre-populated form allowing seamless book details modification.
- **View Book Details**: Dedicated detail screen with structured metadata card, stock badges, and description.
- **Delete Confirmation**: Safety alert dialog confirming deletion before API call.
- **State Feedback**: Seamless handling of loading, error (with retry button), and empty states (distinguishing between empty library and no search matches).
- **Toast / SnackBar Notifications**: Clear success and failure feedback for all CRUD operations.

## Architecture

```
lib/
├── models/
│   └── book.dart            # Immutable Book entity with fromJson, toJson, copyWith
├── providers/
│   └── book_provider.dart   # ChangeNotifier handling state, search, filters, CRUD
├── services/
│   └── api_service.dart     # HTTP client communicating with Node.js Express backend
├── screens/
│   ├── book_list_screen.dart    # Primary catalog screen
│   ├── book_detail_screen.dart  # Detailed specifications & actions screen
│   ├── add_book_screen.dart     # Book creation screen
│   └── edit_book_screen.dart    # Book modification screen
├── widgets/
│   ├── book_card.dart       # Individual book card
│   ├── book_form.dart       # Reusable form component
│   ├── empty_state.dart     # Context-aware empty state
│   ├── error_state.dart     # Error message with retry action
│   └── loading_view.dart    # Centralized progress indicator
├── utils/
│   ├── constants.dart       # API base URLs, timeouts, default genres
│   ├── app_theme.dart       # Material 3 typography and color scheme
│   └── validators.dart      # Form field validators
└── main.dart                # App entry point with Provider registration
```

## Prerequisites

- Flutter SDK (>= 3.22.0)
- Dart SDK (>= 3.4.0)

## Getting Started

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run Analyzer & Tests:
   ```bash
   flutter analyze
   flutter test
   ```

4. Run the Application:
   - On macOS Desktop:
     ```bash
     flutter run -d macos
     ```
   - On iOS Simulator:
     ```bash
     flutter run -d iphone
     ```
   - On Android Emulator:
     ```bash
     flutter run -d android
     ```
   - On Chrome / Web:
     ```bash
     flutter run -d chrome
     ```

## API URL Configuration

The application automatically resolves the correct endpoint for your environment:
- **Android Emulator**: Uses `http://10.0.2.2:5000/api/books`
- **iOS Simulator / macOS / Web**: Uses `http://localhost:5000/api/books`

### Custom API Host / Physical Device Testing
To run against a specific backend host or LAN IP address, pass `--dart-define`:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:5000/api/books
```
