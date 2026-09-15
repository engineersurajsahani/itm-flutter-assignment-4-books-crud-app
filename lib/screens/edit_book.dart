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
  DateTime? _publishedDate;
  bool _isSubmitting = false;

  final List<String> _genreOptions = [
    'Technology',
    'Software Engineering',
    'Computer Science',
    'Fiction',
    'Non-Fiction',
    'Science',
    'Business',
    'Biography',
    'Self-Help',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _quantityController = TextEditingController(text: widget.book.quantity.toString());
    _descriptionController = TextEditingController(text: widget.book.description);
    _publisherController = TextEditingController(text: widget.book.publisher);

    _selectedGenre = _genreOptions.contains(widget.book.genre)
        ? widget.book.genre
        : (_genreOptions.contains('Other') ? 'Other' : _genreOptions.first);
    _publishedDate = widget.book.publishedDate;
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _publishedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _selectedGenre,
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      publisher: _publisherController.text.trim(),
      publishedDate: _publishedDate,
    );

    final provider = Provider.of<BookProvider>(context, listen: false);
    final success = await provider.updateBook(widget.book.id, updatedBook);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updatedBook.title}" updated successfully!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(updatedBook);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update book'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Book',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Essential Information
              _buildSectionTitle('Essential Details', Icons.info_outline),
              const SizedBox(height: 12),

              _buildCardContainer(
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Book Title *',
                    hint: 'e.g. Clean Code',
                    icon: Icons.book,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the book title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _authorController,
                    label: 'Author Name *',
                    hint: 'e.g. Robert C. Martin',
                    icon: Icons.person_outline,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter author name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _isbnController,
                    label: 'ISBN Number * (Unique)',
                    hint: 'e.g. 978-0132350884',
                    icon: Icons.qr_code,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter ISBN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedGenre,
                    decoration: _inputDecoration(
                      label: 'Genre / Category',
                      icon: Icons.category_outlined,
                    ),
                    items: _genreOptions.map((genre) {
                      return DropdownMenuItem(value: genre, child: Text(genre));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGenre = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Pricing & Inventory
              _buildSectionTitle('Pricing & Inventory', Icons.attach_money),
              const SizedBox(height: 12),

              _buildCardContainer(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Price (USD)',
                          hint: '29.99',
                          icon: Icons.payments_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal < 0) {
                                return 'Invalid price';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: _buildTextField(
                          controller: _quantityController,
                          label: 'Stock Quantity',
                          hint: '10',
                          icon: Icons.inventory_outlined,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final intVal = int.tryParse(val.trim());
                              if (intVal == null || intVal < 0) {
                                return 'Invalid quantity';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Publication Info & Description
              _buildSectionTitle('Publication & Details', Icons.library_books_outlined),
              const SizedBox(height: 12),

              _buildCardContainer(
                children: [
                  _buildTextField(
                    controller: _publisherController,
                    label: 'Publisher',
                    hint: 'e.g. Prentice Hall',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        label: 'Publication Date',
                        icon: Icons.calendar_today_outlined,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _publishedDate != null
                                ? DateFormat('MMMM dd, yyyy').format(_publishedDate!)
                                : 'Select publication date',
                            style: TextStyle(
                              color: _publishedDate != null
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (_publishedDate != null)
                            InkWell(
                              onTap: () => setState(() => _publishedDate = null),
                              child: const Icon(Icons.close, size: 18, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Book Description',
                    hint: 'Brief summary or key topics...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Update Book',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
