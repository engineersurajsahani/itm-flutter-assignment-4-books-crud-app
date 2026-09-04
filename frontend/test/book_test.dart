import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/utils/validators.dart';

void main() {
  group('Book Model Tests', () {
    test('Book.fromJson parses properly', () {
      final json = {
        'id': 'test-123',
        'title': 'The Pragmatic Programmer',
        'author': 'Andy Hunt & Dave Thomas',
        'isbn': '9780201616224',
        'genre': 'Technology',
        'price': 42.50,
        'quantity': 15,
        'description': 'Software mastery',
        'publisher': 'Addison-Wesley',
        'publishedDate': '2019-09-13T00:00:00.000Z',
      };

      final book = Book.fromJson(json);

      expect(book.id, 'test-123');
      expect(book.title, 'The Pragmatic Programmer');
      expect(book.author, 'Andy Hunt & Dave Thomas');
      expect(book.isbn, '9780201616224');
      expect(book.genre, 'Technology');
      expect(book.price, 42.50);
      expect(book.quantity, 15);
      expect(book.description, 'Software mastery');
      expect(book.publisher, 'Addison-Wesley');
      expect(book.formattedPrice, '\$42.50');
      expect(book.inStock, true);
    });

    test('Book.toJson serializes properly without id for POST requests', () {
      final book = Book(
        id: '123',
        title: 'Atomic Habits',
        author: 'James Clear',
        isbn: '9780735211292',
        genre: 'Self-Help',
        price: 18.00,
        quantity: 20,
        publishedDate: DateTime(2018, 10, 16),
      );

      final json = book.toJson();

      expect(json['id'], isNull);
      expect(json['title'], 'Atomic Habits');
      expect(json['price'], 18.00);
      expect(json['quantity'], 20);
    });

    test('Book.copyWith creates updated copy without modifying original', () {
      final book = Book(
        id: '1',
        title: 'Original Title',
        author: 'Author A',
        isbn: '1111111111',
        genre: 'Classic',
        price: 10.0,
        quantity: 5,
        publishedDate: DateTime(2020, 1, 1),
      );

      final updated = book.copyWith(title: 'Updated Title', price: 15.0);

      expect(updated.title, 'Updated Title');
      expect(updated.price, 15.0);
      expect(updated.author, 'Author A'); // Unchanged
      expect(book.title, 'Original Title'); // Original untouched
    });
  });

  group('AppValidators Tests', () {
    test('validateTitle validates required non-empty string', () {
      expect(AppValidators.validateTitle(''), isNotNull);
      expect(AppValidators.validateTitle('   '), isNotNull);
      expect(AppValidators.validateTitle(null), isNotNull);
      expect(AppValidators.validateTitle('Valid Title'), isNull);
    });

    test('validatePrice requires non-negative numeric value', () {
      expect(AppValidators.validatePrice(''), isNotNull);
      expect(AppValidators.validatePrice('abc'), isNotNull);
      expect(AppValidators.validatePrice('-10'), isNotNull);
      expect(AppValidators.validatePrice('0'), isNull);
      expect(AppValidators.validatePrice('24.99'), isNull);
    });

    test('validateQuantity requires non-negative integer', () {
      expect(AppValidators.validateQuantity(''), isNotNull);
      expect(AppValidators.validateQuantity('12.5'), isNotNull);
      expect(AppValidators.validateQuantity('-5'), isNotNull);
      expect(AppValidators.validateQuantity('0'), isNull);
      expect(AppValidators.validateQuantity('15'), isNull);
    });
  });
}
