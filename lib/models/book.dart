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
  final DateTime publishedDate;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.price,
    required this.quantity,
    required this.description,
    required this.publisher,
    required this.publishedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      genre: json['genre'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      description: json['description'] as String,
      publisher: json['publisher'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'price': price,
      'quantity': quantity,
      'description': description,
      'publisher': publisher,
      'publishedDate': publishedDate.toIso8601String(),
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
}
