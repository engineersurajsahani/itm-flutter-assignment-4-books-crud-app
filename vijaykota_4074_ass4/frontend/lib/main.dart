import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'screens/book_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: MaterialApp(
        title: 'Books CRUD App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667EEA),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            scrolledUnderElevation: 2,
          ),
        ),
        home: const BookListScreen(),
      ),
    );
  }
}
