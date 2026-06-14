import 'package:characters/characters.dart';

/// A chunk of paragraphs whose combined text is close to (but, for a single
/// over-long paragraph, may exceed) the requested target character count.
class BuiltChunk {
  final String text;
  final int charCount;
  final int paragraphStartIndex;
  final int paragraphEndIndex;

  const BuiltChunk({
    required this.text,
    required this.charCount,
    required this.paragraphStartIndex,
    required this.paragraphEndIndex,
  });
}

/// Splits a chapter's paragraphs into chunks close to [targetChars]
/// characters without ever splitting a paragraph (spec section 6.2).
class ChunkBuilder {
  static List<BuiltChunk> build({
    required List<String> paragraphs,
    required int targetChars,
  }) {
    final chunks = <BuiltChunk>[];
    final current = <String>[];
    var currentChars = 0;
    var startIndex = 0;

    for (var i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;

      final paragraphChars = paragraph.characters.length;
      final nextChars = currentChars + paragraphChars;

      if (current.isNotEmpty && nextChars > targetChars) {
        chunks.add(_buildChunk(current, startIndex, i - 1));
        current.clear();
        currentChars = 0;
        startIndex = i;
      }

      current.add(paragraph);
      currentChars += paragraphChars;
    }

    if (current.isNotEmpty) {
      chunks.add(_buildChunk(current, startIndex, paragraphs.length - 1));
    }

    return chunks;
  }

  static BuiltChunk _buildChunk(
    List<String> paragraphs,
    int startIndex,
    int endIndex,
  ) {
    final text = paragraphs.join('\n\n');
    return BuiltChunk(
      text: text,
      charCount: text.characters.length,
      paragraphStartIndex: startIndex,
      paragraphEndIndex: endIndex,
    );
  }
}
