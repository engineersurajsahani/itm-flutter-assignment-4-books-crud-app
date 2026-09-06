import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'book_detail.dart';
import 'book_form.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext dialogContext, Book book) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<BookProvider>(context, listen: false);
              final success = await provider.deleteBook(book.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Book deleted successfully!'
                        : 'Failed to delete book'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Books Library'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Header Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                Provider.of<BookProvider>(context, listen: false).setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by title, author, genre or ISBN...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<BookProvider>(context, listen: false).setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.books.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.books.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load books',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchBooks(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (provider.books.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchBooks(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book, size: 70, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No books available.',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add a book!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchBooks(),
                  child: ListView.builder(
                    itemCount: provider.books.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final book = provider.books[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.book, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Author: ${book.author}'),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (book.genre.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        book.genre,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(
                                    '\$${book.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: book),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookFormScreen(bookToEdit: book),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, book),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}
