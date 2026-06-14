import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/database/app_database.dart';

class ChunkDetailPage extends ConsumerStatefulWidget {
  final Book book;
  final Chapter chapter;
  final int initialChunkId;

  const ChunkDetailPage({
    super.key,
    required this.book,
    required this.chapter,
    required this.initialChunkId,
  });

  @override
  ConsumerState<ChunkDetailPage> createState() => _ChunkDetailPageState();
}

class _ChunkDetailPageState extends ConsumerState<ChunkDetailPage> {
  late int _chunkId;

  @override
  void initState() {
    super.initState();
    _chunkId = widget.initialChunkId;
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(bookDaoProvider);

    return StreamBuilder<List<Chunk>>(
      stream: dao.watchChunksByChapter(widget.chapter.id),
      builder: (context, snapshot) {
        final chunks = snapshot.data ?? const <Chunk>[];
        final chunk = _findChunk(chunks, _chunkId);
        final index = chunk == null ? -1 : chunks.indexOf(chunk);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              chunk == null
                  ? widget.chapter.title
                  : 'Chunk ${chunk.orderIndex + 1}/${chunks.length}',
            ),
            actions: [
              IconButton(
                tooltip: 'Paragraph status',
                onPressed: chunk == null
                    ? null
                    : () => _showParagraphStatus(context, dao, chunk),
                icon: const Icon(Icons.checklist),
              ),
            ],
          ),
          body: _buildBody(context, chunk, chunks.length),
          bottomNavigationBar: chunk == null
              ? null
              : _ChunkActions(
                  chunk: chunk,
                  isFirst: index <= 0,
                  isLast: index >= chunks.length - 1,
                  onPrevious: () => _goTo(chunks[index - 1].id),
                  onNext: () => _goTo(chunks[index + 1].id),
                  onCopy: () => _copyChunk(context, dao, chunk, false),
                  onCopyWithMetadata: () =>
                      _copyChunk(context, dao, chunk, true),
                  onReadChanged: () =>
                      dao.markChunkRead(chunk.id, !chunk.isRead),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Chunk? chunk, int totalChunks) {
    if (chunk == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      children: [
        Text(widget.book.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${widget.chapter.title} - ${chunk.orderIndex + 1}/$totalChunks - ${chunk.charCount} chars',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        SelectableText(
          chunk.content,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(height: 1.55, fontSize: 18),
        ),
      ],
    );
  }

  Future<void> _showParagraphStatus(
    BuildContext context,
    BookDao dao,
    Chunk chunk,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StreamBuilder<List<BookParagraph>>(
          stream: dao.watchParagraphsByChunk(chunk.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final paragraphs = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text(
                  'Paragraph status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final paragraph in paragraphs)
                  _ParagraphTile(
                    paragraph: paragraph,
                    onChanged: (isRead) =>
                        dao.markParagraphRead(paragraph.id, isRead),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Chunk? _findChunk(List<Chunk> chunks, int id) {
    for (final chunk in chunks) {
      if (chunk.id == id) return chunk;
    }
    return chunks.isEmpty ? null : chunks.first;
  }

  void _goTo(int chunkId) {
    setState(() {
      _chunkId = chunkId;
    });
  }

  Future<void> _copyChunk(
    BuildContext context,
    BookDao dao,
    Chunk chunk,
    bool withMetadata,
  ) async {
    final text = withMetadata
        ? '''
Book: ${widget.book.title}
Chapter: ${widget.chapter.title}
Chunk: ${chunk.orderIndex + 1}

${chunk.content}
'''
        : chunk.content;

    await Clipboard.setData(ClipboardData(text: text));
    await dao.updateChunkCopied(chunk.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied chunk ${chunk.orderIndex + 1}')),
    );
  }
}

class _ParagraphTile extends StatelessWidget {
  final BookParagraph paragraph;
  final ValueChanged<bool> onChanged;

  const _ParagraphTile({required this.paragraph, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: paragraph.isRead,
        onChanged: (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: SelectableText(
          paragraph.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

class _ChunkActions extends StatelessWidget {
  final Chunk chunk;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCopy;
  final VoidCallback onCopyWithMetadata;
  final VoidCallback onReadChanged;

  const _ChunkActions({
    required this.chunk,
    required this.isFirst,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
    required this.onCopy,
    required this.onCopyWithMetadata,
    required this.onReadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous chunk',
                    onPressed: isFirst ? null : onPrevious,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: 'Next chunk',
                    onPressed: isLast ? null : onNext,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReadChanged,
                      icon: Icon(
                        chunk.isRead
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(chunk.isRead ? 'Mark unread' : 'Mark read'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copy text'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onCopyWithMetadata,
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copy meta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
