import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:chapterclip/epub/chunk_builder.dart';
import 'package:chapterclip/epub/epub_parser.dart';
import 'package:chapterclip/epub/html_text_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlTextExtractor', () {
    test('extracts readable paragraph-like blocks and skips navigation', () {
      final paragraphs = HtmlTextExtractor.extract('''
        <html>
          <body>
            <nav><p>Table of contents</p></nav>
            <h1>Chapter One</h1>
            <p> First   paragraph<br/>with spacing. </p>
            <blockquote>Quoted text</blockquote>
            <ul><li>First point</li><li>Second point</li></ul>
            <script>bad()</script>
          </body>
        </html>
      ''');

      expect(paragraphs, [
        'Chapter One',
        'First paragraph with spacing.',
        'Quoted text',
        '- First point',
        '- Second point',
      ]);
    });
  });

  group('ChunkBuilder', () {
    test('splits on paragraph boundaries and keeps long paragraphs whole', () {
      final chunks = ChunkBuilder.build(
        paragraphs: ['aaaa', 'bbbb', 'cccccccccc', 'dd'],
        targetChars: 8,
      );

      expect(chunks, hasLength(3));
      expect(chunks[0].text, 'aaaa\n\nbbbb');
      expect(chunks[0].paragraphStartIndex, 0);
      expect(chunks[0].paragraphEndIndex, 1);
      expect(chunks[1].text, 'cccccccccc');
      expect(chunks[1].charCount, 10);
      expect(chunks[2].text, 'dd');
    });
  });

  group('EpubParser', () {
    test(
      'parses metadata, nav titles, spine order, and chapter paragraphs',
      () {
        final book = EpubParser.parseBook(_minimalEpub());

        expect(book.title, 'Demo Book');
        expect(book.author, 'Ada Writer');
        expect(book.language, 'en');
        expect(book.chapters, hasLength(2));
        expect(book.chapters[0].title, 'Opening');
        expect(book.chapters[0].href, 'OEBPS/chapter1.xhtml');
        expect(book.chapters[0].paragraphs, ['Opening', 'Hello world.']);
        expect(book.chapters[1].title, 'Next');
        expect(book.chapters[1].paragraphs, ['Second chapter.']);
      },
    );
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
          <item id="chap2" href="chapter2.xhtml"
              media-type="application/xhtml+xml"/>
        </manifest>
        <spine>
          <itemref idref="chap1"/>
          <itemref idref="chap2"/>
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
            <ol>
              <li><a href="chapter1.xhtml">Opening</a></li>
              <li><a href="chapter2.xhtml">Next</a></li>
            </ol>
          </nav>
        </body>
      </html>
    '''),
    )
    ..addFile(
      ArchiveFile.string('OEBPS/chapter1.xhtml', '''
      <html xmlns="http://www.w3.org/1999/xhtml">
        <body><h1>Opening</h1><p>Hello world.</p></body>
      </html>
    '''),
    )
    ..addFile(
      ArchiveFile.string('OEBPS/chapter2.xhtml', '''
      <html xmlns="http://www.w3.org/1999/xhtml">
        <body><p>Second chapter.</p></body>
      </html>
    '''),
    );

  return ZipEncoder().encodeBytes(archive);
}
