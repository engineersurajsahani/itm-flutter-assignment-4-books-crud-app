import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow(label: 'Author', value: book.author),
                _detailRow(label: 'ISBN', value: book.isbn),
                _detailRow(label: 'Genre', value: book.genre),
                _detailRow(label: 'Price', value: '₹${book.price.toStringAsFixed(2)}'),
                _detailRow(label: 'Quantity', value: book.quantity.toString()),
                _detailRow(label: 'Publisher', value: book.publisher),
                _detailRow(
                  label: 'Published',
                  value: dateFormat.format(book.publishedDate),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(book.description),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
