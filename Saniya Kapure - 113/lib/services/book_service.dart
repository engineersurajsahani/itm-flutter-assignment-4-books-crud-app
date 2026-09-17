import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  // Use 'http://10.0.2.2:5000/api/books' for Android emulator,
  // or 'http://localhost:5000/api/books' for iOS/Web/Desktop.
  // ignore: non_constant_identifier_names
  static String API_URL = 'http://10.0.2.2:5000/api/books';
  static String get apiUrl => API_URL;

  static Future<List<Book>> getBooks() async {
    final response = await http.get(Uri.parse(API_URL));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load books (Status code: ${response.statusCode})');
    }
  }

  static Future<Book> getBookById(String id) async {
    final response = await http.get(Uri.parse('$API_URL/$id'));
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load book with ID $id');
    }
  }

  static Future<Map<String, dynamic>> createBook(Book book) async {
    final response = await http.post(
      Uri.parse(API_URL),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(book.toJson()),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateBook(String id, Book book) async {
    final response = await http.put(
      Uri.parse('$API_URL/$id'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(book.toJson()),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$API_URL/$id'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
