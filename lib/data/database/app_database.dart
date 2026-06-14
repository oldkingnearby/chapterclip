import 'dart:io';

import 'package:characters/characters.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Books, Chapters, Chunks, BookParagraphs],
  daos: [BookDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = p.join(dir.path, 'chapterclip.sqlite');
    return NativeDatabase.createInBackground(File(file));
  });
}

class BookImportDraft {
  final String title;
  final String? author;
  final String? language;
  final String sourceFileName;
  final String? sourceFilePath;
  final int chunkTargetChars;
  final List<ChapterImportDraft> chapters;

  const BookImportDraft({
    required this.title,
    this.author,
    this.language,
    required this.sourceFileName,
    this.sourceFilePath,
    required this.chunkTargetChars,
    required this.chapters,
  });
}

class ChapterImportDraft {
  final String title;
  final String? href;
  final List<String> paragraphs;
  final List<ChunkImportDraft> chunks;

  const ChapterImportDraft({
    required this.title,
    this.href,
    required this.paragraphs,
    required this.chunks,
  });
}

class ChunkImportDraft {
  final String? title;
  final String text;
  final int charCount;
  final int paragraphStartIndex;
  final int paragraphEndIndex;

  const ChunkImportDraft({
    this.title,
    required this.text,
    required this.charCount,
    required this.paragraphStartIndex,
    required this.paragraphEndIndex,
  });
}

class BookProgress {
  final int readParagraphCount;
  final int totalParagraphCount;
  final int readChunkCount;
  final int totalChunkCount;

  const BookProgress({
    required this.readParagraphCount,
    required this.totalParagraphCount,
    required this.readChunkCount,
    required this.totalChunkCount,
  });

  factory BookProgress.fromBook(Book book) {
    return BookProgress(
      readParagraphCount: book.readParagraphCount,
      totalParagraphCount: book.totalParagraphCount,
      readChunkCount: book.readChunkCount,
      totalChunkCount: book.totalChunkCount,
    );
  }

  double get paragraphFraction {
    if (totalParagraphCount == 0) return 0;
    return readParagraphCount / totalParagraphCount;
  }

  double get chunkFraction {
    if (totalChunkCount == 0) return 0;
    return readChunkCount / totalChunkCount;
  }
}

@DriftAccessor(tables: [Books, Chapters, Chunks, BookParagraphs])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Future<int> insertBookWithChaptersAndChunks(BookImportDraft draft) {
    return transaction(() async {
      final now = DateTime.now();
      final totalParagraphCount = draft.chapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.paragraphs.length,
      );
      final totalChunkCount = draft.chapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.chunks.length,
      );

      final bookId = await into(books).insert(
        BooksCompanion.insert(
          title: draft.title,
          author: Value(draft.author),
          language: Value(draft.language),
          sourceFileName: draft.sourceFileName,
          sourceFilePath: Value(draft.sourceFilePath),
          importedAt: now,
          updatedAt: now,
          chunkTargetChars: draft.chunkTargetChars,
          totalParagraphCount: Value(totalParagraphCount),
          totalChunkCount: Value(totalChunkCount),
        ),
      );

      for (var chapterIndex = 0;
          chapterIndex < draft.chapters.length;
          chapterIndex++) {
        final chapter = draft.chapters[chapterIndex];
        final chapterId = await into(chapters).insert(
          ChaptersCompanion.insert(
            bookId: bookId,
            orderIndex: chapterIndex,
            title: chapter.title,
            href: Value(chapter.href),
            charCount: _countChapterCharacters(chapter.paragraphs),
            paragraphCount: chapter.paragraphs.length,
            chunkCount: chapter.chunks.length,
          ),
        );

        final chunkIds = <int>[];
        for (var chunkIndex = 0;
            chunkIndex < chapter.chunks.length;
            chunkIndex++) {
          final chunk = chapter.chunks[chunkIndex];
          final chunkId = await into(chunks).insert(
            ChunksCompanion.insert(
              bookId: bookId,
              chapterId: chapterId,
              orderIndex: chunkIndex,
              title: chunk.title ?? 'Chunk ${chunkIndex + 1}',
              content: chunk.text,
              charCount: chunk.charCount,
              paragraphStartIndex: chunk.paragraphStartIndex,
              paragraphEndIndex: chunk.paragraphEndIndex,
            ),
          );
          chunkIds.add(chunkId);
        }

        for (var paragraphIndex = 0;
            paragraphIndex < chapter.paragraphs.length;
            paragraphIndex++) {
          final text = chapter.paragraphs[paragraphIndex];
          final chunkIndex = chapter.chunks.indexWhere(
            (chunk) =>
                paragraphIndex >= chunk.paragraphStartIndex &&
                paragraphIndex <= chunk.paragraphEndIndex,
          );

          await into(bookParagraphs).insert(
            BookParagraphsCompanion.insert(
              bookId: bookId,
              chapterId: chapterId,
              chunkId: chunkIndex == -1
                  ? const Value.absent()
                  : Value(chunkIds[chunkIndex]),
              orderIndex: paragraphIndex,
              content: text,
              charCount: text.characters.length,
            ),
          );
        }
      }

      await _refreshProgressForBook(bookId);
      return bookId;
    });
  }

  Stream<List<Book>> watchBooks() {
    return (select(books)
          ..orderBy([
            (book) => OrderingTerm(
                expression: book.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Chapter>> watchChaptersByBook(int bookId) {
    return (select(chapters)
          ..where((chapter) => chapter.bookId.equals(bookId))
          ..orderBy([(chapter) => OrderingTerm.asc(chapter.orderIndex)]))
        .watch();
  }

  Stream<List<Chunk>> watchChunksByChapter(int chapterId) {
    return (select(chunks)
          ..where((chunk) => chunk.chapterId.equals(chapterId))
          ..orderBy([(chunk) => OrderingTerm.asc(chunk.orderIndex)]))
        .watch();
  }

  Stream<List<BookParagraph>> watchParagraphsByChunk(int chunkId) {
    return (select(bookParagraphs)
          ..where((paragraph) => paragraph.chunkId.equals(chunkId))
          ..orderBy([(paragraph) => OrderingTerm.asc(paragraph.orderIndex)]))
        .watch();
  }

  Stream<BookProgress> watchBookProgress(int bookId) {
    return (select(books)..where((book) => book.id.equals(bookId)))
        .watchSingle()
        .map(BookProgress.fromBook);
  }

  Future<void> deleteBookCascade(int bookId) async {
    await (delete(books)..where((book) => book.id.equals(bookId))).go();
  }

  Future<void> updateChunkCopied(int chunkId, {DateTime? copiedAt}) {
    return transaction(() async {
      final chunk = await (select(
        chunks,
      )..where((c) => c.id.equals(chunkId)))
          .getSingleOrNull();
      if (chunk == null) return;

      await (update(chunks)..where((c) => c.id.equals(chunkId))).write(
        ChunksCompanion(
          copiedCount: Value(chunk.copiedCount + 1),
          lastCopiedAt: Value(copiedAt ?? DateTime.now()),
        ),
      );
      await _touchBook(chunk.bookId);
    });
  }

  Future<void> markChunkRead(int chunkId, bool isRead) {
    return transaction(() async {
      final chunk = await (select(
        chunks,
      )..where((c) => c.id.equals(chunkId)))
          .getSingleOrNull();
      if (chunk == null) return;

      final readAt = isRead ? DateTime.now() : null;
      await (update(chunks)..where((c) => c.id.equals(chunkId))).write(
        ChunksCompanion(isRead: Value(isRead), readAt: Value(readAt)),
      );
      await (update(
        bookParagraphs,
      )..where((paragraph) => paragraph.chunkId.equals(chunkId)))
          .write(
        BookParagraphsCompanion(isRead: Value(isRead), readAt: Value(readAt)),
      );
      await _refreshProgressForBook(chunk.bookId);
    });
  }

  Future<void> markParagraphRead(int paragraphId, bool isRead) {
    return transaction(() async {
      final paragraph = await (select(
        bookParagraphs,
      )..where((p) => p.id.equals(paragraphId)))
          .getSingleOrNull();
      if (paragraph == null) return;

      await (update(
        bookParagraphs,
      )..where((p) => p.id.equals(paragraphId)))
          .write(
        BookParagraphsCompanion(
          isRead: Value(isRead),
          readAt: Value(isRead ? DateTime.now() : null),
        ),
      );

      final chunkId = paragraph.chunkId;
      if (chunkId != null) {
        await _refreshChunkReadState(chunkId);
      }
      await _refreshProgressForBook(paragraph.bookId);
    });
  }

  Future<void> _refreshChunkReadState(int chunkId) async {
    final paragraphs = await (select(
      bookParagraphs,
    )..where((paragraph) => paragraph.chunkId.equals(chunkId)))
        .get();
    final isRead = paragraphs.isNotEmpty && paragraphs.every((p) => p.isRead);
    await (update(chunks)..where((chunk) => chunk.id.equals(chunkId))).write(
      ChunksCompanion(
        isRead: Value(isRead),
        readAt: Value(isRead ? DateTime.now() : null),
      ),
    );
  }

  Future<void> _refreshProgressForBook(int bookId) async {
    final bookChapters = await (select(
      chapters,
    )..where((chapter) => chapter.bookId.equals(bookId)))
        .get();

    var totalParagraphCount = 0;
    var readParagraphCount = 0;
    var totalChunkCount = 0;
    var readChunkCount = 0;

    for (final chapter in bookChapters) {
      final paragraphs = await (select(
        bookParagraphs,
      )..where((paragraph) => paragraph.chapterId.equals(chapter.id)))
          .get();
      final chapterChunks = await (select(
        chunks,
      )..where((chunk) => chunk.chapterId.equals(chapter.id)))
          .get();

      final chapterReadParagraphCount =
          paragraphs.where((paragraph) => paragraph.isRead).length;
      final chapterReadChunkCount =
          chapterChunks.where((chunk) => chunk.isRead).length;

      await (update(chapters)..where((c) => c.id.equals(chapter.id))).write(
        ChaptersCompanion(
          paragraphCount: Value(paragraphs.length),
          readParagraphCount: Value(chapterReadParagraphCount),
          chunkCount: Value(chapterChunks.length),
          readChunkCount: Value(chapterReadChunkCount),
        ),
      );

      totalParagraphCount += paragraphs.length;
      readParagraphCount += chapterReadParagraphCount;
      totalChunkCount += chapterChunks.length;
      readChunkCount += chapterReadChunkCount;
    }

    await (update(books)..where((book) => book.id.equals(bookId))).write(
      BooksCompanion(
        updatedAt: Value(DateTime.now()),
        totalParagraphCount: Value(totalParagraphCount),
        readParagraphCount: Value(readParagraphCount),
        totalChunkCount: Value(totalChunkCount),
        readChunkCount: Value(readChunkCount),
      ),
    );
  }

  Future<void> _touchBook(int bookId) async {
    await (update(books)..where((book) => book.id.equals(bookId))).write(
      BooksCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  static int _countChapterCharacters(List<String> paragraphs) {
    return paragraphs.join('\n\n').characters.length;
  }
}
