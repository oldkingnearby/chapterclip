import 'package:chapterclip/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores imported books and keeps progress in sync', () async {
    final bookId = await database.bookDao.insertBookWithChaptersAndChunks(
      const BookImportDraft(
        title: 'Demo Book',
        author: 'Ada Writer',
        language: 'en',
        sourceFileName: 'demo.epub',
        chunkTargetChars: 3000,
        chapters: [
          ChapterImportDraft(
            title: 'Intro',
            href: 'intro.xhtml',
            paragraphs: ['Alpha', 'Beta', 'Gamma'],
            chunks: [
              ChunkImportDraft(
                text: 'Alpha\n\nBeta',
                charCount: 11,
                paragraphStartIndex: 0,
                paragraphEndIndex: 1,
              ),
              ChunkImportDraft(
                text: 'Gamma',
                charCount: 5,
                paragraphStartIndex: 2,
                paragraphEndIndex: 2,
              ),
            ],
          ),
        ],
      ),
    );

    final books = await database.bookDao.watchBooks().first;
    expect(books, hasLength(1));
    expect(books.single.title, 'Demo Book');
    expect(books.single.totalParagraphCount, 3);
    expect(books.single.totalChunkCount, 2);

    final chapters = await database.bookDao.watchChaptersByBook(bookId).first;
    expect(chapters, hasLength(1));
    expect(chapters.single.paragraphCount, 3);
    expect(chapters.single.chunkCount, 2);

    final chunks =
        await database.bookDao.watchChunksByChapter(chapters.single.id).first;
    expect(chunks.map((chunk) => chunk.content), ['Alpha\n\nBeta', 'Gamma']);

    final firstChunkParagraphs =
        await database.bookDao.watchParagraphsByChunk(chunks.first.id).first;
    expect(firstChunkParagraphs.map((paragraph) => paragraph.content), [
      'Alpha',
      'Beta',
    ]);

    await database.bookDao.markParagraphRead(
      firstChunkParagraphs.first.id,
      true,
    );
    var progress = await database.bookDao.watchBookProgress(bookId).first;
    expect(progress.readParagraphCount, 1);
    expect(progress.readChunkCount, 0);

    await database.bookDao.markChunkRead(chunks.last.id, true);
    progress = await database.bookDao.watchBookProgress(bookId).first;
    expect(progress.readParagraphCount, 2);
    expect(progress.readChunkCount, 1);

    await database.bookDao.markParagraphRead(
      firstChunkParagraphs.last.id,
      true,
    );
    progress = await database.bookDao.watchBookProgress(bookId).first;
    expect(progress.readParagraphCount, 3);
    expect(progress.readChunkCount, 2);

    final copiedAt = DateTime.utc(2026, 6, 14, 12);
    await database.bookDao.updateChunkCopied(
      chunks.first.id,
      copiedAt: copiedAt,
    );
    final refreshedChunks =
        await database.bookDao.watchChunksByChapter(chapters.single.id).first;
    expect(refreshedChunks.first.copiedCount, 1);
    expect(refreshedChunks.first.lastCopiedAt?.toUtc(), copiedAt);

    await database.bookDao.deleteBookCascade(bookId);
    expect(await database.bookDao.watchBooks().first, isEmpty);
    expect(await database.bookDao.watchChaptersByBook(bookId).first, isEmpty);
  });
}
