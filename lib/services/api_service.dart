import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Default API base URL based on running platform
  String _baseUrl = _getDefaultBaseUrl();
  bool _discoveredWorkingPort = false;

  static String _getDefaultBaseUrl({int port = 5000}) {
    if (kIsWeb) {
      return 'http://localhost:$port/api/books';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:$port/api/books';
        }
      } catch (_) {}
      return 'http://localhost:$port/api/books';
    }
  }

  String get baseUrl => _baseUrl;

  void setBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _discoveredWorkingPort = true;
  }

  /// Automatically discovers whether port 5000 or fallback 5050 is active
  Future<void> _ensureWorkingPort() async {
    if (_discoveredWorkingPort) return;

    final ports = [5000, 5050, 5001];
    for (final port in ports) {
      try {
        final candidateUrl = _getDefaultBaseUrl(port: port);
        final healthUri = Uri.parse(candidateUrl.replaceAll('/api/books', '/api/health'));
        final res = await http.get(healthUri).timeout(const Duration(milliseconds: 1200));
        if (res.statusCode == 200) {
          _baseUrl = candidateUrl;
          _discoveredWorkingPort = true;
          debugPrint('Connected to API at: $_baseUrl');
          return;
        }
      } catch (_) {
        // try next candidate
      }
    }
    // Default fallback
    _discoveredWorkingPort = true;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Helper to handle response body and extract error messages
  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          return (data['errors'] as List).join('\n');
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {}
    return 'Server error (${response.statusCode}): ${response.reasonPhrase}';
  }

  /// GET /api/books (with optional search and genre query)
  Future<List<Book>> getBooks({String? search, String? genre}) async {
    await _ensureWorkingPort();
    final queryParams = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (genre != null && genre.trim().isNotEmpty && genre != 'All') {
      queryParams['genre'] = genre.trim();
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> booksJson = body['data'] ?? [];
        return booksJson.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to load books: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// GET /api/books/:id
  Future<Book> getBookById(String id) async {
    await _ensureWorkingPort();
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Book.fromJson(body['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch book: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// POST /api/books
  Future<Book> createBook(Book book) async {
    await _ensureWorkingPort();
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Book.fromJson(body['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// PUT /api/books/:id
  Future<Book> updateBook(String id, Book book) async {
    await _ensureWorkingPort();
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Book.fromJson(body['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// DELETE /api/books/:id
  Future<bool> deleteBook(String id) async {
    await _ensureWorkingPort();
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.delete(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
