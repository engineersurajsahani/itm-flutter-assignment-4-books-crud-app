import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _genreController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _publisherController;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn);
    _genreController = TextEditingController(text: widget.book.genre);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _quantityController = TextEditingController(text: widget.book.quantity.toString());
    _descriptionController = TextEditingController(text: widget.book.description);
    _publisherController = TextEditingController(text: widget.book.publisher);
    _selectedDate = widget.book.publishedDate;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _genreController.text.trim().isEmpty ? 'General' : _genreController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      description: _descriptionController.text.trim(),
      publisher: _publisherController.text.trim(),
      publishedDate: _selectedDate,
    );

    final provider = Provider.of<BookProvider>(context, listen: false);
    final success = await provider.updateBook(updatedBook);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Book updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedBook);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Book Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title *',
                  prefixIcon: Icon(Icons.book_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Author Field
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author Name *',
                  prefixIcon: Icon(Icons.person_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // ISBN and Genre
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: Icon(Icons.category_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Price and Quantity
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (USD)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty) {
                          if (double.tryParse(val) == null) {
                            return 'Enter valid price';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.inventory_2_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty) {
                          if (int.tryParse(val) == null) {
                            return 'Enter valid quantity';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Publisher Field
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher',
                  prefixIcon: Icon(Icons.business_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Published Date Selector
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Published Date',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_rounded),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _submitForm,
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.update_rounded),
                  label: Text(
                    provider.isLoading ? 'Updating...' : 'Update Book',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
