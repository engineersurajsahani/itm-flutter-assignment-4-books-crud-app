import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  Book? _selectedBook;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedGenre = 'All';

  BookProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<Book> get books => _books;
  List<Book> get filteredBooks => _filteredBooks;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  ApiService get apiService => _apiService;

  /// Dynamic list of all genres currently present in the book collection, plus 'All'
  List<String> get availableGenres {
    final genreSet = <String>{'All'};
    for (final book in _books) {
      if (book.genre.trim().isNotEmpty) {
        genreSet.add(book.genre.trim());
      }
    }
    return genreSet.toList();
  }

  /// Fetch all books from the REST API
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _apiService.getBooks();
      _applyFilterAndSearch();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single book by ID
  Future<Book?> fetchBookById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final book = await _apiService.getBook(id);
      _selectedBook = book;
      return book;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new book
  Future<bool> addBook(Book book) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdBook = await _apiService.createBook(book);
      _books.add(createdBook);
      // Keep books sorted by title
      _books.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      _applyFilterAndSearch();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing book
  Future<bool> updateBook(Book book) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBook = await _apiService.updateBook(book);
      final index = _books.indexWhere((b) => b.id == updatedBook.id);
      if (index != -1) {
        _books[index] = updatedBook;
        _books.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
      if (_selectedBook?.id == updatedBook.id) {
        _selectedBook = updatedBook;
      }
      _applyFilterAndSearch();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Delete a book by ID
  Future<bool> deleteBook(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteBook(id);
      _books.removeWhere((book) => book.id == id);
      if (_selectedBook?.id == id) {
        _selectedBook = null;
      }
      _applyFilterAndSearch();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Search query updater
  void searchBooks(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  /// Filter genre updater
  void filterByGenre(String genre) {
    _selectedGenre = genre;
    _applyFilterAndSearch();
    notifyListeners();
  }

  /// Clear any active error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Pull-to-refresh
  Future<void> refreshBooks() async {
    await fetchBooks();
  }

  /// Client-side filtering logic based on active query and selected genre
  void _applyFilterAndSearch() {
    final query = _searchQuery.trim().toLowerCase();

    _filteredBooks = _books.where((book) {
      // 1. Genre filter check
      final matchesGenre = (_selectedGenre == 'All') ||
          (book.genre.toLowerCase() == _selectedGenre.toLowerCase());

      if (!matchesGenre) return false;

      // 2. Search query check
      if (query.isEmpty) return true;

      final titleMatch = book.title.toLowerCase().contains(query);
      final authorMatch = book.author.toLowerCase().contains(query);
      final isbnMatch = book.isbn.toLowerCase().contains(query);
      final genreMatch = book.genre.toLowerCase().contains(query);

      return titleMatch || authorMatch || isbnMatch || genreMatch;
    }).toList();
  }
}
