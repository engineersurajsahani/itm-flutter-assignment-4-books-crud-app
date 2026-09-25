import 'package:flutter/material.dart';

import 'screens/book_list.dart';

void main() => runApp(const BooksApp());

class BooksApp extends StatelessWidget {
  const BooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelfwise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1c6e63)),
        scaffoldBackgroundColor: const Color(0xfff5f7f4),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      home: const BookListScreen(),
    );
  }
}
