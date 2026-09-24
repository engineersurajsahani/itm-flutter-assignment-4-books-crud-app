import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  // ignore: non_constant_identifier_names
  static String API_URL = 'http://localhost:5000/api/books';
  static String get apiUrl => API_URL;

  static List<String> get _candidateUrls => [
        API_URL,
        'http://localhost:5000/api/books',
        'http://localhost:5001/api/books',
        'http://10.0.2.2:5000/api/books',
        'http://10.0.2.2:5001/api/books',
      ];

  static Future<List<Book>> getBooks() async {
    for (final url in _candidateUrls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          API_URL = url;
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => Book.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        continue;
      }
    }
    throw Exception('Failed to connect to backend server. Please ensure Node.js server is running.');
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
