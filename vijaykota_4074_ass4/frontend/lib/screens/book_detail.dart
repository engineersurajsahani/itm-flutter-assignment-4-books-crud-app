import 'package:flutter/material.dart';
import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${book.author}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(
                      book.genre.isEmpty ? 'General' : book.genre,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Price & Quantity Grid
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    context,
                    title: 'Price',
                    value: '\$${book.price.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _infoCard(
                    context,
                    title: 'In Stock',
                    value: '${book.quantity} pcs',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Section
            Text(
              'Description',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                book.description.isEmpty
                    ? 'No description provided for this book.'
                    : book.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Metadata list
            Text(
              'Book Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailTile(Icons.qr_code, 'ISBN', book.isbn.isEmpty ? 'N/A' : book.isbn),
                  const Divider(height: 1),
                  _detailTile(Icons.business, 'Publisher', book.publisher.isEmpty ? 'N/A' : book.publisher),
                  const Divider(height: 1),
                  _detailTile(Icons.calendar_today, 'Published Date', book.publishedDate.isEmpty ? 'N/A' : book.publishedDate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
