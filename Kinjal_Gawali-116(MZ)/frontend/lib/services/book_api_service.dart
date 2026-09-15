import 'dart:async';

import '../models/book.dart';

class BookApiService {
  static final List<Book> _books = [
    Book(
      id: '1',
      title: 'The Moonlit Forest',
      author: 'Arielle Frost',
      isbn: '9788132450884',
      genre: 'Fantasy',
      price: 299.99,
      quantity: 12,
      description: 'A glittering tale of lanterns, woodland spirits, and a moonlit promise.',
      publisher: 'Silver Pine Press',
      publishedDate: DateTime(2018, 5, 12),
    ),
    Book(
      id: '2',
      title: 'The Crystal Dragon',
      author: 'Nimra Wren',
      isbn: '9789201616224',
      genre: 'Adventure',
      price: 345.5,
      quantity: 8,
      description: 'A brave girl and a dragon of crystal fire uncover the hidden valley of dreams.',
      publisher: 'Rosewood Books',
      publishedDate: DateTime(2012, 10, 20),
    ),
    Book(
      id: '3',
      title: 'The Fairy Queen’s Garden',
      author: 'Eliana Bloom',
      isbn: '9781617298323',
      genre: 'Magic',
      price: 420.0,
      quantity: 5,
      description: 'A magical garden where every flower whispers a lost secret of the kingdom.',
      publisher: 'Aurora House',
      publishedDate: DateTime(2021, 6, 1),
    ),
  ];

  Future<List<Book>> fetchBooks() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<Book>.from(_books);
  }

  Future<Book> getBook(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final book = _books.firstWhere((item) => item.id == id);
    return book;
  }

  Future<Book> addBook(Book book) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _books.insert(0, book);
    return book;
  }

  Future<Book> updateBook(Book book) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _books.indexWhere((item) => item.id == book.id);
    if (index >= 0) {
      _books[index] = book;
    }
    return book;
  }

  Future<void> deleteBook(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _books.removeWhere((item) => item.id == id);
  }
}
