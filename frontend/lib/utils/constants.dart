import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // App branding
  static const String appTitle = 'Books CRUD';
  static const String appSubtitle = 'Manage your library collection';

  // Base API configuration
  // You can override at build time with: --dart-define=API_BASE_URL=http://your-ip:5000/api/books
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get defaultBaseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'https://backend-mauve-five-11.vercel.app/api/books';
    }

    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback alias
        return 'http://10.0.2.2:5001/api/books';
      }
    } catch (_) {
      // Fallback for non-supported platforms
    }

    // iOS Simulator, macOS Desktop, Linux, Windows
    return 'http://localhost:5001/api/books';
  }

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Common Genres for picker & filter
  static const List<String> commonGenres = [
    'Fiction',
    'Non-Fiction',
    'Technology',
    'Self-Help',
    'Classic',
    'Science',
    'Biography',
    'History',
    'Mystery',
    'Fantasy',
    'Business',
    'Philosophy',
  ];
}
