import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'edit_book.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _currentBook;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await BookService.deleteBook(_currentBook.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
        Navigator.pop(context, true); // Go back to list with refresh signal
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentBook.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<Book>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBookScreen(book: _currentBook),
                ),
              );
              if (updated != null) {
                setState(() {
                  _currentBook = updated;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _confirmDelete,
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      _currentBook.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'by ${_currentBook.author}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.attach_money,
                            'Price',
                            '\$${_currentBook.price.toStringAsFixed(2)}',
                            valueColor: Colors.green.shade700,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            Icons.inventory_2,
                            'Quantity',
                            '${_currentBook.quantity} in stock',
                          ),
                          if (_currentBook.genre.isNotEmpty) ...[
                            const Divider(),
                            _buildDetailRow(
                              Icons.category,
                              'Genre',
                              _currentBook.genre,
                            ),
                          ],
                          if (_currentBook.isbn.isNotEmpty) ...[
                            const Divider(),
                            _buildDetailRow(
                              Icons.pin,
                              'ISBN',
                              _currentBook.isbn,
                            ),
                          ],
                          if (_currentBook.publisher.isNotEmpty) ...[
                            const Divider(),
                            _buildDetailRow(
                              Icons.business,
                              'Publisher',
                              _currentBook.publisher,
                            ),
                          ],
                          if (_currentBook.publishedDate != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              Icons.calendar_today,
                              'Published Date',
                              DateFormat('MMMM dd, yyyy').format(_currentBook.publishedDate!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_currentBook.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _currentBook.description,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
