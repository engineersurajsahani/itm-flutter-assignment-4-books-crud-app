import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  ApiService({String? baseUrl})
    : baseUrl = baseUrl ??
          const String.fromEnvironment('API_BASE_URL', defaultValue: '') {
    if (this.baseUrl.isEmpty) {
      this.baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:4000/api/books'
          : 'http://localhost:4000/api/books';
    }
  }

  String baseUrl;

  Future<List<Book>> getBooks() async {
    final response = await http.get(Uri.parse(baseUrl));
    _checkResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Book> createBook(Book book) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(book.toJson()),
    );
    _checkResponse(response);
    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Book> updateBook(Book book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${Uri.encodeComponent(book.id)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(book.toJson()),
    );
    _checkResponse(response);
    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/${Uri.encodeComponent(id)}'),
    );
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Books API request failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
