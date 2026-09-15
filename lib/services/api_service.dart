import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static String? _cachedBaseUrl;

  /// Dynamically determines the appropriate localhost URL based on device platform.
  /// Android Emulator uses 10.0.2.2, while iOS/macOS/Web use localhost.
  static String get defaultHost {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  /// Base API URL for books. Default port 5002 (fallback to 5001 or 5000 if needed).
  static String get baseUrl {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    return 'http://$defaultHost:5002/api/books';
  }

  /// Allows setting or updating the API URL manually (e.g. from app settings)
  static void setBaseUrl(String url) {
    _cachedBaseUrl = url;
  }

  /// Helper to send request with automatic port fallback (5002 -> 5001 -> 5000)
  static Future<http.Response> _requestWithFallback(
    Future<http.Response> Function(String url) requestFn,
    String path,
  ) async {
    final candidatePorts = ['5002', '5001', '5000'];
    final currentBase = baseUrl;

    // Try current base first
    try {
      final response = await requestFn('$currentBase$path')
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (_) {
      // Try other ports
      for (final port in candidatePorts) {
        final candidateBase = 'http://$defaultHost:$port/api/books';
        if (candidateBase == currentBase) continue;
        try {
          final response = await requestFn('$candidateBase$path')
              .timeout(const Duration(seconds: 4));
          _cachedBaseUrl = candidateBase;
          return response;
        } catch (_) {
          continue;
        }
      }
      throw Exception('Could not connect to backend server. Make sure backend is running.');
    }
  }

  /// GET /api/books (with optional search, genre, sortBy, order)
  Future<List<Book>> getBooks({
    String? search,
    String? genre,
    String? sortBy,
    String? order,
  }) async {
    final queryParameters = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (genre != null && genre.trim().isNotEmpty && genre.toLowerCase() != 'all') {
      queryParameters['genre'] = genre.trim();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sortBy'] = sortBy;
    }
    if (order != null && order.isNotEmpty) {
      queryParameters['order'] = order;
    }

    final queryString = queryParameters.isNotEmpty
        ? '?${Uri(queryParameters: queryParameters).query}'
        : '';

    final response = await _requestWithFallback(
      (url) => http.get(Uri.parse(url), headers: {'Accept': 'application/json'}),
      queryString,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> booksJson = data['data'] ?? [];
      return booksJson.map((json) => Book.fromJson(json)).toList();
    } else {
      final errorData = _parseError(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch books (${response.statusCode})');
    }
  }

  /// GET /api/books/:id
  Future<Book> getBookById(String id) async {
    final response = await _requestWithFallback(
      (url) => http.get(Uri.parse(url), headers: {'Accept': 'application/json'}),
      '/$id',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Book.fromJson(data['data']);
    } else {
      final errorData = _parseError(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load book (${response.statusCode})');
    }
  }

  /// POST /api/books
  Future<Book> createBook(Book book) async {
    final response = await _requestWithFallback(
      (url) => http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(book.toJson()),
      ),
      '',
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Book.fromJson(data['data']);
    } else {
      final errorData = _parseError(response.body);
      if (errorData['errors'] != null && errorData['errors'] is List) {
        throw Exception((errorData['errors'] as List).join('\n'));
      }
      throw Exception(errorData['message'] ?? 'Failed to create book (${response.statusCode})');
    }
  }

  /// PUT /api/books/:id
  Future<Book> updateBook(String id, Book book) async {
    final response = await _requestWithFallback(
      (url) => http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(book.toJson()),
      ),
      '/$id',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Book.fromJson(data['data']);
    } else {
      final errorData = _parseError(response.body);
      if (errorData['errors'] != null && errorData['errors'] is List) {
        throw Exception((errorData['errors'] as List).join('\n'));
      }
      throw Exception(errorData['message'] ?? 'Failed to update book (${response.statusCode})');
    }
  }

  /// DELETE /api/books/:id
  Future<bool> deleteBook(String id) async {
    final response = await _requestWithFallback(
      (url) => http.delete(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ),
      '/$id',
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = _parseError(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete book (${response.statusCode})');
    }
  }

  static Map<String, dynamic> _parseError(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': body};
    }
  }
}
