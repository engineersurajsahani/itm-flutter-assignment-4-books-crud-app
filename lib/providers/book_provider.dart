import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedGenre = 'All';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  final List<String> _availableGenres = [
    'All',
    'Software Engineering',
    'Programming',
    'Mobile Development',
    'Fiction',
    'Non-Fiction',
    'Science',
    'Fantasy',
    'Biography',
    'Other'
  ];

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  List<String> get availableGenres => _availableGenres;

  /// Fetches books from backend with current filters and search
  Future<void> fetchBooks({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetchedBooks = await _apiService.getBooks(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        genre: _selectedGenre != 'All' ? _selectedGenre : null,
        sortBy: _sortBy,
        order: _sortOrder,
      );
      _books = fetchedBooks;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new book
  Future<bool> addBook(Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBook = await _apiService.createBook(book);
      _books.insert(0, newBook);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing book
  Future<bool> updateBook(Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateBook(book.id, book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a book
  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchBooks();
  }

  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    fetchBooks();
  }

  void setSorting(String field, String order) {
    _sortBy = field;
    _sortOrder = order;
    fetchBooks();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
