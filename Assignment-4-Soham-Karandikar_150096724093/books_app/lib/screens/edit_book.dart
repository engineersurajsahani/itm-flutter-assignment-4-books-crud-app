import 'package:flutter/material.dart';

import '../models/book.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({
    super.key,
    required this.title,
    this.book,
    required this.onSave,
  });
  final String title;
  final Book? book;
  final ValueChanged<Book> onSave;
  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.book?.title);
  late final author = TextEditingController(text: widget.book?.author);
  late final isbn = TextEditingController(text: widget.book?.isbn);
  late final genre = TextEditingController(text: widget.book?.genre);
  late final price = TextEditingController(text: widget.book?.price.toString());
  late final quantity = TextEditingController(
    text: widget.book?.quantity.toString(),
  );
  late final description = TextEditingController(
    text: widget.book?.description,
  );

  @override
  void dispose() {
    for (final item in [
      title,
      author,
      isbn,
      genre,
      price,
      quantity,
      description,
    ]) {
      item.dispose();
    }
    super.dispose();
  }

  String? requiredField(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  void save() {
    if (!formKey.currentState!.validate()) return;
    widget.onSave(
      Book(
        id: widget.book?.id ?? DateTime.now().toIso8601String(),
        title: title.text.trim(),
        author: author.text.trim(),
        isbn: isbn.text.trim(),
        genre: genre.text.trim(),
        price: double.tryParse(price.text) ?? 0,
        quantity: int.tryParse(quantity.text) ?? 0,
        description: description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          field(title, 'Title'),
          field(author, 'Author'),
          field(isbn, 'ISBN'),
          field(genre, 'Genre'),
          Row(
            children: [
              Expanded(child: field(price, 'Price', number: true)),
              const SizedBox(width: 12),
              Expanded(child: field(quantity, 'Quantity', number: true)),
            ],
          ),
          field(description, 'Description', lines: 4),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.check),
            label: const Text('Save book'),
          ),
        ],
      ),
    ),
  );

  Widget field(
    TextEditingController controller,
    String label, {
    bool number = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      validator: requiredField,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    ),
  );
}
