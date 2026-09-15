import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookProvider>().loadBooks();
    });
  }

  Future<void> _openForm({Book? book}) async {
    final result = await Navigator.push<Book>(
      context,
      MaterialPageRoute(
        builder: (_) => BookFormScreen(
          book: book,
          onSubmit: (value) => Navigator.of(context).pop(value),
        ),
      ),
    );

    if (result == null) {
      return;
    }

    final provider = context.read<BookProvider>();
    if (book == null) {
      await provider.addBook(result);
      _showSnackBar('Book added successfully');
    } else {
      await provider.updateBook(result);
      _showSnackBar('Book updated successfully');
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await context.read<BookProvider>().deleteBook(book.id);
    _showSnackBar('Book deleted');
  }

  Future<void> _showDetail(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(
          book: book,
          onEdit: () async {
            Navigator.pop(context);
            await _openForm(book: book);
          },
          onDelete: () async {
            Navigator.pop(context);
            await _deleteBook(book);
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final filteredBooks = provider.filteredBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fairy Tale Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showSnackBar('Magic shelf ready'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.library_add),
        label: const Text('Add Tale'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadBooks,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFDF7E8),
                Color(0xFFF2E5C9),
                Color(0xFFEAD9B7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6E6B9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC89A2F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Color(0xFF7C4A1A), size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Enchanted Books',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E3415),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9BC4D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Magic Shelf',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4C2F14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchText,
                  decoration: InputDecoration(
                    hintText: 'Search stories or authors',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7C4A1A)),
                    hintStyle: const TextStyle(color: Color(0xFF92652F)),
                    filled: true,
                    fillColor: const Color(0xFFFFF8EA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFCC9B42)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFCC9B42)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8A5A1A), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF996314),
                          ),
                        )
                      : filteredBooks.isEmpty
                          ? const Center(
                              child: Text(
                                'No enchanted tales found',
                                style: TextStyle(
                                  color: Color(0xFF5E3415),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredBooks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFDF7),
                                        Color(0xFFF7E5BE),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE0B75A), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB97F1F),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3D240E),
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text('by ${book.author}', style: const TextStyle(color: Color(0xFF6A4722))),
                                        Text('${book.genre} • ISBN ${book.isbn}', style: const TextStyle(color: Color(0xFF7C5A2D))),
                                        Text('₹${book.price.toStringAsFixed(2)} • Qty ${book.quantity}', style: const TextStyle(color: Color(0xFF7C5A2D))),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF7C4A1A)),
                                      onPressed: () => _deleteBook(book),
                                    ),
                                    onTap: () => _showDetail(book),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
