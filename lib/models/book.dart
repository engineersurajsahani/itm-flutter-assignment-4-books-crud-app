class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final double price;
  final int quantity;
  final String description;
  final String publisher;
  final DateTime? publishedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    this.id = '',
    required this.title,
    required this.author,
    required this.isbn,
    this.genre = '',
    this.price = 0.0,
    this.quantity = 0,
    this.description = '',
    this.publisher = '',
    this.publishedDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a Book instance from API JSON response
  factory Book.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      publishedDate: parseDate(json['publishedDate']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  /// Converts Book to JSON payload for API POST/PUT requests
  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'author': author.trim(),
      'isbn': isbn.trim(),
      'genre': genre.trim(),
      'price': price,
      'quantity': quantity,
      'description': description.trim(),
      'publisher': publisher.trim(),
      if (publishedDate != null)
        'publishedDate': publishedDate!.toIso8601String(),
    };
  }

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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
