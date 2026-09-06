import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Book> get books => _filteredBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _apiService.fetchBooks();
      _applySearch();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredBooks = List.from(_books);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredBooks = _books.where((book) {
        return book.title.toLowerCase().contains(q) ||
            book.author.toLowerCase().contains(q) ||
            book.genre.toLowerCase().contains(q) ||
            book.isbn.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> addBook(Book book) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _apiService.addBook(book);
      if (success) {
        await fetchBooks();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(String id, Book book) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _apiService.updateBook(id, book);
      if (success) {
        await fetchBooks();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String id) async {
    try {
      final success = await _apiService.deleteBook(id);
      if (success) {
        _books.removeWhere((b) => b.id == id);
        _applySearch();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
