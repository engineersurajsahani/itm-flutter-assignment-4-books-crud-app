import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  // Compute local URL based on platform/environment
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5005/api/books';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5005/api/books';
    } else {
      return 'http://localhost:5005/api/books';
    }
  }

  // Get all books
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load books (Status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error connecting to backend API: $e');
    }
  }

  // Get book by ID
  Future<Book> fetchBookById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Book.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      throw Exception('Error fetching book details: $e');
    }
  }

  // Add new book
  Future<bool> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Error adding book: $e');
    }
  }

  // Update existing book
  Future<bool> updateBook(String id, Book book) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating book: $e');
    }
  }

  // Delete book
  Future<bool> deleteBook(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }
}
