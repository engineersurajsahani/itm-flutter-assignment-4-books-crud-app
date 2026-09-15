import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5050/api/books';

  // GET all books
  Future<List<Book>> getBooks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Book.fromJson(json))
          .toList();
    }

    throw Exception('Failed to load books');
  }

  // GET one book
  Future<Book> getBookById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load book');
  }

  // CREATE book
  Future<Book> createBook(Book book) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 201) {
      return Book.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      jsonDecode(response.body)['message'] ??
          'Failed to create book',
    );
  }

  // UPDATE book
  Future<Book> updateBook(Book book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${book.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      jsonDecode(response.body)['message'] ??
          'Failed to update book',
    );
  }

  // DELETE book
  Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ??
            'Failed to delete book',
      );
    }
  }
}