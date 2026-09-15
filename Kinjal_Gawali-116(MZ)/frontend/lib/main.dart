import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/book_provider.dart';
import 'screens/book_list_screen.dart';

void main() {
  runApp(const BooksApp());
}

class BooksApp extends StatelessWidget {
  const BooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fawn = Color(0xFFD6A97D);
    const wheat = Color(0xFFDCC6A4);
    const mistyRose = Color(0xFFDFA4B3);
    const salmonPink = Color(0xFFEA9BA6);
    const bole = Color(0xFF734E3B);
    const parchment = Color(0xFFF7F0E3);

    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: MaterialApp(
        title: 'Fairy Tale Library',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: parchment,
          colorScheme: ColorScheme.fromSeed(
            seedColor: fawn,
            brightness: Brightness.light,
            primary: fawn,
            secondary: wheat,
            tertiary: mistyRose,
            surface: Colors.white,
            onSurface: bole,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: fawn,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF7F1EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: wheat),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: bole, width: 2),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: salmonPink,
            foregroundColor: Colors.white,
          ),
        ),
        home: const BookListScreen(),
      ),
    );
  }
}
