import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  // Base URL handling for Desktop, iOS Simulator, Web, and Android Emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api/books';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api/books';
    } else {
      return 'http://localhost:5001/api/books';
    }
  }

  // GET /api/books - Get all books
  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Book.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load books');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET /api/books/:id - Get a specific book
  static Future<Book> fetchBookById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Book not found');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST /api/books - Add a new book
  static Future<Book> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to add book');
        }
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create book: $e');
    }
  }

  // PUT /api/books/:id - Update a book
  static Future<Book> updateBook(String id, Book book) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to update book');
        }
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // DELETE /api/books/:id - Delete a book
  static Future<bool> deleteBook(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete book');
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }
}
