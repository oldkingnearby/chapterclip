# ChapterClip Web PWA

This is the pure web version of ChapterClip. It runs entirely in the browser and does not require a backend.

## Why Svelte

ChapterClip Web is mostly local state, file parsing, IndexedDB persistence, and a focused reading UI. Svelte keeps the implementation small and direct, with less component boilerplate than React for this shape of app. React would also be fast enough, but its ecosystem advantages are not essential here.

## Features

- Import local `.epub` files through the browser file picker.
- Parse EPUB ZIP, OPF, spine, nav, and XHTML content in the browser.
- Split chapters into copy-friendly chunks.
- Store books and reading progress in IndexedDB through Dexie.
- Copy the current chunk with the Clipboard API.
- Export and import JSON backups.
- Installable, mobile-first PWA with generated service worker assets and app icons.

## Commands

```powershell
npm install
npm run dev
npm run build
npm run preview
```

The production build is emitted to `dist/`.

## Deployment

Deploy the contents of `dist/` to any static host. The app is self-contained and stores imported books in the user's browser.

The current Cloudflare Pages project is `chapterclip`:

```powershell
npm run build
npx wrangler pages deploy dist --project-name chapterclip --branch main --commit-dirty=true
```

The Pages custom domain is `chapterclip.oldking.club`. Cloudflare still needs the DNS record for that host to point at `chapterclip.pages.dev`.

Because browser storage can be cleared by the operating system or browser settings, the UI includes backup export/import controls.
