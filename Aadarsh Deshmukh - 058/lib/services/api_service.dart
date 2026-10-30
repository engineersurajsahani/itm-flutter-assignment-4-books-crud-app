import '../models/book.dart';
import 'book_service.dart';

// ApiService alias delegating to BookService
class ApiService {
  static String get baseUrl => BookService.API_URL;

  Future<List<Book>> getBooks() => BookService.getBooks();
  Future<Book> getBook(String id) => BookService.getBookById(id);
  Future<Map<String, dynamic>> createBook(Book book) => BookService.createBook(book);
  Future<Map<String, dynamic>> updateBook(String id, Book book) => BookService.updateBook(id, book);
  Future<Map<String, dynamic>> deleteBook(String id) => BookService.deleteBook(id);
}
