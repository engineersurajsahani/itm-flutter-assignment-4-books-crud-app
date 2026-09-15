import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({
    super.key,
    required this.book,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _genreController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _publisherController;

  late DateTime _publishedDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final book = widget.book;

    _titleController =
        TextEditingController(text: book.title);

    _authorController =
        TextEditingController(text: book.author);

    _isbnController =
        TextEditingController(text: book.isbn);

    _genreController =
        TextEditingController(text: book.genre);

    _priceController =
        TextEditingController(text: book.price.toString());

    _quantityController =
        TextEditingController(text: book.quantity.toString());

    _descriptionController =
        TextEditingController(text: book.description);

    _publisherController =
        TextEditingController(text: book.publisher);

    _publishedDate = book.publishedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _genreController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                icon: Icons.book,
                required: true,
              ),

              _buildTextField(
                controller: _authorController,
                label: 'Author',
                icon: Icons.person,
                required: true,
              ),

              _buildTextField(
                controller: _isbnController,
                label: 'ISBN',
                icon: Icons.numbers,
                required: true,
              ),

              _buildTextField(
                controller: _genreController,
                label: 'Genre',
                icon: Icons.category,
              ),

              _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.currency_rupee,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                required: true,
              ),

              _buildTextField(
                controller: _quantityController,
                label: 'Quantity',
                icon: Icons.inventory_2,
                keyboardType: TextInputType.number,
                required: true,
              ),

              _buildTextField(
                controller: _publisherController,
                label: 'Publisher',
                icon: Icons.business,
              ),

              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: const Text('Published Date'),
                subtitle: Text(
                  '${_publishedDate.day}/'
                  '${_publishedDate.month}/'
                  '${_publishedDate.year}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _selectDate,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _updateBook,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Updating...' : 'Update Book',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (required &&
              (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }

          if (label == 'Price' &&
              value != null &&
              value.isNotEmpty &&
              double.tryParse(value) == null) {
            return 'Enter a valid price';
          }

          if (label == 'Quantity' &&
              value != null &&
              value.isNotEmpty &&
              int.tryParse(value) == null) {
            return 'Enter a valid quantity';
          }

          return null;
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _publishedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _publishedDate = selectedDate;
      });
    }
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedBook = Book(
      id: widget.book.id,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _genreController.text.trim(),
      price: double.parse(
        _priceController.text.trim(),
      ),
      quantity: int.parse(
        _quantityController.text.trim(),
      ),
      description: _descriptionController.text.trim(),
      publisher: _publisherController.text.trim(),
      publishedDate: _publishedDate,
    );

    final success = await context
        .read<BookProvider>()
        .updateBook(updatedBook);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book updated successfully'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update book. ISBN may already exist.',
          ),
        ),
      );
    }
  }
}