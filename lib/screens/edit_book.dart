import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _publisherController;

  late String _selectedGenre;
  DateTime? _selectedDate;
  bool _isSaving = false;

  final List<String> _genres = [
    'Software Engineering',
    'Programming',
    'Mobile Development',
    'Fiction',
    'Non-Fiction',
    'Science',
    'Fantasy',
    'Biography',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _quantityController =
        TextEditingController(text: widget.book.quantity.toString());
    _descriptionController =
        TextEditingController(text: widget.book.description);
    _publisherController =
        TextEditingController(text: widget.book.publisher);

    _selectedGenre = _genres.contains(widget.book.genre)
        ? widget.book.genre
        : 'Other';
    _selectedDate = widget.book.publishedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _pickPublishedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1800),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _selectedGenre,
      price: double.tryParse(_priceController.text.trim()) ?? widget.book.price,
      quantity:
          int.tryParse(_quantityController.text.trim()) ?? widget.book.quantity,
      description: _descriptionController.text.trim(),
      publisher: _publisherController.text.trim(),
      publishedDate: _selectedDate,
    );

    final provider = Provider.of<BookProvider>(context, listen: false);
    final success = await provider.updateBook(updatedBook);

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ "${updatedBook.title}" updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(updatedBook);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('⚠️ ${provider.errorMessage ?? 'Failed to update book'}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update Book Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Title (Required)
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Book Title *',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Book title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Author (Required)
                TextFormField(
                  controller: _authorController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Author Name *',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Author name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ISBN
                TextFormField(
                  controller: _isbnController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'ISBN Number',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),

                // Genre Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedGenre,
                  decoration: InputDecoration(
                    labelText: 'Genre',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _genres
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedGenre = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Price & Quantity Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Price (\$ USD) *',
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Price is required';
                          }
                          final p = double.tryParse(val.trim());
                          if (p == null || p < 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Quantity *',
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Quantity is required';
                          }
                          final q = int.tryParse(val.trim());
                          if (q == null || q < 0) {
                            return 'Enter valid integer';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Publisher
                TextFormField(
                  controller: _publisherController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Publisher',
                    prefixIcon: const Icon(Icons.business_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),

                // Published Date Picker Tile
                InkWell(
                  onTap: _pickPublishedDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? 'Published: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                                : 'Select Publication Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDate != null
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: Icon(Icons.description_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 28),

                // Update Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _isSaving ? 'Updating...' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
