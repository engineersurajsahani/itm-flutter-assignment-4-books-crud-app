import 'package:flutter/material.dart';

import 'edit_book.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});
  @override
  Widget build(BuildContext context) => BookFormScreen(
    title: 'Add book',
    onSave: (book) => Navigator.pop(context, book),
  );
}
