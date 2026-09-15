import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.defaultBaseUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /api/books - Fetch all books
  Future<List<Book>> getBooks() async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);

      final responseData = _handleResponse(response);
      final List<dynamic> booksJson = responseData['data'] ?? [];

      return booksJson
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw ApiException(
          'Cannot connect to server. Make sure the Node.js backend is running at $baseUrl');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load books: ${e.toString()}');
    }
  }

  /// GET /api/books/:id - Fetch single book by ID
  Future<Book> getBook(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);

      final responseData = _handleResponse(response);
      final dynamic bookJson = responseData['data'];

      if (bookJson == null) {
        throw ApiException('Book not found', 404);
      }

      return Book.fromJson(bookJson as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load book: ${e.toString()}');
    }
  }

  /// POST /api/books - Create a new book
  Future<Book> createBook(Book book) async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = _handleResponse(response);
      final dynamic createdJson = responseData['data'];

      return Book.fromJson(createdJson as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create book: ${e.toString()}');
    }
  }

  /// PUT /api/books/:id - Update an existing book
  Future<Book> updateBook(Book book) async {
    try {
      final uri = Uri.parse('$baseUrl/${book.id}');
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(AppConstants.connectTimeout);

      final responseData = _handleResponse(response);
      final dynamic updatedJson = responseData['data'];

      return Book.fromJson(updatedJson as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update book: ${e.toString()}');
    }
  }

  /// DELETE /api/books/:id - Delete a book
  Future<void> deleteBook(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);

      _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server. Please check your network.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete book: ${e.toString()}');
    }
  }

  /// Centralized response handler that parses JSON and checks HTTP status codes
  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};

    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Body was not JSON
    }

    final message = body['message']?.toString() ?? 'Request failed (${response.statusCode})';

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ApiException(message, 400);
      case 404:
        throw ApiException(message.isNotEmpty ? message : 'Book not found', 404);
      case 409:
        throw ApiException(message.isNotEmpty ? message : 'ISBN already exists', 409);
      case 500:
      default:
        throw ApiException(
          message.isNotEmpty ? message : 'Server error occurred (${response.statusCode})',
          response.statusCode,
        );
    }
  }

  void dispose() {
    _client.close();
  }
}
