import 'package:flutter_test/flutter_test.dart';
import 'package:book_crud_app/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Book should correctly deserialize from JSON', () {
      final json = {
        'id': 'book_123',
        'title': 'Flutter in Action',
        'author': 'Eric Windmill',
        'isbn': '978-1617296147',
        'genre': 'Mobile Development',
        'price': 39.99,
        'quantity': 12,
        'description': 'Teach yourself Flutter and Dart from scratch.',
        'publisher': 'Manning Publications',
        'publishedDate': '2020-01-07T00:00:00.000Z',
      };

      final book = Book.fromJson(json);

      expect(book.id, 'book_123');
      expect(book.title, 'Flutter in Action');
      expect(book.author, 'Eric Windmill');
      expect(book.isbn, '978-1617296147');
      expect(book.genre, 'Mobile Development');
      expect(book.price, 39.99);
      expect(book.quantity, 12);
      expect(book.publisher, 'Manning Publications');
      expect(book.publishedDate, isNotNull);
      expect(book.publishedDate!.year, 2020);
    });

    test('Book should correctly serialize to JSON', () {
      final book = Book(
        id: 'book_456',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        isbn: '978-0132350884',
        genre: 'Software Engineering',
        price: 37.99,
        quantity: 15,
        description: 'A Handbook of Agile Software Craftsmanship',
        publisher: 'Prentice Hall',
        publishedDate: DateTime.utc(2008, 8, 1),
      );

      final json = book.toJson();

      expect(json['id'], 'book_456');
      expect(json['title'], 'Clean Code');
      expect(json['author'], 'Robert C. Martin');
      expect(json['isbn'], '978-0132350884');
      expect(json['price'], 37.99);
      expect(json['quantity'], 15);
      expect(json['publishedDate'], contains('2008-08-01'));
    });

    test('Book copyWith should update specified fields only', () {
      final book = Book(
        id: '1',
        title: 'Original Title',
        author: 'Original Author',
        price: 10.0,
      );

      final updated = book.copyWith(
        title: 'Updated Title',
        price: 15.5,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Updated Title');
      expect(updated.author, 'Original Author');
      expect(updated.price, 15.5);
    });
  });
}
