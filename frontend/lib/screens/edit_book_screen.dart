import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_form.dart';

class EditBookScreen extends StatelessWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  Future<void> _handleUpdateBook(BuildContext context, Book updatedBook) async {
    final provider = context.read<BookProvider>();
    final success = await provider.updateBook(updatedBook);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book "${updatedBook.title}" updated successfully!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to update book'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          return BookForm(
            initialBook: book,
            submitButtonLabel: 'Update Book',
            isLoading: provider.isActionLoading,
            onSubmit: (updatedBook) => _handleUpdateBook(context, updatedBook),
          );
        },
      ),
    );
  }
}
