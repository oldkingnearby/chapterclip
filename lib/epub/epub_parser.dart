import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import 'epub_models.dart';
import 'html_text_extractor.dart';

/// Thrown when an EPUB cannot be parsed (corrupt zip, missing OPF, no
/// readable chapters, etc). The [message] is suitable for display to users.
class EpubParseException implements Exception {
  final String message;

  EpubParseException(this.message);

  @override
  String toString() => message;
}

class _ManifestItem {
  final String id;
  final String path;
  final String mediaType;
  final String properties;

  const _ManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });
}

/// Parses EPUB (zip) byte content into [ParsedBook] / [EpubMetadata].
///
/// Flow: unzip -> META-INF/container.xml -> OPF (metadata, manifest, spine)
/// -> nav.xhtml or toc.ncx for chapter titles -> per spine item, extract
/// paragraphs via [HtmlTextExtractor].
class EpubParser {
  /// Quick parse of just title/author/language from the OPF metadata.
  static EpubMetadata parseMetadata(Uint8List bytes) {
    final archive = _decodeArchive(bytes);
    final opfPath = _findOpfPath(archive);
    final opfDoc = _readXml(archive, opfPath);
    return _parseMetadataFromOpf(opfDoc);
  }

  /// Full parse: metadata + chapters with extracted paragraphs.
  static ParsedBook parseBook(Uint8List bytes) {
    final archive = _decodeArchive(bytes);
    final opfPath = _findOpfPath(archive);
    final opfDir = p.posix.dirname(opfPath);
    final opfDoc = _readXml(archive, opfPath);

    final metadata = _parseMetadataFromOpf(opfDoc);

    final manifest = <String, _ManifestItem>{};
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id == null || href == null) continue;
      manifest[id] = _ManifestItem(
        id: id,
        path: _resolvePath(opfDir, href),
        mediaType: (item.getAttribute('media-type') ?? '').toLowerCase(),
        properties: item.getAttribute('properties') ?? '',
      );
    }

    final spineEl = opfDoc.findAllElements('spine').firstOrNull;
    final spineItems = <_ManifestItem>[];
    if (spineEl != null) {
      for (final itemref in spineEl.findElements('itemref')) {
        final idref = itemref.getAttribute('idref');
        final item = idref != null ? manifest[idref] : null;
        if (item != null) spineItems.add(item);
      }
    }
    if (spineItems.isEmpty) {
      spineItems.addAll(
        manifest.values.where(
          (m) => _isHtmlMedia(m.mediaType) || _looksLikeHtmlPath(m.path),
        ),
      );
    }

    final tocMap = _buildTocMap(archive, opfDoc, manifest, opfDir);

    final chapters = <ParsedChapter>[];
    for (final item in spineItems) {
      if (!_isHtmlMedia(item.mediaType) && !_looksLikeHtmlPath(item.path)) {
        continue;
      }
      final file = _findFile(archive, item.path);
      if (file == null) continue;

      final html = _decodeText(_readArchiveBytes(file));
      final paragraphs = HtmlTextExtractor.extract(html);
      if (paragraphs.isEmpty) continue;

      final title = tocMap[item.path] ??
          _firstHeading(html) ??
          p.basenameWithoutExtension(item.path);

      chapters.add(
        ParsedChapter(title: title, href: item.path, paragraphs: paragraphs),
      );
    }

    if (chapters.isEmpty) {
      throw EpubParseException('未在 EPUB 中找到可解析的章节内容');
    }

    return ParsedBook(
      title: metadata.title,
      author: metadata.author,
      language: metadata.language,
      chapters: chapters,
    );
  }

  static Archive _decodeArchive(Uint8List bytes) {
    try {
      return ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw EpubParseException('无法解压 EPUB 文件：$e');
    }
  }

  static String _findOpfPath(Archive archive) {
    final containerFile = _findFile(archive, 'META-INF/container.xml');
    if (containerFile == null) {
      throw EpubParseException('缺少 META-INF/container.xml');
    }
    final doc = XmlDocument.parse(
      _decodeText(_readArchiveBytes(containerFile)),
    );
    final rootfile = doc.findAllElements('rootfile').firstOrNull;
    final fullPath = rootfile?.getAttribute('full-path');
    if (fullPath == null || fullPath.isEmpty) {
      throw EpubParseException('container.xml 中未找到 OPF 文件路径');
    }
    return _normalize(fullPath);
  }

  static XmlDocument _readXml(Archive archive, String path) {
    final file = _findFile(archive, path);
    if (file == null) {
      throw EpubParseException('未找到文件：$path');
    }
    try {
      return XmlDocument.parse(_decodeText(_readArchiveBytes(file)));
    } catch (e) {
      throw EpubParseException('解析 $path 失败：$e');
    }
  }

  static Uint8List _readArchiveBytes(ArchiveFile file) {
    return file.content;
  }

  static EpubMetadata _parseMetadataFromOpf(XmlDocument opfDoc) {
    final metadataEl = _allElements(opfDoc, 'metadata').firstOrNull;

    String? title;
    String? author;
    String? language;

    if (metadataEl != null) {
      final titleEl = _childElements(metadataEl, 'title').firstOrNull;
      title = titleEl?.innerText.trim();

      final creators = _childElements(metadataEl, 'creator')
          .map((e) => e.innerText.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (creators.isNotEmpty) author = creators.join(', ');

      final languageEl = _childElements(metadataEl, 'language').firstOrNull;
      language = languageEl?.innerText.trim();
    }

    return EpubMetadata(
      title: (title == null || title.isEmpty) ? 'Untitled' : title,
      author: (author == null || author.isEmpty) ? null : author,
      language: (language == null || language.isEmpty) ? null : language,
    );
  }

  /// Builds a map from chapter file path (no fragment) to chapter title,
  /// preferring the EPUB3 nav document and falling back to toc.ncx.
  static Map<String, String> _buildTocMap(
    Archive archive,
    XmlDocument opfDoc,
    Map<String, _ManifestItem> manifest,
    String opfDir,
  ) {
    final navItem = manifest.values.firstWhereOrNull(
      (m) => m.properties.split(RegExp(r'\s+')).contains('nav'),
    );
    if (navItem != null) {
      final file = _findFile(archive, navItem.path);
      if (file != null) {
        final html = _decodeText(_readArchiveBytes(file));
        final navDir = p.posix.dirname(navItem.path);
        final map = _parseNavXhtml(html, navDir);
        if (map.isNotEmpty) return map;
      }
    }

    final spineEl = opfDoc.findAllElements('spine').firstOrNull;
    final tocId = spineEl?.getAttribute('toc');
    final ncxItem = (tocId != null ? manifest[tocId] : null) ??
        manifest.values.firstWhereOrNull(
          (m) => m.mediaType == 'application/x-dtbncx+xml',
        );
    if (ncxItem != null) {
      final file = _findFile(archive, ncxItem.path);
      if (file != null) {
        try {
          final doc = XmlDocument.parse(
            _decodeText(_readArchiveBytes(file)),
          );
          final ncxDir = p.posix.dirname(ncxItem.path);
          return _parseNcx(doc, ncxDir);
        } catch (_) {
          // fall through to empty map
        }
      }
    }

    return {};
  }

  static Map<String, String> _parseNavXhtml(String htmlString, String navDir) {
    final document = html_parser.parse(htmlString);
    final navs = document.querySelectorAll('nav');
    if (navs.isEmpty) return {};

    dom.Element? tocNav;
    for (final nav in navs) {
      final type = nav.attributes.entries
          .firstWhereOrNull(
            (e) => e.key.toString().toLowerCase() == 'epub:type',
          )
          ?.value;
      if (type != null && type.toLowerCase().contains('toc')) {
        tocNav = nav;
        break;
      }
    }
    final selectedNav = tocNav ?? navs.first;

    final map = <String, String>{};
    for (final a in selectedNav.querySelectorAll('a')) {
      final href = a.attributes['href'];
      final text = a.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (href == null || href.isEmpty || text.isEmpty) continue;
      final path = _resolvePath(navDir, href);
      map.putIfAbsent(path, () => text);
    }
    return map;
  }

  static Map<String, String> _parseNcx(XmlDocument doc, String ncxDir) {
    final map = <String, String>{};
    final navMap = _allElements(doc, 'navMap').firstOrNull;
    if (navMap == null) return map;

    void visit(XmlElement el) {
      for (final navPoint in _childElements(el, 'navPoint')) {
        final labelEl = _childElements(navPoint, 'navLabel').firstOrNull;
        final label = labelEl == null
            ? null
            : _childElements(labelEl, 'text').firstOrNull?.innerText.trim();
        final src = _childElements(
          navPoint,
          'content',
        ).firstOrNull?.getAttribute('src');
        if (label != null &&
            label.isNotEmpty &&
            src != null &&
            src.isNotEmpty) {
          final path = _resolvePath(ncxDir, src);
          map.putIfAbsent(path, () => label);
        }
        visit(navPoint);
      }
    }

    visit(navMap);
    return map;
  }

  static Iterable<XmlElement> _allElements(XmlNode node, String localName) {
    return node.descendants
        .whereType<XmlElement>()
        .where((element) => element.localName == localName);
  }

  static Iterable<XmlElement> _childElements(
    XmlElement node,
    String localName,
  ) {
    return node.childElements
        .where((element) => element.localName == localName);
  }

  static String? _firstHeading(String htmlString) {
    final document = html_parser.parse(htmlString);
    for (final tag in const ['h1', 'h2', 'h3']) {
      final text = document
          .querySelector(tag)
          ?.text
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static bool _isHtmlMedia(String mediaType) {
    return mediaType == 'application/xhtml+xml' || mediaType == 'text/html';
  }

  static bool _looksLikeHtmlPath(String path) {
    final ext = p.posix.extension(path).toLowerCase();
    return ext == '.xhtml' || ext == '.html' || ext == '.htm';
  }

  static ArchiveFile? _findFile(Archive archive, String path) {
    final normalized = _normalize(path);
    final direct = archive.findFile(normalized);
    if (direct != null) return direct;

    final lower = normalized.toLowerCase();
    for (final f in archive.files) {
      if (_normalize(f.name).toLowerCase() == lower) return f;
    }
    return null;
  }

  static String _normalize(String path) {
    var value = path.replaceAll('\\', '/');
    while (value.startsWith('/')) {
      value = value.substring(1);
    }
    return p.posix.normalize(value);
  }

  /// Resolves [href] (possibly with a `#fragment`, percent-encoding, or
  /// `..` segments) against [baseDir], returning an archive-relative path.
  static String _resolvePath(String baseDir, String href) {
    var value = href;
    final hashIndex = value.indexOf('#');
    if (hashIndex >= 0) value = value.substring(0, hashIndex);

    try {
      value = Uri.decodeComponent(value);
    } catch (_) {
      // leave as-is if not validly percent-encoded
    }
    value = value.replaceAll('\\', '/');

    if (value.startsWith('/')) {
      return _normalize(value);
    }

    final base = (baseDir.isEmpty || baseDir == '.') ? '' : baseDir;
    final joined = base.isEmpty ? value : '$base/$value';
    return _normalize(joined);
  }

  static String _decodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }
}
