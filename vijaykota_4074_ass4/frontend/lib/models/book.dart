class Book {
  final String? id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final double price;
  final int quantity;
  final String description;
  final String publisher;
  final String publishedDate;

  Book({
    this.id,
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
      id: json['id'] as String?,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      genre: json['genre'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      quantity: (json['quantity'] != null) ? (json['quantity'] as num).toInt() : 0,
      description: json['description'] ?? '',
      publisher: json['publisher'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'price': price,
      'quantity': quantity,
      'description': description,
      'publisher': publisher,
      'publishedDate': publishedDate,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
