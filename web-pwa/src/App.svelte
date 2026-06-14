<script lang="ts">
  import { onMount } from 'svelte';
  import {
    ArchiveRestore,
    ArrowLeft,
    BookOpen,
    CheckCircle2,
    ChevronLeft,
    ChevronRight,
    Copy,
    Download,
    FileUp,
    Library,
    MoreHorizontal,
    Trash2
  } from '@lucide/svelte';
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
  let toolsOpen = false;
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
    toolsOpen = false;
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
    activeChunkIndex = Math.max(0, getAllChunks(book).findIndex((chunk) => !chunk.read));
    if (activeChunkIndex < 0) activeChunkIndex = 0;
    toolsOpen = false;
  }

  function closeBook() {
    selectedBook = null;
    activeChunkIndex = 0;
    toolsOpen = false;
  }

  function openChunk(chunk: ChunkRecord) {
    const index = chunks.findIndex((item) => item.id === chunk.id);
    if (index >= 0) activeChunkIndex = index;
    toolsOpen = false;
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
    showNotice(read ? 'Marked read' : 'Marked unread');
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
    toolsOpen = false;
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
      toolsOpen = false;
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
      day: 'numeric'
    }).format(new Date(value));
  }

  function showNotice(message: string) {
    notice = message;
    setTimeout(() => {
      if (notice === message) notice = '';
    }, 2200);
  }
</script>

<main>
  <section class="phone-shell" aria-label="ChapterClip">
    <header class="top-bar">
      {#if selectedBook}
        <button class="icon-button" aria-label="Back to library" on:click={closeBook}>
          <ArrowLeft size={22} strokeWidth={2.4} />
        </button>
      {:else}
        <img class="app-icon" src="/icon-192.png" alt="" />
      {/if}

      <div class="title-block">
        <h1>{selectedBook ? selectedBook.title : 'ChapterClip'}</h1>
        {#if selectedBook && selectedProgress}
          <p>{selectedProgress.read}/{selectedProgress.total} chunks, {selectedProgress.percent}%</p>
        {:else}
          <p>{books.length ? `${books.length} books saved offline` : 'EPUB chunks, ready to copy'}</p>
        {/if}
      </div>

      <button
        class="icon-button"
        aria-label={selectedBook ? 'Show chunks' : 'Library tools'}
        on:click={() => (toolsOpen = !toolsOpen)}
      >
        <MoreHorizontal size={22} strokeWidth={2.4} />
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
      <div class="progress-strip" role="status">
        <span>{progress.message}</span>
        <div class="progress-bar"><span></span></div>
      </div>
    {/if}

    {#if !selectedBook}
      <section class="screen library-screen" aria-label="Library">
        {#if books.length}
          <div class="book-list">
            {#each books as book}
              <article class="book-row">
                <button class="book-main" on:click={() => openBook(book.id)}>
                  <span class="book-cover" aria-hidden="true">
                    <BookOpen size={24} strokeWidth={2.2} />
                  </span>
                  <span class="book-text">
                    <span class="book-title">{book.title}</span>
                    <span class="book-author">{book.author || book.sourceFileName}</span>
                    <span class="book-meta">
                      {book.totalChunkCount} chunks, {summaryPercent(book)}%, {formatDate(book.importedAt)}
                    </span>
                    <span class="meter"><span style={`width: ${summaryPercent(book)}%`}></span></span>
                  </span>
                </button>
                <button
                  class="icon-button danger"
                  aria-label={`Delete ${book.title}`}
                  on:click={() => removeBook(book)}
                >
                  <Trash2 size={19} />
                </button>
              </article>
            {/each}
          </div>
        {:else}
          <div class="empty-state">
            <div class="empty-mark" aria-hidden="true">
              <BookOpen size={58} strokeWidth={1.7} />
            </div>
            <h2>No books imported</h2>
            <p>Import an EPUB and ChapterClip will keep it offline on this device.</p>
          </div>
        {/if}
      </section>

      {#if toolsOpen}
        <section class="sheet" aria-label="Library tools">
          <div class="sheet-handle"></div>
          <label class="field">
            <span>Chunk size</span>
            <input
              type="number"
              min="200"
              step="100"
              bind:value={chunkTargetChars}
            />
          </label>
          <div class="sheet-grid">
            <button on:click={chooseBackup}>
              <ArchiveRestore size={18} />
              Import backup
            </button>
            <button on:click={exportBackup} disabled={!books.length}>
              <Download size={18} />
              Export backup
            </button>
          </div>
        </section>
      {/if}

      <nav class="bottom-bar" aria-label="Library actions">
        <button class="bottom-tab active" aria-label="Library">
          <Library size={20} />
          <span>Library</span>
        </button>
        <button class="primary-pill" disabled={busy} on:click={chooseEpub}>
          <FileUp size={21} />
          <span>{busy ? 'Importing' : 'Import EPUB'}</span>
        </button>
      </nav>
    {:else if activeChunk}
      <section class="screen reader-screen" aria-label="Reader">
        <div class="reader-card">
          <div class="reader-meta">
            <span>Chunk {activeChunkIndex + 1}/{chunks.length}</span>
            <button class:read={activeChunk.read} on:click={() => markActiveChunk(!activeChunk.read)}>
              <CheckCircle2 size={18} />
              {activeChunk.read ? 'Read' : 'Mark read'}
            </button>
          </div>
          <h2>{activeChunk.title}</h2>
          <p class="chunk-count">{activeChunk.charCount} chars</p>
          <div class="chunk-text">{activeChunk.content}</div>
        </div>

        {#if toolsOpen}
          <section class="chunk-sheet" aria-label="Chunks">
            <div class="sheet-handle"></div>
            <h3>All chunks</h3>
            <div class="chunk-list">
              {#each selectedBook.chapters as chapter}
                <div class="chapter-group">
                  <p>{chapter.title}</p>
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
                </div>
              {/each}
            </div>
          </section>
        {/if}
      </section>

      <nav class="reader-bar" aria-label="Reader actions">
        <button class="icon-button" aria-label="Previous chunk" on:click={previousChunk} disabled={activeChunkIndex === 0}>
          <ChevronLeft size={23} />
        </button>
        <button class="copy-pill" on:click={copyActiveChunk}>
          <Copy size={21} />
          Copy text
        </button>
        <button class="icon-button" aria-label="Next chunk" on:click={nextChunk} disabled={activeChunkIndex >= chunks.length - 1}>
          <ChevronRight size={23} />
        </button>
      </nav>
    {/if}

    {#if notice}
      <div class="toast">{notice}</div>
    {/if}
  </section>
</main>
