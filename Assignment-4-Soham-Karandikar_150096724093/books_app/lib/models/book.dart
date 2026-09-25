class Book {
  Book({
    this.id = '',
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.price,
    required this.quantity,
    required this.description,
    this.publisher = '',
    DateTime? publishedDate,
  }) : publishedDate = publishedDate ?? DateTime.now();

  final String id;
  String title;
  String author;
  String isbn;
  String genre;
  double price;
  int quantity;
  String description;
  String publisher;
  DateTime publishedDate;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    author: json['author'] ?? '',
    isbn: json['isbn'] ?? '',
    genre: json['genre'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    description: json['description'] ?? '',
    publisher: json['publisher'] ?? '',
    publishedDate: DateTime.tryParse(json['publishedDate'] ?? ''),
  );

  Map<String, dynamic> toJson() => {
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
