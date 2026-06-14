import Dexie, { type Table } from 'dexie';
import type { BookRecord, BookSummary, ChunkRecord } from './types';

class ChapterClipDatabase extends Dexie {
  books!: Table<BookRecord, string>;

  constructor() {
    super('chapterclip-web');
    this.version(1).stores({
      books: 'id, importedAt, updatedAt, title, sourceFileName'
    });
  }
}

export const db = new ChapterClipDatabase();

export async function listBooks(): Promise<BookSummary[]> {
  const books = await db.books.orderBy('importedAt').reverse().toArray();
  return books.map(toSummary);
}

export async function getBook(id: string): Promise<BookRecord | undefined> {
  return db.books.get(id);
}

export async function saveBook(book: BookRecord): Promise<void> {
  book.updatedAt = new Date().toISOString();
  await db.books.put(book);
}

export async function deleteBook(id: string): Promise<void> {
  await db.books.delete(id);
}

export async function clearLibrary(): Promise<void> {
  await db.books.clear();
}

export async function exportLibrary(): Promise<BookRecord[]> {
  return db.books.orderBy('importedAt').toArray();
}

export async function importLibraryBackup(books: BookRecord[]): Promise<void> {
  await db.transaction('rw', db.books, async () => {
    await db.books.bulkPut(books);
  });
}

export function getAllChunks(book: BookRecord): ChunkRecord[] {
  return book.chapters.flatMap((chapter) => chapter.chunks);
}

export function toSummary(book: BookRecord): BookSummary {
  const chunks = getAllChunks(book);
  return {
    id: book.id,
    title: book.title,
    author: book.author,
    sourceFileName: book.sourceFileName,
    importedAt: book.importedAt,
    totalParagraphCount: book.totalParagraphCount,
    totalChunkCount: book.totalChunkCount,
    readChunkCount: chunks.filter((chunk) => chunk.read).length
  };
}
