import 'package:flutter/material.dart';

import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Book details'),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context, 'edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          onPressed: () => _delete(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xffd7e9df),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 90,
            color: Color(0xff1c6e63),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'by ${book.author}',
          style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          children: [
            Chip(label: Text(book.genre)),
            Chip(label: Text('${book.quantity} in stock')),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'About this book',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          book.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        Text('ISBN: ${book.isbn}'),
        const SizedBox(height: 10),
        Text('Price: \$${book.price.toStringAsFixed(2)}'),
      ],
    ),
  );

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text('Remove "${book.title}" from your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) Navigator.pop(context, 'delete');
  }
}
