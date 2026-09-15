import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class BookForm extends StatefulWidget {
  final Book? initialBook;
  final String submitButtonLabel;
  final bool isLoading;
  final Future<void> Function(Book book) onSubmit;

  const BookForm({
    super.key,
    this.initialBook,
    required this.submitButtonLabel,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _genreController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _publisherController;

  DateTime? _selectedDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final book = widget.initialBook;

    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _genreController = TextEditingController(text: book?.genre ?? '');
    _priceController = TextEditingController(
        text: book != null ? book.price.toString() : '');
    _quantityController = TextEditingController(
        text: book != null ? book.quantity.toString() : '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');

    _selectedDate = book?.publishedDate ?? DateTime.now();
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
        _dateError = null;
      });
    }
  }

  void _handleSubmit() {
    // Validate date
    if (_selectedDate == null) {
      setState(() {
        _dateError = 'Published date is required';
      });
    } else {
      setState(() {
        _dateError = null;
      });
    }

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final quantity = int.parse(_quantityController.text.trim());

    final book = Book(
      id: widget.initialBook?.id ?? '',
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      genre: _genreController.text.trim(),
      price: price,
      quantity: quantity,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      publisher: _publisherController.text.trim().isNotEmpty
          ? _publisherController.text.trim()
          : null,
      publishedDate: _selectedDate!,
    );

    widget.onSubmit(book);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title *',
                hintText: 'e.g., The Alchemist',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateTitle,
            ),
            const SizedBox(height: 16),

            // Author Field
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                hintText: 'e.g., Paulo Coelho',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateAuthor,
            ),
            const SizedBox(height: 16),

            // ISBN Field
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN *',
                hintText: 'e.g., 9780061122415',
                prefixIcon: Icon(Icons.qr_code_outlined),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateIsbn,
            ),
            const SizedBox(height: 16),

            // Genre Field with Quick Suggestions
            TextFormField(
              controller: _genreController,
              decoration: InputDecoration(
                labelText: 'Genre *',
                hintText: 'e.g., Fiction, Technology',
                prefixIcon: const Icon(Icons.category_outlined),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  tooltip: 'Select common genre',
                  onSelected: (genre) {
                    setState(() {
                      _genreController.text = genre;
                    });
                  },
                  itemBuilder: (context) => AppConstants.commonGenres
                      .map((g) => PopupMenuItem(value: g, child: Text(g)))
                      .toList(),
                ),
              ),
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateGenre,
            ),
            const SizedBox(height: 16),

            // Price & Quantity Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$) *',
                      hintText: '19.99',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: AppValidators.validatePrice,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      hintText: '10',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: AppValidators.validateQuantity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Publisher Field
            TextFormField(
              controller: _publisherController,
              decoration: const InputDecoration(
                labelText: 'Publisher (Optional)',
                hintText: 'e.g., HarperCollins',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Published Date Picker Tile
            InkWell(
              onTap: _pickPublishedDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _dateError != null
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFFCBD5E1),
                    width: _dateError != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Published Date *',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedDate != null
                                ? DateFormat('MMMM d, y').format(_selectedDate!)
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDate != null
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_outlined, size: 20, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
            if (_dateError != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  _dateError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a short summary or description...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
                ),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),

            // Submit Button with Loading Indicator
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.submitButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
