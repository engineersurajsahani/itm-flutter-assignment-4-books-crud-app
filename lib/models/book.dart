class Book {
  String id;
  String title;
  String author;
  String isbn;
  String genre;
  double price;
  int quantity;
  String description;
  String publisher;
  DateTime publishedDate;

  Book({
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

  // Factory constructor to create a Book from JSON map
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      genre: json['genre'] ?? 'General',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      publisher: json['publisher'] ?? '',
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Convert Book object to JSON map
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

  // Create a copy of Book with updated fields
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
