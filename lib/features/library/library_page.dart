import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../data/database/app_database.dart';
import '../../utils/app_update_flow.dart';
import '../book/book_detail_page.dart';
import '../import/epub_import_service.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  bool _isImporting = false;
  String? _importMessage;
  double? _importFraction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateFlow.check(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChapterClip'),
        actions: [
          IconButton(
            tooltip: 'Import EPUB',
            onPressed: _isImporting ? null : _pickAndImport,
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isImporting)
            _ImportProgressBar(
              message: _importMessage ?? 'Importing',
              fraction: _importFraction,
            ),
          Expanded(
            child: books.when(
              data: (items) {
                if (items.isEmpty) {
                  return const _EmptyLibrary();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final book = items[index];
                    return _BookTile(
                      book: book,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BookDetailPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _LoadError(message: '$error'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImport() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'EPUB', extensions: ['epub']),
      ],
    );
    if (file == null) return;

    if (!mounted) return;
    final targetChars = await _askTargetChars(context);
    if (targetChars == null) return;

    setState(() {
      _isImporting = true;
      _importMessage = 'Reading EPUB file';
      _importFraction = null;
    });

    try {
      final bytes = await file.readAsBytes();
      final service = EpubImportService(ref.read(appDatabaseProvider));
      await service.importBytes(
        bytes: bytes,
        sourceFileName: _sourceFileName(file),
        sourceFilePath: file.path,
        chunkTargetChars: targetChars,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _importMessage = progress.message;
            _importFraction = progress.fraction;
          });
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('EPUB imported')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importMessage = null;
          _importFraction = null;
        });
      }
    }
  }

  String _sourceFileName(XFile file) {
    final name = file.name.trim();
    if (name.isNotEmpty && !name.startsWith('content://')) {
      return name;
    }

    final uri = Uri.tryParse(file.path);
    final lastSegment =
        uri?.pathSegments.isEmpty ?? true ? '' : uri!.pathSegments.last;
    final decoded = Uri.decodeComponent(lastSegment).trim();
    if (decoded.isNotEmpty && !decoded.contains('/')) {
      return decoded;
    }

    return 'selected.epub';
  }

  Future<int?> _askTargetChars(BuildContext context) async {
    final controller = TextEditingController(text: '3000');
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chunk target'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Characters per chunk',
              hintText: '3000',
            ),
            onSubmitted: (_) => _submitTargetChars(context, controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _submitTargetChars(context, controller),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value;
  }

  void _submitTargetChars(
    BuildContext context,
    TextEditingController controller,
  ) {
    final value = int.tryParse(controller.text.trim());
    if (value == null || value <= 0) return;
    Navigator.of(context).pop(value);
  }
}

class _ImportProgressBar extends StatelessWidget {
  final String message;
  final double? fraction;

  const _ImportProgressBar({required this.message, required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: fraction),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = book.totalParagraphCount == 0
        ? 0.0
        : book.readParagraphCount / book.totalParagraphCount;
    final importedAt = DateFormat.yMMMd().add_Hm().format(book.importedAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              [
                if (book.author != null) book.author,
                '${book.totalChunkCount} chunks',
                importedAt,
              ].whereType<String>().join('  |  '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text(
              '${book.readParagraphCount}/${book.totalParagraphCount} paragraphs read',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No books imported',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;

  const _LoadError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
