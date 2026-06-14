import { createId } from './id';
import type { ChapterRecord, ChunkRecord, ParsedChapter } from './types';

export function buildChapterRecord(
  chapter: ParsedChapter,
  targetChars: number
): ChapterRecord {
  const chunks = buildChunks(chapter, Math.max(200, targetChars));
  return {
    id: chapter.id,
    title: chapter.title,
    href: chapter.href,
    paragraphCount: chapter.paragraphs.length,
    chunks
  };
}

function buildChunks(chapter: ParsedChapter, targetChars: number): ChunkRecord[] {
  const chunks: ChunkRecord[] = [];
  let current: string[] = [];
  let startIndex = 0;
  let currentLength = 0;

  const flush = (endIndex: number) => {
    if (!current.length) return;
    const index = chunks.length + 1;
    const content = current.join('\n\n');
    chunks.push({
      id: createId('chunk'),
      chapterId: chapter.id,
      title: `${chapter.title} - ${index}`,
      content,
      charCount: content.length,
      paragraphStartIndex: startIndex,
      paragraphEndIndex: endIndex,
      read: false,
      copiedCount: 0
    });
    current = [];
    currentLength = 0;
  };

  chapter.paragraphs.forEach((paragraph, index) => {
    const paragraphLength = paragraph.length;
    if (current.length && currentLength + paragraphLength > targetChars) {
      flush(index - 1);
      startIndex = index;
    }
    if (!current.length) startIndex = index;
    current.push(paragraph);
    currentLength += paragraphLength;
  });

  flush(chapter.paragraphs.length - 1);

  if (!chunks.length) {
    chunks.push({
      id: createId('chunk'),
      chapterId: chapter.id,
      title: `${chapter.title} - 1`,
      content: '',
      charCount: 0,
      paragraphStartIndex: 0,
      paragraphEndIndex: 0,
      read: false,
      copiedCount: 0
    });
  }

  return chunks;
}
