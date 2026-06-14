/// A chapter parsed from an EPUB's spine, with its extracted paragraphs.
class ParsedChapter {
  final String title;
  final String href;
  final List<String> paragraphs;

  const ParsedChapter({
    required this.title,
    required this.href,
    required this.paragraphs,
  });
}

/// A fully parsed EPUB book: metadata plus ordered chapters.
class ParsedBook {
  final String title;
  final String? author;
  final String? language;
  final List<ParsedChapter> chapters;

  const ParsedBook({
    required this.title,
    this.author,
    this.language,
    required this.chapters,
  });
}

/// Lightweight metadata-only parse result, used for the import preview.
class EpubMetadata {
  final String title;
  final String? author;
  final String? language;

  const EpubMetadata({required this.title, this.author, this.language});
}
