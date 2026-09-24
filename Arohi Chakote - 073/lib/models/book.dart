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
  DateTime? publishedDate;

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
    this.publishedDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      genre: json['genre'] ?? '',
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      quantity: (json['quantity'] != null) ? int.parse(json['quantity'].toString()) : 0,
      description: json['description'] ?? '',
      publisher: json['publisher'] ?? '',
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'price': price,
      'quantity': quantity,
      'description': description,
      'publisher': publisher,
      if (publishedDate != null) 'publishedDate': publishedDate!.toIso8601String(),
    };
  }
}
