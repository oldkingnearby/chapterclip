import 'package:drift/drift.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get sourceFileName => text()();
  TextColumn get sourceFilePath => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get chunkTargetChars => integer()();
  IntColumn get readParagraphCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalParagraphCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get readChunkCount => integer().withDefault(const Constant(0))();
  IntColumn get totalChunkCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('ready'))();
}

class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer()();
  TextColumn get title => text()();
  TextColumn get href => text().nullable()();
  IntColumn get charCount => integer()();
  IntColumn get paragraphCount => integer()();
  IntColumn get readParagraphCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get chunkCount => integer()();
  IntColumn get readChunkCount => integer().withDefault(const Constant(0))();
}

class Chunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get chapterId =>
      integer().references(Chapters, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer()();
  TextColumn get title => text()();
  TextColumn get content => text().named('text')();
  IntColumn get charCount => integer()();
  IntColumn get paragraphStartIndex => integer()();
  IntColumn get paragraphEndIndex => integer()();
  IntColumn get copiedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCopiedAt => dateTime().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();
}

class BookParagraphs extends Table {
  @override
  String get tableName => 'paragraphs';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get chapterId =>
      integer().references(Chapters, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkId => integer().nullable().references(
        Chunks,
        #id,
        onDelete: KeyAction.setNull,
      )();
  IntColumn get orderIndex => integer()();
  TextColumn get content => text().named('text')();
  IntColumn get charCount => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();
}
