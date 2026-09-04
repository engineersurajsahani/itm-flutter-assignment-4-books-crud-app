import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.menu_book_rounded,
    this.actionLabel,
    this.onAction,
  });

  /// Specialized constructor for empty search results
  factory EmptyState.noSearchResults({VoidCallback? onClear}) {
    return EmptyState(
      title: 'No Matching Books',
      message: 'Try adjusting your search query or genre filter.',
      icon: Icons.search_off_rounded,
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }

  /// Specialized constructor for initial empty library
  factory EmptyState.noBooks({VoidCallback? onAddBook}) {
    return EmptyState(
      title: 'No Books Yet',
      message: 'Your library is empty. Add your first book to get started!',
      icon: Icons.library_books_rounded,
      actionLabel: onAddBook != null ? 'Add First Book' : null,
      onAction: onAddBook,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
