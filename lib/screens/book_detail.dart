import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'edit_book.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final provider = Provider.of<BookProvider>(context, listen: false);
              final success = await provider.deleteBook(book.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Book deleted successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.pop(context); // Go back to list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Delete failed: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final bookIndex = provider.books.indexWhere((b) => b.id == widget.bookId);
        if (bookIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Details')),
            body: const Center(
              child: Text('Book not found or has been deleted.'),
            ),
          );
        }

        final book = provider.books[bookIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBookScreen(book: book),
                    ),
                  );
                },
                tooltip: 'Edit Book',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, book),
                tooltip: 'Delete Book',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Header Banner Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade400, Colors.indigo.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              book.title.isNotEmpty ? book.title[0].toUpperCase() : 'B',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'By ${book.author}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${book.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Details Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.category_rounded,
                          label: 'Genre',
                          value: book.genre,
                        ),
                        _DetailRow(
                          icon: Icons.qr_code_rounded,
                          label: 'ISBN',
                          value: book.isbn.isNotEmpty ? book.isbn : 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.inventory_2_rounded,
                          label: 'Available Quantity',
                          value: '${book.quantity} copies (${book.quantity > 0 ? "In Stock" : "Out of Stock"})',
                          valueColor: book.quantity > 0 ? Colors.green[700] : Colors.red[700],
                        ),
                        _DetailRow(
                          icon: Icons.business_rounded,
                          label: 'Publisher',
                          value: book.publisher.isNotEmpty ? book.publisher : 'N/A',
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Published Date',
                          value: DateFormat('MMMM dd, yyyy').format(book.publishedDate),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Text(
                          book.description.isNotEmpty
                              ? book.description
                              : 'No description provided.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit & Delete Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.indigo),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBookScreen(book: book),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, color: Colors.indigo),
                        label: const Text(
                          'Edit Book',
                          style: TextStyle(color: Colors.indigo, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _confirmDelete(context, book),
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                        label: const Text(
                          'Delete Book',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo.shade300),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
