import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'edit_book.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Text('Delete Book', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_currentBook.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              Navigator.of(ctx).pop();
              final provider = Provider.of<BookProvider>(context, listen: false);
              final success = await provider.deleteBook(_currentBook.id);

              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('"${_currentBook.title}" deleted.'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  navigator.pop();
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete book'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
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
    final hasStock = _currentBook.quantity > 0;
    final isLowStock = _currentBook.quantity > 0 && _currentBook.quantity <= 5;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Book Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit',
            onPressed: () async {
              final updated = await Navigator.of(context).push<Book>(
                MaterialPageRoute(
                  builder: (_) => EditBookScreen(book: _currentBook),
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
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete',
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Book Header
            Container(
              width: double.infinity,
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Book Cover Badge
                      Container(
                        width: 70,
                        height: 95,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _currentBook.title.isNotEmpty ? _currentBook.title[0].toUpperCase() : 'B',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Author
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentBook.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'by ${_currentBook.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Price Tag & Genre Pill
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF10B981)),
                                  ),
                                  child: Text(
                                    '\$${_currentBook.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (_currentBook.genre.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _currentBook.genre,
                                      style: const TextStyle(
                                        color: Color(0xFFA5B4FC),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !hasStock
                          ? const Color(0xFFFEF2F2)
                          : isLowStock
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !hasStock
                            ? const Color(0xFFFECACA)
                            : isLowStock
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !hasStock
                              ? Icons.cancel_outlined
                              : isLowStock
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                          color: !hasStock
                              ? const Color(0xFFDC2626)
                              : isLowStock
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              !hasStock
                                  ? 'Out of Stock'
                                  : isLowStock
                                      ? 'Low Stock Warning'
                                      : 'In Stock & Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !hasStock
                                    ? const Color(0xFFDC2626)
                                    : isLowStock
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF16A34A),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_currentBook.quantity} units currently available in inventory',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Metadata Grid Card
                  _buildSectionHeader('Book Information'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow(
                          icon: Icons.qr_code,
                          label: 'ISBN',
                          value: _currentBook.isbn.isNotEmpty ? _currentBook.isbn : 'Not specified',
                        ),
                        const Divider(height: 1, indent: 50),
                        _buildMetaRow(
                          icon: Icons.business_outlined,
                          label: 'Publisher',
                          value: _currentBook.publisher.isNotEmpty ? _currentBook.publisher : 'Not specified',
                        ),
                        const Divider(height: 1, indent: 50),
                        _buildMetaRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Published Date',
                          value: _currentBook.publishedDate != null
                              ? DateFormat('MMMM dd, yyyy').format(_currentBook.publishedDate!)
                              : 'Not specified',
                        ),
                        const Divider(height: 1, indent: 50),
                        _buildMetaRow(
                          icon: Icons.tag,
                          label: 'Document ID',
                          value: _currentBook.id,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description Card
                  _buildSectionHeader('Description'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      _currentBook.description.isNotEmpty
                          ? _currentBook.description
                          : 'No description provided for this book.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: _currentBook.description.isNotEmpty
                            ? const Color(0xFF334155)
                            : const Color(0xFF94A3B8),
                        fontStyle: _currentBook.description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xFF6366F1)),
                            foregroundColor: const Color(0xFF6366F1),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Book', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            final updated = await Navigator.of(context).push<Book>(
                              MaterialPageRoute(
                                builder: (_) => EditBookScreen(book: _currentBook),
                              ),
                            );
                            if (updated != null) {
                              setState(() {
                                _currentBook = updated;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Book', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _showDeleteDialog,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
