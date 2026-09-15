import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedGenre = 'All';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;

  // Extract all unique genres for filter chips
  List<String> get availableGenres {
    final set = <String>{'All'};
    for (var b in _books) {
      if (b.genre.isNotEmpty) {
        set.add(b.genre);
      }
    }
    return set.toList();
  }

  // Filtered books list based on search and genre
  List<Book> get filteredBooks {
    return _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesGenre = _selectedGenre == 'All' ||
          book.genre.toLowerCase() == _selectedGenre.toLowerCase();

      return matchesSearch && matchesGenre;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // Fetch all books from API
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _books = await ApiService.fetchBooks();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new book
  Future<bool> addBook(Book book) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newBook = await ApiService.addBook(book);
      _books.insert(0, newBook);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing book
  Future<bool> updateBook(Book book) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updated = await ApiService.updateBook(book.id, book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete book by ID
  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final success = await ApiService.deleteBook(id);
      if (success) {
        _books.removeWhere((b) => b.id == id);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
