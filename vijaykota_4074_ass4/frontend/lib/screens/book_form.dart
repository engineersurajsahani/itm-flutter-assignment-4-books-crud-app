import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class BookFormScreen extends StatefulWidget {
  final Book? bookToEdit;

  const BookFormScreen({super.key, this.bookToEdit});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _genreController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _publisherController;
  late TextEditingController _publishedDateController;

  bool get isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _isbnController = TextEditingController(text: b?.isbn ?? '');
    _genreController = TextEditingController(text: b?.genre ?? '');
    _priceController = TextEditingController(text: b != null ? b.price.toString() : '');
    _quantityController = TextEditingController(text: b != null ? b.quantity.toString() : '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _publisherController = TextEditingController(text: b?.publisher ?? '');
    _publishedDateController = TextEditingController(text: b?.publishedDate ?? '');
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
    _publishedDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _publishedDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      id: widget.bookToEdit?.id,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _genreController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      publisher: _publisherController.text.trim(),
      publishedDate: _publishedDateController.text.trim(),
    );

    final provider = Provider.of<BookProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await provider.updateBook(book.id!, book);
    } else {
      success = await provider.addBook(book);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Book updated successfully!'
                : 'Book added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
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
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title *',
                icon: Icons.title,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _authorController,
                label: 'Author *',
                icon: Icons.person,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _isbnController,
                      label: 'ISBN',
                      icon: Icons.qr_code,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _genreController,
                      label: 'Genre',
                      icon: Icons.category,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (\$)',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
                          return 'Enter valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      icon: Icons.inventory_2,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val != null && val.isNotEmpty && int.tryParse(val) == null) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _publisherController,
                      label: 'Publisher',
                      icon: Icons.business,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _publishedDateController,
                          label: 'Published Date',
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Consumer<BookProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Update Book' : 'Save Book',
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  );
                },
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
