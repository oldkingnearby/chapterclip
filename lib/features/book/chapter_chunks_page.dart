import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/database/app_database.dart';
import 'chunk_detail_page.dart';

class ChapterChunksPage extends ConsumerWidget {
  final Book book;
  final Chapter chapter;

  const ChapterChunksPage({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(bookDaoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: StreamBuilder<List<Chunk>>(
        stream: dao.watchChunksByChapter(chapter.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chunks = snapshot.data!;
          if (chunks.isEmpty) {
            return const Center(child: Text('No chunks found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: chunks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chunk = chunks[index];
              return _ChunkTile(
                chunk: chunk,
                totalChunks: chunks.length,
                onReadChanged: (isRead) => dao.markChunkRead(chunk.id, isRead),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChunkDetailPage(
                        book: book,
                        chapter: chapter,
                        initialChunkId: chunk.id,
                      ),
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
}

class _ChunkTile extends StatelessWidget {
  final Chunk chunk;
  final int totalChunks;
  final ValueChanged<bool> onReadChanged;
  final VoidCallback onTap;

  const _ChunkTile({
    required this.chunk,
    required this.totalChunks,
    required this.onReadChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = chunk.content.replaceAll(RegExp(r'\s+'), ' ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text('${chunk.orderIndex + 1}')),
        title: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Chunk ${chunk.orderIndex + 1}/$totalChunks  |  ${chunk.charCount} chars  |  paragraphs ${chunk.paragraphStartIndex + 1}-${chunk.paragraphEndIndex + 1}  |  copied ${chunk.copiedCount}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Checkbox(
          value: chunk.isRead,
          onChanged: (value) => onReadChanged(value ?? false),
        ),
      ),
    );
  }
}
