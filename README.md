# ChapterClip

[中文说明](README.zh-CN.md)

ChapterClip is an Android Flutter app for importing EPUB books, splitting chapters into copy-friendly chunks, tracking reading progress, and copying selected text with minimal friction.

The project is currently Android-only. HarmonyOS, iOS, Windows, web, and desktop platform targets are intentionally not included.

## Features

- Import EPUB files through the Android system file picker.
- Read EPUB metadata, spine order, table-of-contents titles, and XHTML chapter content.
- Extract readable paragraph blocks from chapter HTML.
- Split chapters into configurable text chunks while preserving paragraph boundaries.
- Track read progress at the paragraph, chunk, chapter, and book levels.
- Mark chunks read or unread.
- Copy chunk text and basic metadata.
- Store imported books locally with Drift and SQLite.
- Optional in-app APK update checks through a plain `update.json` manifest.

## Tech Stack

- Flutter and Dart
- Android native host code in Kotlin
- Drift for local persistence
- `sqlite3_flutter_libs` for SQLite runtime support
- `file_selector` for Android file picking
- `archive`, `xml`, and `html` for EPUB parsing
- Riverpod for app-level dependency wiring

## Requirements

- Flutter stable SDK
- Dart SDK bundled with Flutter
- Android Studio or Android command-line tools
- Android SDK with a recent compile SDK installed
- JDK 17
- A physical Android device or emulator

Check the local toolchain with:

```powershell
flutter doctor
```

## Getting Started

Clone the repository and fetch dependencies:

```powershell
git clone https://github.com/<owner>/<repo>.git
cd <repo>
flutter pub get
```

Run the app on a connected Android device:

```powershell
flutter run
```

Build a release APK:

```powershell
flutter build apk --release
```

Or use the bundled PowerShell helper:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-android.ps1 -Mode release
```

The default release APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Optional Update Manifest

ChapterClip can check for a newer APK at startup, but update checks are disabled by default in the public source tree.

Enable them at build time by passing a public base URL:

```powershell
flutter build apk --release --dart-define=CHAPTERCLIP_UPDATE_BASE_URL=https://example.com/chapterclip/
```

The app expects an `update.json` file at that base URL:

```json
{
  "version": "1.0.2",
  "buildNumber": 3,
  "apk": "chapterclip-android.apk",
  "notes": "Fix EPUB import from Android content URIs.",
  "force": false
}
```

Fields:

- `version`: semantic app version without the build number.
- `buildNumber`: Android version code.
- `apk`, `apkUrl`, `url`, or `fileName`: APK path or absolute URL.
- `notes`: optional release notes shown in the update dialog.
- `force`: optional boolean for non-dismissible update prompts.

The repository does not include any storage-provider upload script. Publish APKs and manifests with your own deployment process.

## EPUB Import Notes

Android file pickers often return `content://` URIs instead of ordinary filesystem paths. ChapterClip reads the selected `XFile` as bytes before parsing, so imports work with document providers, downloads, media documents, and other Android storage providers that expose content URIs.

The importer keeps the original source file name when available and stores all parsed data locally. EPUB parsing is offline and does not upload book contents.

## Project Layout

```text
android/                         Android host project
assets/                          App assets
lib/app.dart                     App root and theme
lib/data/database/               Drift schema, DAO, generated database code
lib/epub/                        EPUB parsing, HTML extraction, chunk builder
lib/features/book/               Book, chapter, and chunk views
lib/features/import/             Import service
lib/features/library/            Library screen and file picker flow
lib/services/app_update_service.dart
lib/utils/app_update_flow.dart
scripts/build-android.ps1        Local Android build helper
test/                            Parser, importer, and database tests
```

## Development

Regenerate Drift code after schema changes:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Run static analysis:

```powershell
flutter analyze lib test
```

Run tests:

```powershell
flutter test
```

## Android Package Name

The current Android package name is defined in `android/app/build.gradle.kts`. Change `namespace` and `applicationId` before publishing your own fork to an app store or update channel.

## License

No license has been selected yet. If you plan to reuse or redistribute the project, add an explicit license first.
