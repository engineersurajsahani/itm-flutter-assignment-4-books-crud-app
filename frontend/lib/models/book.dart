import 'package:intl/intl.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final double price;
  final int quantity;
  final String? description;
  final String? publisher;
  final DateTime publishedDate;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.price,
    required this.quantity,
    this.description,
    this.publisher,
    required this.publishedDate,
  });

  /// Factory constructor to create a Book instance from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['publishedDate'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : (int.tryParse(json['quantity']?.toString() ?? '0') ?? 0),
      description: json['description']?.toString(),
      publisher: json['publisher']?.toString(),
      publishedDate: parsedDate,
    );
  }

  /// Serialize Book instance to JSON (for POST / PUT requests)
  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'title': title.trim(),
      'author': author.trim(),
      'isbn': isbn.trim(),
      'genre': genre.trim(),
      'price': price,
      'quantity': quantity,
      'description': description?.trim() ?? '',
      'publisher': publisher?.trim() ?? '',
      'publishedDate': publishedDate.toIso8601String(),
    };

    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  /// Create a modified copy of this Book
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? genre,
    double? price,
    int? quantity,
    String? description,
    String? publisher,
    DateTime? publishedDate,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genre: genre ?? this.genre,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }

  /// Formatted price with dollar sign and 2 decimals
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Readable formatted published date (e.g., "Jan 10, 2026")
  String get formattedPublishedDate => DateFormat('MMM d, y').format(publishedDate);

  /// Check if book is currently in stock
  bool get inStock => quantity > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isbn == other.isbn;

  @override
  int get hashCode => id.hashCode ^ isbn.hashCode;
}
