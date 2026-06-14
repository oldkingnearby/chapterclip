import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../data/database/app_database.dart';
import '../../epub/chunk_builder.dart';
import '../../epub/epub_models.dart';
import '../../epub/epub_parser.dart';

enum EpubImportStage {
  readingFile,
  parsingMetadata,
  parsingChapters,
  buildingChunks,
  saving,
  done,
}

class EpubImportProgress {
  final EpubImportStage stage;
  final String message;
  final double? fraction;

  const EpubImportProgress({
    required this.stage,
    required this.message,
    this.fraction,
  });
}

typedef EpubImportProgressCallback = void Function(EpubImportProgress progress);

class EpubImportService {
  final AppDatabase database;

  const EpubImportService(this.database);

  Future<EpubMetadata> previewMetadata(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return EpubParser.parseMetadata(bytes);
  }

  Future<int> importFile({
    required String filePath,
    required int chunkTargetChars,
    EpubImportProgressCallback? onProgress,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    return importBytes(
      bytes: bytes,
      sourceFileName: p.basename(filePath),
      sourceFilePath: filePath,
      chunkTargetChars: chunkTargetChars,
      onProgress: onProgress,
    );
  }

  Future<int> importBytes({
    required Uint8List bytes,
    required String sourceFileName,
    String? sourceFilePath,
    required int chunkTargetChars,
    EpubImportProgressCallback? onProgress,
  }) async {
    if (chunkTargetChars <= 0) {
      throw ArgumentError.value(
        chunkTargetChars,
        'chunkTargetChars',
        'must be greater than zero',
      );
    }

    onProgress?.call(
      const EpubImportProgress(
        stage: EpubImportStage.readingFile,
        message: 'Reading EPUB file',
        fraction: 0,
      ),
    );

    onProgress?.call(
      const EpubImportProgress(
        stage: EpubImportStage.parsingChapters,
        message: 'Parsing EPUB chapters',
        fraction: 0.2,
      ),
    );
    final parsedBook = EpubParser.parseBook(bytes);

    final chapters = <ChapterImportDraft>[];
    for (var i = 0; i < parsedBook.chapters.length; i++) {
      final parsedChapter = parsedBook.chapters[i];
      onProgress?.call(
        EpubImportProgress(
          stage: EpubImportStage.buildingChunks,
          message: 'Building chunks ${i + 1}/${parsedBook.chapters.length}',
          fraction: 0.2 + (0.6 * (i + 1) / parsedBook.chapters.length),
        ),
      );

      final builtChunks = ChunkBuilder.build(
        paragraphs: parsedChapter.paragraphs,
        targetChars: chunkTargetChars,
      );

      chapters.add(
        ChapterImportDraft(
          title: parsedChapter.title,
          href: parsedChapter.href,
          paragraphs: parsedChapter.paragraphs,
          chunks: [
            for (var chunkIndex = 0;
                chunkIndex < builtChunks.length;
                chunkIndex++)
              _toChunkDraft(parsedChapter, builtChunks[chunkIndex], chunkIndex),
          ],
        ),
      );
    }

    onProgress?.call(
      const EpubImportProgress(
        stage: EpubImportStage.saving,
        message: 'Saving imported book',
        fraction: 0.9,
      ),
    );
    final bookId = await database.bookDao.insertBookWithChaptersAndChunks(
      BookImportDraft(
        title: parsedBook.title,
        author: parsedBook.author,
        language: parsedBook.language,
        sourceFileName: sourceFileName,
        sourceFilePath: sourceFilePath,
        chunkTargetChars: chunkTargetChars,
        chapters: chapters,
      ),
    );

    onProgress?.call(
      const EpubImportProgress(
        stage: EpubImportStage.done,
        message: 'Import complete',
        fraction: 1,
      ),
    );
    return bookId;
  }

  static ChunkImportDraft _toChunkDraft(
    ParsedChapter chapter,
    BuiltChunk chunk,
    int chunkIndex,
  ) {
    return ChunkImportDraft(
      title: '${chapter.title} - ${chunkIndex + 1}',
      text: chunk.text,
      charCount: chunk.charCount,
      paragraphStartIndex: chunk.paragraphStartIndex,
      paragraphEndIndex: chunk.paragraphEndIndex,
    );
  }
}
