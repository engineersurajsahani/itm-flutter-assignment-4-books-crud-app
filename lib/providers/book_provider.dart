import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Book> get books => _books;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  // Load books
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _books = await _apiService.getBooks();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add book
  Future<bool> addBook(Book book) async {
    try {
      final newBook = await _apiService.createBook(book);

      _books.add(newBook);
      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  // Update book
  Future<bool> updateBook(Book book) async {
    try {
      final updatedBook = await _apiService.updateBook(book);

      final index = _books.indexWhere(
        (item) => item.id == book.id,
      );

      if (index != -1) {
        _books[index] = updatedBook;
      }

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  // Delete book
  Future<bool> deleteBook(String id) async {
    try {
      await _apiService.deleteBook(id);

      _books.removeWhere(
        (book) => book.id == id,
      );

      notifyListeners();

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}