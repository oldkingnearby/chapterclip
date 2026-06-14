import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:chapterclip/data/database/app_database.dart';
import 'package:chapterclip/features/import/epub_import_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase database;
  late Directory tempDir;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('chapterclip_import_test');
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('imports an EPUB file into the database', () async {
    final file = File(p.join(tempDir.path, 'demo.epub'));
    await file.writeAsBytes(_minimalEpub());

    final service = EpubImportService(database);
    final metadata = await service.previewMetadata(file.path);
    expect(metadata.title, 'Demo Book');
    expect(metadata.author, 'Ada Writer');

    final progress = <EpubImportStage>[];
    final bookId = await service.importFile(
      filePath: file.path,
      chunkTargetChars: 12,
      onProgress: (value) => progress.add(value.stage),
    );

    expect(progress.first, EpubImportStage.readingFile);
    expect(progress, contains(EpubImportStage.buildingChunks));
    expect(progress.last, EpubImportStage.done);

    final books = await database.bookDao.watchBooks().first;
    expect(books.single.id, bookId);
    expect(books.single.sourceFileName, 'demo.epub');
    expect(books.single.totalParagraphCount, 3);

    final chapters = await database.bookDao.watchChaptersByBook(bookId).first;
    expect(chapters.single.title, 'Opening');

    final chunks =
        await database.bookDao.watchChunksByChapter(chapters.single.id).first;
    expect(chunks, hasLength(greaterThan(1)));
    expect(chunks.first.title, 'Opening - 1');
    expect(chunks.first.content, 'Opening');
  });
}

Uint8List _minimalEpub() {
  final archive = Archive()
    ..addFile(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..addFile(
      ArchiveFile.string('META-INF/container.xml', '''
      <?xml version="1.0"?>
      <container version="1.0"
          xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles>
          <rootfile full-path="OEBPS/content.opf"
              media-type="application/oebps-package+xml"/>
        </rootfiles>
      </container>
    '''),
    )
    ..addFile(
      ArchiveFile.string('OEBPS/content.opf', '''
      <?xml version="1.0" encoding="utf-8"?>
      <package version="3.0" xmlns="http://www.idpf.org/2007/opf"
          unique-identifier="bookid">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>Demo Book</dc:title>
          <dc:creator>Ada Writer</dc:creator>
          <dc:language>en</dc:language>
        </metadata>
        <manifest>
          <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml"
              properties="nav"/>
          <item id="chap1" href="chapter1.xhtml"
              media-type="application/xhtml+xml"/>
        </manifest>
        <spine>
          <itemref idref="chap1"/>
        </spine>
      </package>
    '''),
    )
    ..addFile(
      ArchiveFile.string('OEBPS/nav.xhtml', '''
      <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:epub="http://www.idpf.org/2007/ops">
        <body>
          <nav epub:type="toc">
            <ol><li><a href="chapter1.xhtml">Opening</a></li></ol>
          </nav>
        </body>
      </html>
    '''),
    )
    ..addFile(
      ArchiveFile.string('OEBPS/chapter1.xhtml', '''
      <html xmlns="http://www.w3.org/1999/xhtml">
        <body>
          <h1>Opening</h1>
          <p>Alpha Beta</p>
          <p>Gamma</p>
        </body>
      </html>
    '''),
    );

  return ZipEncoder().encodeBytes(archive);
}
