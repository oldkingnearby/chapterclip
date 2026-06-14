import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database/app_database.dart';
import 'features/library/library_page.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final bookDaoProvider = Provider<BookDao>((ref) {
  return ref.watch(appDatabaseProvider).bookDao;
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(bookDaoProvider).watchBooks();
});

class ChapterClipApp extends StatelessWidget {
  const ChapterClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChapterClip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LibraryPage(),
    );
  }
}
