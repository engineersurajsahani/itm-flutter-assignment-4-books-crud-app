import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Book {
  Book({
    this.id,
    required this.title,
    required this.author,
    this.isbn = '',
    this.genre = '',
    this.price = 0,
    this.quantity = 0,
    this.description = '',
    this.publisher = '',
    this.publishedDate = '',
  });

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

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id']?.toString(),
    title: json['title']?.toString() ?? '',
    author: json['author']?.toString() ?? '',
    isbn: json['isbn']?.toString() ?? '',
    genre: json['genre']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    description: json['description']?.toString() ?? '',
    publisher: json['publisher']?.toString() ?? '',
    publishedDate: json['publishedDate']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
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
}

class BooksApi {
  BooksApi({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:5001/api/books',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<Book>> all() async {
    final data = await _send('GET', baseUrl);
    return (data as List).map((item) => Book.fromJson(item)).toList();
  }

  Future<void> create(Book book) => _send('POST', baseUrl, body: book.toJson());

  Future<void> update(Book book) =>
      _send('PUT', '$baseUrl/${book.id}', body: book.toJson());

  Future<void> delete(String id) => _send('DELETE', '$baseUrl/$id');

  Future<dynamic> _send(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = switch (method) {
      'GET' => await _client.get(uri),
      'POST' => await _client.post(uri, headers: headers, body: encodedBody),
      'PUT' => await _client.put(uri, headers: headers, body: encodedBody),
      'DELETE' => await _client.delete(uri),
      _ => throw ArgumentError('Unsupported method: $method'),
    };
    final data = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data is Map ? data['message'] ?? data['errors'] : response.body,
      );
    }

    return data;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Books',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: BooksPage(api: BooksApi()),
    );
  }
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key, required this.api});

  final BooksApi api;

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  var _books = <Book>[];
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _books = await widget.api.all();
    } catch (error) {
      _error = error.toString();
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(Book book) async {
    try {
      await widget.api.delete(book.id!);
      await _load();
      _message('Book deleted');
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _save(Book book) async {
    try {
      if (book.id == null) {
        await widget.api.create(book);
      } else {
        await widget.api.update(book);
      }

      await _load();
      _message('Book saved');
    } catch (error) {
      _message(error.toString());
    }
  }

  void _message(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openForm([Book? book]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => BookForm(
        book: book,
        onSave: (savedBook) async {
          Navigator.pop(context);
          await _save(savedBook);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(child: Text('No books found'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _books.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final book = _books[index];

          return ListTile(
            title: Text(book.title),
            subtitle: Text(
              '${book.author} - ${book.genre.isEmpty ? 'No genre' : book.genre}',
            ),
            trailing: Wrap(
              children: [
                IconButton(
                  onPressed: () => _openForm(book),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: book.id == null ? null : () => _delete(book),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BookForm extends StatefulWidget {
  const BookForm({super.key, this.book, required this.onSave});

  final Book? book;
  final Future<void> Function(Book book) onSave;

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.book?.title ?? '');
  late final _author = TextEditingController(text: widget.book?.author ?? '');
  late final _isbn = TextEditingController(text: widget.book?.isbn ?? '');
  late final _genre = TextEditingController(text: widget.book?.genre ?? '');
  late final _price = TextEditingController(
    text: widget.book?.price.toString() ?? '',
  );
  late final _quantity = TextEditingController(
    text: widget.book?.quantity.toString() ?? '',
  );
  late final _description = TextEditingController(
    text: widget.book?.description ?? '',
  );
  late final _publisher = TextEditingController(
    text: widget.book?.publisher ?? '',
  );
  late final _publishedDate = TextEditingController(
    text: widget.book?.publishedDate ?? '',
  );

  @override
  void dispose() {
    for (final controller in [
      _title,
      _author,
      _isbn,
      _genre,
      _price,
      _quantity,
      _description,
      _publisher,
      _publishedDate,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSave(
      Book(
        id: widget.book?.id,
        title: _title.text.trim(),
        author: _author.text.trim(),
        isbn: _isbn.text.trim(),
        genre: _genre.text.trim(),
        price: double.tryParse(_price.text) ?? 0,
        quantity: int.tryParse(_quantity.text) ?? 0,
        description: _description.text.trim(),
        publisher: _publisher.text.trim(),
        publishedDate: _publishedDate.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.book == null ? 'Add Book' : 'Edit Book',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _field(_title, 'Title', required: true),
            _field(_author, 'Author', required: true),
            _field(_isbn, 'ISBN'),
            _field(_genre, 'Genre'),
            _field(_price, 'Price', number: true),
            _field(_quantity, 'Quantity', integer: true),
            _field(_publisher, 'Publisher'),
            _field(_publishedDate, 'Published Date'),
            _field(_description, 'Description', maxLines: 3),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    bool integer = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        keyboardType: number || integer
            ? TextInputType.number
            : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          final text = value?.trim() ?? '';

          if (required && text.isEmpty) {
            return '$label is required';
          }

          if (number && text.isNotEmpty) {
            final parsed = double.tryParse(text);
            if (parsed == null || parsed < 0) {
              return '$label must be non-negative';
            }
          }

          if (integer && text.isNotEmpty) {
            final parsed = int.tryParse(text);
            if (parsed == null || parsed < 0) {
              return '$label must be a non-negative integer';
            }
          }

          return null;
        },
      ),
    );
  }
}
