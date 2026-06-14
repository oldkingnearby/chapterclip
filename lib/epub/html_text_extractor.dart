import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

/// Extracts a flat list of paragraph strings from EPUB chapter XHTML.
///
/// Keeps `h1-h4`, `p`, `blockquote` and `li` as individual paragraphs (list
/// items get a leading `- `), skips `script`/`style`/`nav`, and collapses
/// whitespace within each paragraph.
class HtmlTextExtractor {
  static const _paragraphTags = {
    'h1',
    'h2',
    'h3',
    'h4',
    'p',
    'blockquote',
    'li',
  };
  static const _skipTags = {'script', 'style', 'nav'};

  static List<String> extract(String htmlString) {
    final document = parse(
      htmlString.replaceAll(RegExp(r'<br\b[^>]*>', caseSensitive: false), ' '),
    );
    final root = document.body ?? document.documentElement;
    if (root == null) return [];

    final paragraphs = <String>[];
    _walk(root, paragraphs);
    return paragraphs;
  }

  static void _walk(dom.Node node, List<String> out) {
    if (node is! dom.Element) return;

    final tag = node.localName?.toLowerCase() ?? '';
    if (_skipTags.contains(tag)) return;

    if (_paragraphTags.contains(tag)) {
      final text = _cleanText(node.text);
      if (text.isNotEmpty) {
        out.add(tag == 'li' ? '- $text' : text);
      }
      return;
    }

    for (final child in node.nodes) {
      _walk(child, out);
    }
  }

  static String _cleanText(String raw) {
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
