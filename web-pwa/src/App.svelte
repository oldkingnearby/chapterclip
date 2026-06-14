<script lang="ts">
  import { onMount } from 'svelte';
  import { buildChapterRecord } from './lib/chunk';
  import {
    deleteBook,
    exportLibrary,
    getAllChunks,
    getBook,
    importLibraryBackup,
    listBooks,
    saveBook
  } from './lib/db';
  import { parseEpubFile } from './lib/epub';
  import { createId } from './lib/id';
  import type {
    BookRecord,
    BookSummary,
    ChunkRecord,
    ImportProgress
  } from './lib/types';

  let books: BookSummary[] = [];
  let selectedBook: BookRecord | null = null;
  let activeChunkIndex = 0;
  let chunkTargetChars = 3000;
  let progress: ImportProgress | null = null;
  let notice = '';
  let busy = false;
  let fileInput: HTMLInputElement;
  let backupInput: HTMLInputElement;

  $: chunks = selectedBook ? getAllChunks(selectedBook) : [];
  $: activeChunk = chunks[activeChunkIndex];
  $: selectedProgress = selectedBook ? progressFor(selectedBook) : null;

  onMount(() => {
    refreshBooks();
  });

  async function refreshBooks() {
    books = await listBooks();
  }

  function chooseEpub() {
    fileInput.click();
  }

  function chooseBackup() {
    backupInput.click();
  }

  async function handleEpubSelected(event: Event) {
    const input = event.currentTarget as HTMLInputElement;
    const file = input.files?.[0];
    input.value = '';
    if (!file) return;

    busy = true;
    try {
      progress = { stage: 'reading', message: 'Reading EPUB' };
      const parsed = await parseEpubFile(file);

      progress = { stage: 'building', message: 'Building chunks' };
      const chapters = parsed.chapters.map((chapter) =>
        buildChapterRecord(chapter, chunkTargetChars)
      );
      const totalParagraphCount = chapters.reduce(
        (sum, chapter) => sum + chapter.paragraphCount,
        0
      );
      const totalChunkCount = chapters.reduce(
        (sum, chapter) => sum + chapter.chunks.length,
        0
      );
      const now = new Date().toISOString();
      const book: BookRecord = {
        id: createId('book'),
        title: parsed.title,
        author: parsed.author,
        language: parsed.language,
        sourceFileName: file.name,
        importedAt: now,
        updatedAt: now,
        chunkTargetChars,
        totalParagraphCount,
        totalChunkCount,
        chapters
      };

      progress = { stage: 'saving', message: 'Saving book' };
      await saveBook(book);
      selectedBook = book;
      activeChunkIndex = 0;
      await refreshBooks();
      progress = { stage: 'done', message: 'Imported' };
      showNotice('Imported');
    } catch (error) {
      showNotice(error instanceof Error ? error.message : 'Import failed');
    } finally {
      busy = false;
      setTimeout(() => {
        progress = null;
      }, 900);
    }
  }

  async function openBook(id: string) {
    const book = await getBook(id);
    if (!book) {
      showNotice('Book not found');
      await refreshBooks();
      return;
    }
    selectedBook = book;
    activeChunkIndex = Math.max(0, chunks.findIndex((chunk) => !chunk.read));
    if (activeChunkIndex < 0) activeChunkIndex = 0;
  }

  function closeBook() {
    selectedBook = null;
    activeChunkIndex = 0;
  }

  function openChunk(chunk: ChunkRecord) {
    const index = chunks.findIndex((item) => item.id === chunk.id);
    if (index >= 0) activeChunkIndex = index;
  }

  async function removeBook(book: BookSummary) {
    if (!confirm(`Delete "${book.title}"?`)) return;
    await deleteBook(book.id);
    if (selectedBook?.id === book.id) closeBook();
    await refreshBooks();
    showNotice('Deleted');
  }

  async function markActiveChunk(read: boolean) {
    if (!selectedBook || !activeChunk) return;
    activeChunk.read = read;
    await saveBook(selectedBook);
    await refreshBooks();
  }

  async function copyActiveChunk() {
    if (!selectedBook || !activeChunk) return;
    await copyText(activeChunk.content);
    activeChunk.copiedCount += 1;
    activeChunk.lastCopiedAt = new Date().toISOString();
    await saveBook(selectedBook);
    await refreshBooks();
    showNotice('Copied');
  }

  async function exportBackup() {
    const payload = {
      version: 1,
      exportedAt: new Date().toISOString(),
      books: await exportLibrary()
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], {
      type: 'application/json'
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `chapterclip-backup-${new Date()
      .toISOString()
      .slice(0, 10)}.json`;
    link.click();
    URL.revokeObjectURL(url);
  }

  async function handleBackupSelected(event: Event) {
    const input = event.currentTarget as HTMLInputElement;
    const file = input.files?.[0];
    input.value = '';
    if (!file) return;

    try {
      const raw = JSON.parse(await file.text());
      const booksToImport: BookRecord[] = Array.isArray(raw)
        ? raw
        : Array.isArray(raw.books)
          ? raw.books
          : [];
      if (!booksToImport.length) throw new Error('Backup is empty');
      await importLibraryBackup(booksToImport);
      await refreshBooks();
      showNotice('Backup imported');
    } catch (error) {
      showNotice(error instanceof Error ? error.message : 'Import failed');
    }
  }

  function nextChunk() {
    activeChunkIndex = Math.min(chunks.length - 1, activeChunkIndex + 1);
  }

  function previousChunk() {
    activeChunkIndex = Math.max(0, activeChunkIndex - 1);
  }

  async function copyText(text: string) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);
      return;
    }
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    textarea.remove();
  }

  function progressFor(book: BookRecord) {
    const bookChunks = getAllChunks(book);
    const read = bookChunks.filter((chunk) => chunk.read).length;
    return {
      read,
      total: bookChunks.length,
      percent: bookChunks.length ? Math.round((read / bookChunks.length) * 100) : 0
    };
  }

  function summaryPercent(book: BookSummary) {
    return book.totalChunkCount
      ? Math.round((book.readChunkCount / book.totalChunkCount) * 100)
      : 0;
  }

  function formatDate(value: string) {
    return new Intl.DateTimeFormat(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(new Date(value));
  }

  function showNotice(message: string) {
    notice = message;
    setTimeout(() => {
      if (notice === message) notice = '';
    }, 2200);
  }
</script>

<main class:reading={Boolean(selectedBook && activeChunk)}>
  <header class="app-header">
    {#if selectedBook}
      <button class="icon-button" aria-label="Back to library" on:click={closeBook}>
        <span aria-hidden="true">‹</span>
      </button>
    {:else}
      <div class="brand-mark" aria-hidden="true">C</div>
    {/if}
    <div>
      <h1>{selectedBook ? selectedBook.title : 'ChapterClip'}</h1>
      {#if selectedBook && selectedProgress}
        <p>{selectedProgress.read}/{selectedProgress.total} chunks · {selectedProgress.percent}%</p>
      {:else}
        <p>Android EPUB chunks in your browser</p>
      {/if}
    </div>
    <button class="primary-action" disabled={busy} on:click={chooseEpub}>
      Import EPUB
    </button>
  </header>

  <input
    bind:this={fileInput}
    class="hidden"
    type="file"
    accept=".epub,application/epub+zip"
    on:change={handleEpubSelected}
  />
  <input
    bind:this={backupInput}
    class="hidden"
    type="file"
    accept="application/json,.json"
    on:change={handleBackupSelected}
  />

  {#if progress}
    <div class="progress-strip">
      <div>{progress.message}</div>
      <div class="progress-bar"><span></span></div>
    </div>
  {/if}

  {#if !selectedBook}
    <section class="library-toolbar">
      <label>
        Chunk size
        <input
          type="number"
          min="200"
          step="100"
          bind:value={chunkTargetChars}
        />
      </label>
      <div class="toolbar-actions">
        <button on:click={chooseBackup}>Import backup</button>
        <button on:click={exportBackup} disabled={!books.length}>Export backup</button>
      </div>
    </section>

    {#if books.length}
      <section class="book-grid" aria-label="Library">
        {#each books as book}
          <article class="book-card">
            <button class="book-main" on:click={() => openBook(book.id)}>
              <span class="book-title">{book.title}</span>
              <span class="book-author">{book.author || book.sourceFileName}</span>
              <span class="book-meta">
                {book.totalChunkCount} chunks · {summaryPercent(book)}% · {formatDate(book.importedAt)}
              </span>
              <span class="meter"><span style={`width: ${summaryPercent(book)}%`}></span></span>
            </button>
            <button class="danger" on:click={() => removeBook(book)}>Delete</button>
          </article>
        {/each}
      </section>
    {:else}
      <section class="empty-state">
        <div class="empty-icon" aria-hidden="true">▰</div>
        <h2>No books imported</h2>
        <button class="primary-action" on:click={chooseEpub}>Import EPUB</button>
      </section>
    {/if}
  {:else if activeChunk}
    <section class="reader-shell">
      <aside class="chapter-list" aria-label="Chapters">
        {#each selectedBook.chapters as chapter}
          <details open>
            <summary>{chapter.title}</summary>
            {#each chapter.chunks as chunk}
              <button
                class:active={chunk.id === activeChunk.id}
                class:done={chunk.read}
                on:click={() => openChunk(chunk)}
              >
                <span>{chunk.title}</span>
                <small>{chunk.charCount} chars</small>
              </button>
            {/each}
          </details>
        {/each}
      </aside>

      <article class="reader">
        <div class="reader-top">
          <div>
            <h2>{activeChunk.title}</h2>
            <p>{activeChunkIndex + 1}/{chunks.length} · {activeChunk.charCount} chars</p>
          </div>
          <button on:click={() => markActiveChunk(!activeChunk.read)}>
            {activeChunk.read ? 'Mark unread' : 'Mark read'}
          </button>
        </div>

        <div class="chunk-text">{activeChunk.content}</div>

        <nav class="reader-actions">
          <button on:click={previousChunk} disabled={activeChunkIndex === 0}>Previous</button>
          <button class="primary-action" on:click={copyActiveChunk}>Copy text</button>
          <button on:click={nextChunk} disabled={activeChunkIndex >= chunks.length - 1}>Next</button>
        </nav>
      </article>
    </section>
  {/if}

  {#if notice}
    <div class="toast">{notice}</div>
  {/if}
</main>
