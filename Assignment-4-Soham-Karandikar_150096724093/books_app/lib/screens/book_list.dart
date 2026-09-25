import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/api_service.dart';
import 'add_book.dart';
import 'book_detail.dart';
import 'edit_book.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});
  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final api = ApiService();
  final search = TextEditingController();
  List<Book> books = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final items = await api.getBooks();
    if (mounted) setState(() => books = items);
  }

  List<Book> get filtered => books
      .where(
        (book) => '${book.title} ${book.author} ${book.genre}'
            .toLowerCase()
            .contains(query.toLowerCase()),
      )
      .toList();

  Future<void> add() async {
    final book = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (book != null) {
      await api.createBook(book);
      loadBooks();
    }
  }

  Future<void> open(Book book) async {
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
    if (action == 'delete') {
      await api.deleteBook(book.id);
      loadBooks();
    }
    if (action == 'edit' && mounted) {
      final edited = await Navigator.push<Book>(
        context,
        MaterialPageRoute(
          builder: (_) => BookFormScreen(
            title: 'Edit book',
            book: book,
            onSave: (value) => Navigator.pop(context, value),
          ),
        ),
      );
      if (edited != null) {
        await api.updateBook(edited);
        loadBooks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shelfwise',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(onPressed: add, icon: const Icon(Icons.add_box_outlined)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadBooks,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your library',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${books.length} books in your collection',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: search,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search by title, author, or genre',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All books',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                FilledButton.icon(
                  onPressed: add,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add book'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filtered.map(
              (book) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => open(book),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffd7e9df),
                    child: Icon(Icons.menu_book, color: Color(0xff1c6e63)),
                  ),
                  title: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${book.author}\n${book.genre}  •  \$${book.price.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
}
