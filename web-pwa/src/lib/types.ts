export type ImportStage =
  | 'reading'
  | 'parsing'
  | 'building'
  | 'saving'
  | 'done';

export interface ImportProgress {
  stage: ImportStage;
  message: string;
}

export interface ParsedChapter {
  id: string;
  title: string;
  href: string;
  paragraphs: string[];
}

export interface ParsedBook {
  title: string;
  author: string;
  language: string;
  chapters: ParsedChapter[];
}

export interface ChunkRecord {
  id: string;
  chapterId: string;
  title: string;
  content: string;
  charCount: number;
  paragraphStartIndex: number;
  paragraphEndIndex: number;
  read: boolean;
  copiedCount: number;
  lastCopiedAt?: string;
}

export interface ChapterRecord {
  id: string;
  title: string;
  href: string;
  paragraphCount: number;
  chunks: ChunkRecord[];
}

export interface BookRecord {
  id: string;
  title: string;
  author: string;
  language: string;
  sourceFileName: string;
  importedAt: string;
  updatedAt: string;
  chunkTargetChars: number;
  totalParagraphCount: number;
  totalChunkCount: number;
  chapters: ChapterRecord[];
}

export interface BookSummary {
  id: string;
  title: string;
  author: string;
  sourceFileName: string;
  importedAt: string;
  totalParagraphCount: number;
  totalChunkCount: number;
  readChunkCount: number;
}
