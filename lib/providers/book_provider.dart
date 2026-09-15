import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/book_api_service.dart';

class BookProvider extends ChangeNotifier {
  final BookApiService _service = BookApiService();
  List<Book> _books = [];
  bool _isLoading = true;
  String _searchText = '';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get searchText => _searchText;

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    _books = await _service.fetchBooks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    await _service.addBook(book);
    await loadBooks();
  }

  Future<void> updateBook(Book book) async {
    await _service.updateBook(book);
    await loadBooks();
  }

  Future<void> deleteBook(String id) async {
    await _service.deleteBook(id);
    await loadBooks();
  }

  List<Book> get filteredBooks {
    if (_searchText.trim().isEmpty) {
      return _books;
    }

    final query = _searchText.trim().toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }
}
