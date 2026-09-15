class AppValidators {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  static String? validateAuthor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Author is required';
    }
    return null;
  }

  static String? validateIsbn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ISBN is required';
    }
    // Remove dashes/spaces to check length
    final clean = value.replaceAll(RegExp(r'[-\s]'), '');
    if (clean.length < 5) {
      return 'Please enter a valid ISBN';
    }
    return null;
  }

  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Genre is required';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Price must be a valid number';
    }
    if (price < 0) {
      return 'Price must be greater than or equal to 0';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Quantity must be a valid integer';
    }
    if (quantity < 0) {
      return 'Quantity must be greater than or equal to 0';
    }
    return null;
  }

  static String? validatePublishedDate(DateTime? value) {
    if (value == null) {
      return 'Published date is required';
    }
    return null;
  }
}
