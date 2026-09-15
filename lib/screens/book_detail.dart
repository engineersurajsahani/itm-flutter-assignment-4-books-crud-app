import 'package:flutter/material.dart';

import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                child: Text(
                  book.title.isNotEmpty
                      ? book.title[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'by ${book.author}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            _detailItem(
              Icons.numbers,
              'ISBN',
              book.isbn,
            ),

            _detailItem(
              Icons.category,
              'Genre',
              book.genre.isEmpty ? 'Not specified' : book.genre,
            ),

            _detailItem(
              Icons.currency_rupee,
              'Price',
              '₹${book.price.toStringAsFixed(2)}',
            ),

            _detailItem(
              Icons.inventory_2,
              'Quantity',
              book.quantity.toString(),
            ),

            _detailItem(
              Icons.business,
              'Publisher',
              book.publisher.isEmpty
                  ? 'Not specified'
                  : book.publisher,
            ),

            _detailItem(
              Icons.calendar_month,
              'Published Date',
              '${book.publishedDate.day}/'
                  '${book.publishedDate.month}/'
                  '${book.publishedDate.year}',
            ),

            _detailItem(
              Icons.description,
              'Description',
              book.description.isEmpty
                  ? 'No description'
                  : book.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}