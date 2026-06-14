import { strFromU8, unzipSync } from 'fflate';
import { createId } from './id';
import type { ParsedBook, ParsedChapter } from './types';

interface ManifestItem {
  id: string;
  href: string;
  mediaType: string;
  properties: string;
}

export async function parseEpubFile(file: File): Promise<ParsedBook> {
  const bytes = new Uint8Array(await file.arrayBuffer());
  const zip = unzipSync(bytes);
  const fileIndex = indexZipFiles(zip);

  const container = parseXml(readText(fileIndex, 'META-INF/container.xml'));
  const rootfile = firstByLocalName(container, 'rootfile');
  const opfPath = rootfile?.getAttribute('full-path');
  if (!opfPath) {
    throw new Error('EPUB container.xml does not point to an OPF package.');
  }

  const opfDir = directoryName(opfPath);
  const opf = parseXml(readText(fileIndex, opfPath));
  const manifest = parseManifest(opf, opfDir);
  const spineIds = allByLocalName(opf, 'itemref')
    .map((item) => item.getAttribute('idref') ?? '')
    .filter(Boolean);

  const navTitles = readNavTitles(fileIndex, manifest);
  const chapters: ParsedChapter[] = [];

  spineIds.forEach((idref, index) => {
    const item = manifest.get(idref);
    if (!item || !isHtmlLike(item.mediaType)) return;

    const markup = readText(fileIndex, item.href);
    const document = parseHtml(markup);
    const paragraphs = extractParagraphs(document);
    const title =
      navTitles.get(item.href) ||
      firstHeading(document) ||
      `Chapter ${index + 1}`;

    chapters.push({
      id: createId('chapter'),
      title,
      href: item.href,
      paragraphs
    });
  });

  if (!chapters.length) {
    throw new Error('No readable XHTML chapters were found in this EPUB.');
  }

  return {
    title: readMetadata(opf, 'title') || file.name.replace(/\.epub$/i, ''),
    author: readMetadata(opf, 'creator'),
    language: readMetadata(opf, 'language'),
    chapters
  };
}

function indexZipFiles(files: Record<string, Uint8Array>): Map<string, Uint8Array> {
  const index = new Map<string, Uint8Array>();
  Object.entries(files).forEach(([path, bytes]) => {
    index.set(normalizePath(path), bytes);
  });
  return index;
}

function readText(files: Map<string, Uint8Array>, path: string): string {
  const normalized = normalizePath(path);
  const file = files.get(normalized);
  if (!file) throw new Error(`EPUB file not found: ${path}`);
  return stripBom(strFromU8(file));
}

function parseXml(source: string): Document {
  const document = new DOMParser().parseFromString(source, 'application/xml');
  if (document.getElementsByTagName('parsererror').length) {
    throw new Error('Failed to parse EPUB XML.');
  }
  return document;
}

function parseHtml(source: string): Document {
  return new DOMParser().parseFromString(source, 'text/html');
}

function parseManifest(opf: Document, opfDir: string): Map<string, ManifestItem> {
  const manifest = new Map<string, ManifestItem>();
  allByLocalName(opf, 'item').forEach((item) => {
    const id = item.getAttribute('id') ?? '';
    const href = item.getAttribute('href') ?? '';
    if (!id || !href) return;
    manifest.set(id, {
      id,
      href: resolvePath(opfDir, href),
      mediaType: item.getAttribute('media-type') ?? '',
      properties: item.getAttribute('properties') ?? ''
    });
  });
  return manifest;
}

function readNavTitles(
  files: Map<string, Uint8Array>,
  manifest: Map<string, ManifestItem>
): Map<string, string> {
  const titles = new Map<string, string>();
  const nav = [...manifest.values()].find((item) =>
    item.properties.split(/\s+/).includes('nav')
  );
  if (!nav) return titles;

  try {
    const navDocument = parseHtml(readText(files, nav.href));
    const navDir = directoryName(nav.href);
    navDocument.querySelectorAll('a[href]').forEach((anchor) => {
      const href = anchor.getAttribute('href');
      const title = normalizeText(anchor.textContent ?? '');
      if (!href || !title) return;
      titles.set(resolvePath(navDir, href), title);
    });
  } catch {
    return titles;
  }

  return titles;
}

function extractParagraphs(document: Document): string[] {
  document
    .querySelectorAll('script, style, nav, header, footer, aside, noscript')
    .forEach((element) => element.remove());

  const blockSelector = 'h1,h2,h3,h4,h5,h6,p,blockquote,li,pre';
  const blocks = [...document.body.querySelectorAll(blockSelector)].filter(
    (element) => !element.parentElement?.closest(blockSelector)
  );

  const paragraphs = blocks
    .map((element) => {
      const text = normalizeText(element.textContent ?? '');
      if (!text) return '';
      return element.localName.toLowerCase() === 'li' ? `- ${text}` : text;
    })
    .filter(Boolean);

  if (paragraphs.length) return uniqueAdjacent(paragraphs);

  const fallback = normalizeText(document.body.textContent ?? '');
  return fallback ? [fallback] : [];
}

function firstHeading(document: Document): string {
  const heading = document.querySelector('h1,h2,h3,h4,h5,h6');
  return normalizeText(heading?.textContent ?? '');
}

function readMetadata(opf: Document, name: string): string {
  const node = allByLocalName(opf, name).find((element) =>
    hasAncestorLocalName(element, 'metadata')
  );
  return normalizeText(node?.textContent ?? '');
}

function hasAncestorLocalName(element: Element, name: string): boolean {
  let parent = element.parentElement;
  while (parent) {
    if (parent.localName.toLowerCase() === name.toLowerCase()) return true;
    parent = parent.parentElement;
  }
  return false;
}

function allByLocalName(root: ParentNode, name: string): Element[] {
  return [...root.querySelectorAll('*')].filter(
    (element) => element.localName.toLowerCase() === name.toLowerCase()
  );
}

function firstByLocalName(root: ParentNode, name: string): Element | undefined {
  return allByLocalName(root, name)[0];
}

function isHtmlLike(mediaType: string): boolean {
  return /x?html/i.test(mediaType);
}

function directoryName(path: string): string {
  const normalized = normalizePath(path);
  const index = normalized.lastIndexOf('/');
  return index >= 0 ? normalized.slice(0, index) : '';
}

function resolvePath(baseDir: string, href: string): string {
  const withoutFragment = href.split('#')[0];
  const joined = baseDir ? `${baseDir}/${withoutFragment}` : withoutFragment;
  return normalizePath(joined);
}

function normalizePath(path: string): string {
  const parts: string[] = [];
  path
    .replace(/\\/g, '/')
    .split('/')
    .forEach((part) => {
      if (!part || part === '.') return;
      if (part === '..') {
        parts.pop();
        return;
      }
      parts.push(decodeURIComponentSafe(part));
    });
  return parts.join('/');
}

function decodeURIComponentSafe(value: string): string {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

function normalizeText(value: string): string {
  return value.replace(/\s+/g, ' ').trim();
}

function stripBom(value: string): string {
  return value.replace(/^\uFEFF/, '');
}

function uniqueAdjacent(values: string[]): string[] {
  const result: string[] = [];
  values.forEach((value) => {
    if (result[result.length - 1] !== value) result.push(value);
  });
  return result;
}
