import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_view.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import 'edit_book_screen.dart';

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
      context.read<BookProvider>().fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(Book book) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book?'),
          content: Text(
            'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<BookProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: provider.isActionLoading
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await provider.deleteBook(book.id);
                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Book "${book.title}" deleted successfully'
                                    : (provider.errorMessage ?? 'Unable to delete book'),
                              ),
                              backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          );
                        },
                  child: const Text('Delete'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, size: 24),
            SizedBox(width: 10),
            Text('Books Management'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<BookProvider>().refreshBooks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<BookProvider>().searchBooks(val),
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, ISBN...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              context.read<BookProvider>().searchBooks('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 10),

                // Genre Filter Chips (Horizontal list)
                Consumer<BookProvider>(
                  builder: (context, provider, _) {
                    final genres = provider.availableGenres;
                    return SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: genres.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final genre = genres[index];
                          final isSelected = provider.selectedGenre == genre;

                          return FilterChip(
                            label: Text(genre),
                            selected: isSelected,
                            onSelected: (_) => provider.filterByGenre(genre),
                            selectedColor: theme.colorScheme.primary.withAlpha(40),
                            checkmarkColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade700,
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Main Books Content Body
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, _) {
                // 1. Loading State
                if (provider.isLoading && provider.books.isEmpty) {
                  return const LoadingView(message: 'Loading books from server...');
                }

                // 2. Error State
                if (provider.errorMessage != null && provider.books.isEmpty) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.fetchBooks(),
                  );
                }

                // 3. Completely Empty Library
                if (provider.books.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: provider.refreshBooks,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(top: 80),
                        child: EmptyState.noBooks(
                          onAddBook: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddBookScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }

                // 4. Empty Search or Filter Result
                if (provider.filteredBooks.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: provider.refreshBooks,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(top: 80),
                        child: EmptyState.noSearchResults(
                          onClear: () {
                            _searchController.clear();
                            provider.searchBooks('');
                            provider.filterByGenre('All');
                          },
                        ),
                      ),
                    ),
                  );
                }

                // 5. Book List View
                return RefreshIndicator(
                  onRefresh: provider.refreshBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 88),
                    itemCount: provider.filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = provider.filteredBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditBookScreen(book: book),
                            ),
                          );
                        },
                        onDelete: () => _showDeleteConfirmation(book),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
