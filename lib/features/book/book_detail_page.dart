import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/database/app_database.dart';
import 'chapter_chunks_page.dart';

class BookDetailPage extends ConsumerWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(bookDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            tooltip: 'Delete book',
            onPressed: () => _confirmDelete(context, dao),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: StreamBuilder<List<Chapter>>(
        stream: dao.watchChaptersByBook(book.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chapters = snapshot.data!;
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: chapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _ChapterTile(
                chapter: chapter,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ChapterChunksPage(book: book, chapter: chapter),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BookDao dao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete book'),
        content: Text(book.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await dao.deleteBookCascade(book.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterTile({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = chapter.paragraphCount == 0
        ? 0.0
        : chapter.readParagraphCount / chapter.paragraphCount;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(
          chapter.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${chapter.chunkCount} chunks  |  ${chapter.charCount} chars',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text(
              '${chapter.readParagraphCount}/${chapter.paragraphCount} paragraphs read',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
