import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {eqd
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedGenre = 'All';

  // Standard predefined genres for easy filtering
  static const List<String> defaultGenres = [
    'All',
    'Technology',
    'Software Engineering',
    'Computer Science',
    'Fiction',
    'Non-Fiction',
    'Science',
    'Business',
    'Biography',
    'Self-Help'
  ];

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;

  List<String> get genres {
    final dynamicGenres = _books
        .map((b) => b.genre.trim())
        .where((g) => g.isNotEmpty)
        .toSet();
    final combined = {'All', ...defaultGenres, ...dynamicGenres}.toList();
    return combined;
  }

  List<Book> get filteredBooks {
    return _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.genre.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesGenre = _selectedGenre == 'All' ||
          book.genre.toLowerCase() == _selectedGenre.toLowerCase();

      return matchesSearch && matchesGenre;
    }).toList();
  }

  int get totalStock => _books.fold(0, (sum, book) => sum + book.quantity);

  /// Fetch all books from API
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _apiService.getBooks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Set search query filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set selected genre filter
  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  /// Add a new book
  Future<bool> addBook(Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdBook = await _apiService.createBook(book);
      _books.insert(0, createdBook);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing book
  Future<bool> updateBook(String id, Book book) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBook = await _apiService.updateBook(id, book);
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books[index] = updatedBook;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Clear active error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
