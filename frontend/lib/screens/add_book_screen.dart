import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_form.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  Future<void> _handleCreateBook(BuildContext context, Book book) async {
    final provider = context.read<BookProvider>();
    final success = await provider.addBook(book);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book "${book.title}" added successfully!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to add book'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          return BookForm(
            submitButtonLabel: 'Create Book',
            isLoading: provider.isActionLoading,
            onSubmit: (book) => _handleCreateBook(context, book),
          );
        },
      ),
    );
  }
}
