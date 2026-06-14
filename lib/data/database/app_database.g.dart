// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceFileNameMeta =
      const VerificationMeta('sourceFileName');
  @override
  late final GeneratedColumn<String> sourceFileName = GeneratedColumn<String>(
      'source_file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceFilePathMeta =
      const VerificationMeta('sourceFilePath');
  @override
  late final GeneratedColumn<String> sourceFilePath = GeneratedColumn<String>(
      'source_file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _chunkTargetCharsMeta =
      const VerificationMeta('chunkTargetChars');
  @override
  late final GeneratedColumn<int> chunkTargetChars = GeneratedColumn<int>(
      'chunk_target_chars', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readParagraphCountMeta =
      const VerificationMeta('readParagraphCount');
  @override
  late final GeneratedColumn<int> readParagraphCount = GeneratedColumn<int>(
      'read_paragraph_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalParagraphCountMeta =
      const VerificationMeta('totalParagraphCount');
  @override
  late final GeneratedColumn<int> totalParagraphCount = GeneratedColumn<int>(
      'total_paragraph_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _readChunkCountMeta =
      const VerificationMeta('readChunkCount');
  @override
  late final GeneratedColumn<int> readChunkCount = GeneratedColumn<int>(
      'read_chunk_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalChunkCountMeta =
      const VerificationMeta('totalChunkCount');
  @override
  late final GeneratedColumn<int> totalChunkCount = GeneratedColumn<int>(
      'total_chunk_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ready'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        author,
        language,
        sourceFileName,
        sourceFilePath,
        importedAt,
        updatedAt,
        chunkTargetChars,
        readParagraphCount,
        totalParagraphCount,
        readChunkCount,
        totalChunkCount,
        status
      ];
  @override
  String get aliasedName => _alias ?? 'books';
  @override
  String get actualTableName => 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('source_file_name')) {
      context.handle(
          _sourceFileNameMeta,
          sourceFileName.isAcceptableOrUnknown(
              data['source_file_name']!, _sourceFileNameMeta));
    } else if (isInserting) {
      context.missing(_sourceFileNameMeta);
    }
    if (data.containsKey('source_file_path')) {
      context.handle(
          _sourceFilePathMeta,
          sourceFilePath.isAcceptableOrUnknown(
              data['source_file_path']!, _sourceFilePathMeta));
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('chunk_target_chars')) {
      context.handle(
          _chunkTargetCharsMeta,
          chunkTargetChars.isAcceptableOrUnknown(
              data['chunk_target_chars']!, _chunkTargetCharsMeta));
    } else if (isInserting) {
      context.missing(_chunkTargetCharsMeta);
    }
    if (data.containsKey('read_paragraph_count')) {
      context.handle(
          _readParagraphCountMeta,
          readParagraphCount.isAcceptableOrUnknown(
              data['read_paragraph_count']!, _readParagraphCountMeta));
    }
    if (data.containsKey('total_paragraph_count')) {
      context.handle(
          _totalParagraphCountMeta,
          totalParagraphCount.isAcceptableOrUnknown(
              data['total_paragraph_count']!, _totalParagraphCountMeta));
    }
    if (data.containsKey('read_chunk_count')) {
      context.handle(
          _readChunkCountMeta,
          readChunkCount.isAcceptableOrUnknown(
              data['read_chunk_count']!, _readChunkCountMeta));
    }
    if (data.containsKey('total_chunk_count')) {
      context.handle(
          _totalChunkCountMeta,
          totalChunkCount.isAcceptableOrUnknown(
              data['total_chunk_count']!, _totalChunkCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      sourceFileName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_file_name'])!,
      sourceFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_file_path']),
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      chunkTargetChars: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}chunk_target_chars'])!,
      readParagraphCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}read_paragraph_count'])!,
      totalParagraphCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_paragraph_count'])!,
      readChunkCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_chunk_count'])!,
      totalChunkCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chunk_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String? author;
  final String? language;
  final String sourceFileName;
  final String? sourceFilePath;
  final DateTime importedAt;
  final DateTime updatedAt;
  final int chunkTargetChars;
  final int readParagraphCount;
  final int totalParagraphCount;
  final int readChunkCount;
  final int totalChunkCount;
  final String status;
  const Book(
      {required this.id,
      required this.title,
      this.author,
      this.language,
      required this.sourceFileName,
      this.sourceFilePath,
      required this.importedAt,
      required this.updatedAt,
      required this.chunkTargetChars,
      required this.readParagraphCount,
      required this.totalParagraphCount,
      required this.readChunkCount,
      required this.totalChunkCount,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['source_file_name'] = Variable<String>(sourceFileName);
    if (!nullToAbsent || sourceFilePath != null) {
      map['source_file_path'] = Variable<String>(sourceFilePath);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['chunk_target_chars'] = Variable<int>(chunkTargetChars);
    map['read_paragraph_count'] = Variable<int>(readParagraphCount);
    map['total_paragraph_count'] = Variable<int>(totalParagraphCount);
    map['read_chunk_count'] = Variable<int>(readChunkCount);
    map['total_chunk_count'] = Variable<int>(totalChunkCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      sourceFileName: Value(sourceFileName),
      sourceFilePath: sourceFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilePath),
      importedAt: Value(importedAt),
      updatedAt: Value(updatedAt),
      chunkTargetChars: Value(chunkTargetChars),
      readParagraphCount: Value(readParagraphCount),
      totalParagraphCount: Value(totalParagraphCount),
      readChunkCount: Value(readChunkCount),
      totalChunkCount: Value(totalChunkCount),
      status: Value(status),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      language: serializer.fromJson<String?>(json['language']),
      sourceFileName: serializer.fromJson<String>(json['sourceFileName']),
      sourceFilePath: serializer.fromJson<String?>(json['sourceFilePath']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      chunkTargetChars: serializer.fromJson<int>(json['chunkTargetChars']),
      readParagraphCount: serializer.fromJson<int>(json['readParagraphCount']),
      totalParagraphCount:
          serializer.fromJson<int>(json['totalParagraphCount']),
      readChunkCount: serializer.fromJson<int>(json['readChunkCount']),
      totalChunkCount: serializer.fromJson<int>(json['totalChunkCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'language': serializer.toJson<String?>(language),
      'sourceFileName': serializer.toJson<String>(sourceFileName),
      'sourceFilePath': serializer.toJson<String?>(sourceFilePath),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'chunkTargetChars': serializer.toJson<int>(chunkTargetChars),
      'readParagraphCount': serializer.toJson<int>(readParagraphCount),
      'totalParagraphCount': serializer.toJson<int>(totalParagraphCount),
      'readChunkCount': serializer.toJson<int>(readChunkCount),
      'totalChunkCount': serializer.toJson<int>(totalChunkCount),
      'status': serializer.toJson<String>(status),
    };
  }

  Book copyWith(
          {int? id,
          String? title,
          Value<String?> author = const Value.absent(),
          Value<String?> language = const Value.absent(),
          String? sourceFileName,
          Value<String?> sourceFilePath = const Value.absent(),
          DateTime? importedAt,
          DateTime? updatedAt,
          int? chunkTargetChars,
          int? readParagraphCount,
          int? totalParagraphCount,
          int? readChunkCount,
          int? totalChunkCount,
          String? status}) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        language: language.present ? language.value : this.language,
        sourceFileName: sourceFileName ?? this.sourceFileName,
        sourceFilePath:
            sourceFilePath.present ? sourceFilePath.value : this.sourceFilePath,
        importedAt: importedAt ?? this.importedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        chunkTargetChars: chunkTargetChars ?? this.chunkTargetChars,
        readParagraphCount: readParagraphCount ?? this.readParagraphCount,
        totalParagraphCount: totalParagraphCount ?? this.totalParagraphCount,
        readChunkCount: readChunkCount ?? this.readChunkCount,
        totalChunkCount: totalChunkCount ?? this.totalChunkCount,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('language: $language, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('chunkTargetChars: $chunkTargetChars, ')
          ..write('readParagraphCount: $readParagraphCount, ')
          ..write('totalParagraphCount: $totalParagraphCount, ')
          ..write('readChunkCount: $readChunkCount, ')
          ..write('totalChunkCount: $totalChunkCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      author,
      language,
      sourceFileName,
      sourceFilePath,
      importedAt,
      updatedAt,
      chunkTargetChars,
      readParagraphCount,
      totalParagraphCount,
      readChunkCount,
      totalChunkCount,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.language == this.language &&
          other.sourceFileName == this.sourceFileName &&
          other.sourceFilePath == this.sourceFilePath &&
          other.importedAt == this.importedAt &&
          other.updatedAt == this.updatedAt &&
          other.chunkTargetChars == this.chunkTargetChars &&
          other.readParagraphCount == this.readParagraphCount &&
          other.totalParagraphCount == this.totalParagraphCount &&
          other.readChunkCount == this.readChunkCount &&
          other.totalChunkCount == this.totalChunkCount &&
          other.status == this.status);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> language;
  final Value<String> sourceFileName;
  final Value<String?> sourceFilePath;
  final Value<DateTime> importedAt;
  final Value<DateTime> updatedAt;
  final Value<int> chunkTargetChars;
  final Value<int> readParagraphCount;
  final Value<int> totalParagraphCount;
  final Value<int> readChunkCount;
  final Value<int> totalChunkCount;
  final Value<String> status;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.language = const Value.absent(),
    this.sourceFileName = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.chunkTargetChars = const Value.absent(),
    this.readParagraphCount = const Value.absent(),
    this.totalParagraphCount = const Value.absent(),
    this.readChunkCount = const Value.absent(),
    this.totalChunkCount = const Value.absent(),
    this.status = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.language = const Value.absent(),
    required String sourceFileName,
    this.sourceFilePath = const Value.absent(),
    required DateTime importedAt,
    required DateTime updatedAt,
    required int chunkTargetChars,
    this.readParagraphCount = const Value.absent(),
    this.totalParagraphCount = const Value.absent(),
    this.readChunkCount = const Value.absent(),
    this.totalChunkCount = const Value.absent(),
    this.status = const Value.absent(),
  })  : title = Value(title),
        sourceFileName = Value(sourceFileName),
        importedAt = Value(importedAt),
        updatedAt = Value(updatedAt),
        chunkTargetChars = Value(chunkTargetChars);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? language,
    Expression<String>? sourceFileName,
    Expression<String>? sourceFilePath,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? chunkTargetChars,
    Expression<int>? readParagraphCount,
    Expression<int>? totalParagraphCount,
    Expression<int>? readChunkCount,
    Expression<int>? totalChunkCount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (language != null) 'language': language,
      if (sourceFileName != null) 'source_file_name': sourceFileName,
      if (sourceFilePath != null) 'source_file_path': sourceFilePath,
      if (importedAt != null) 'imported_at': importedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (chunkTargetChars != null) 'chunk_target_chars': chunkTargetChars,
      if (readParagraphCount != null)
        'read_paragraph_count': readParagraphCount,
      if (totalParagraphCount != null)
        'total_paragraph_count': totalParagraphCount,
      if (readChunkCount != null) 'read_chunk_count': readChunkCount,
      if (totalChunkCount != null) 'total_chunk_count': totalChunkCount,
      if (status != null) 'status': status,
    });
  }

  BooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? author,
      Value<String?>? language,
      Value<String>? sourceFileName,
      Value<String?>? sourceFilePath,
      Value<DateTime>? importedAt,
      Value<DateTime>? updatedAt,
      Value<int>? chunkTargetChars,
      Value<int>? readParagraphCount,
      Value<int>? totalParagraphCount,
      Value<int>? readChunkCount,
      Value<int>? totalChunkCount,
      Value<String>? status}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      language: language ?? this.language,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      importedAt: importedAt ?? this.importedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chunkTargetChars: chunkTargetChars ?? this.chunkTargetChars,
      readParagraphCount: readParagraphCount ?? this.readParagraphCount,
      totalParagraphCount: totalParagraphCount ?? this.totalParagraphCount,
      readChunkCount: readChunkCount ?? this.readChunkCount,
      totalChunkCount: totalChunkCount ?? this.totalChunkCount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (sourceFileName.present) {
      map['source_file_name'] = Variable<String>(sourceFileName.value);
    }
    if (sourceFilePath.present) {
      map['source_file_path'] = Variable<String>(sourceFilePath.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (chunkTargetChars.present) {
      map['chunk_target_chars'] = Variable<int>(chunkTargetChars.value);
    }
    if (readParagraphCount.present) {
      map['read_paragraph_count'] = Variable<int>(readParagraphCount.value);
    }
    if (totalParagraphCount.present) {
      map['total_paragraph_count'] = Variable<int>(totalParagraphCount.value);
    }
    if (readChunkCount.present) {
      map['read_chunk_count'] = Variable<int>(readChunkCount.value);
    }
    if (totalChunkCount.present) {
      map['total_chunk_count'] = Variable<int>(totalChunkCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('language: $language, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('chunkTargetChars: $chunkTargetChars, ')
          ..write('readParagraphCount: $readParagraphCount, ')
          ..write('totalParagraphCount: $totalParagraphCount, ')
          ..write('readChunkCount: $readChunkCount, ')
          ..write('totalChunkCount: $totalChunkCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hrefMeta = const VerificationMeta('href');
  @override
  late final GeneratedColumn<String> href = GeneratedColumn<String>(
      'href', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _charCountMeta =
      const VerificationMeta('charCount');
  @override
  late final GeneratedColumn<int> charCount = GeneratedColumn<int>(
      'char_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paragraphCountMeta =
      const VerificationMeta('paragraphCount');
  @override
  late final GeneratedColumn<int> paragraphCount = GeneratedColumn<int>(
      'paragraph_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readParagraphCountMeta =
      const VerificationMeta('readParagraphCount');
  @override
  late final GeneratedColumn<int> readParagraphCount = GeneratedColumn<int>(
      'read_paragraph_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _chunkCountMeta =
      const VerificationMeta('chunkCount');
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
      'chunk_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _readChunkCountMeta =
      const VerificationMeta('readChunkCount');
  @override
  late final GeneratedColumn<int> readChunkCount = GeneratedColumn<int>(
      'read_chunk_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        orderIndex,
        title,
        href,
        charCount,
        paragraphCount,
        readParagraphCount,
        chunkCount,
        readChunkCount
      ];
  @override
  String get aliasedName => _alias ?? 'chapters';
  @override
  String get actualTableName => 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<Chapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('href')) {
      context.handle(
          _hrefMeta, href.isAcceptableOrUnknown(data['href']!, _hrefMeta));
    }
    if (data.containsKey('char_count')) {
      context.handle(_charCountMeta,
          charCount.isAcceptableOrUnknown(data['char_count']!, _charCountMeta));
    } else if (isInserting) {
      context.missing(_charCountMeta);
    }
    if (data.containsKey('paragraph_count')) {
      context.handle(
          _paragraphCountMeta,
          paragraphCount.isAcceptableOrUnknown(
              data['paragraph_count']!, _paragraphCountMeta));
    } else if (isInserting) {
      context.missing(_paragraphCountMeta);
    }
    if (data.containsKey('read_paragraph_count')) {
      context.handle(
          _readParagraphCountMeta,
          readParagraphCount.isAcceptableOrUnknown(
              data['read_paragraph_count']!, _readParagraphCountMeta));
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
          _chunkCountMeta,
          chunkCount.isAcceptableOrUnknown(
              data['chunk_count']!, _chunkCountMeta));
    } else if (isInserting) {
      context.missing(_chunkCountMeta);
    }
    if (data.containsKey('read_chunk_count')) {
      context.handle(
          _readChunkCountMeta,
          readChunkCount.isAcceptableOrUnknown(
              data['read_chunk_count']!, _readChunkCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      href: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}href']),
      charCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_count'])!,
      paragraphCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paragraph_count'])!,
      readParagraphCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}read_paragraph_count'])!,
      chunkCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chunk_count'])!,
      readChunkCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_chunk_count'])!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int bookId;
  final int orderIndex;
  final String title;
  final String? href;
  final int charCount;
  final int paragraphCount;
  final int readParagraphCount;
  final int chunkCount;
  final int readChunkCount;
  const Chapter(
      {required this.id,
      required this.bookId,
      required this.orderIndex,
      required this.title,
      this.href,
      required this.charCount,
      required this.paragraphCount,
      required this.readParagraphCount,
      required this.chunkCount,
      required this.readChunkCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['order_index'] = Variable<int>(orderIndex);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || href != null) {
      map['href'] = Variable<String>(href);
    }
    map['char_count'] = Variable<int>(charCount);
    map['paragraph_count'] = Variable<int>(paragraphCount);
    map['read_paragraph_count'] = Variable<int>(readParagraphCount);
    map['chunk_count'] = Variable<int>(chunkCount);
    map['read_chunk_count'] = Variable<int>(readChunkCount);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      orderIndex: Value(orderIndex),
      title: Value(title),
      href: href == null && nullToAbsent ? const Value.absent() : Value(href),
      charCount: Value(charCount),
      paragraphCount: Value(paragraphCount),
      readParagraphCount: Value(readParagraphCount),
      chunkCount: Value(chunkCount),
      readChunkCount: Value(readChunkCount),
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      title: serializer.fromJson<String>(json['title']),
      href: serializer.fromJson<String?>(json['href']),
      charCount: serializer.fromJson<int>(json['charCount']),
      paragraphCount: serializer.fromJson<int>(json['paragraphCount']),
      readParagraphCount: serializer.fromJson<int>(json['readParagraphCount']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      readChunkCount: serializer.fromJson<int>(json['readChunkCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'title': serializer.toJson<String>(title),
      'href': serializer.toJson<String?>(href),
      'charCount': serializer.toJson<int>(charCount),
      'paragraphCount': serializer.toJson<int>(paragraphCount),
      'readParagraphCount': serializer.toJson<int>(readParagraphCount),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'readChunkCount': serializer.toJson<int>(readChunkCount),
    };
  }

  Chapter copyWith(
          {int? id,
          int? bookId,
          int? orderIndex,
          String? title,
          Value<String?> href = const Value.absent(),
          int? charCount,
          int? paragraphCount,
          int? readParagraphCount,
          int? chunkCount,
          int? readChunkCount}) =>
      Chapter(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        orderIndex: orderIndex ?? this.orderIndex,
        title: title ?? this.title,
        href: href.present ? href.value : this.href,
        charCount: charCount ?? this.charCount,
        paragraphCount: paragraphCount ?? this.paragraphCount,
        readParagraphCount: readParagraphCount ?? this.readParagraphCount,
        chunkCount: chunkCount ?? this.chunkCount,
        readChunkCount: readChunkCount ?? this.readChunkCount,
      );
  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('title: $title, ')
          ..write('href: $href, ')
          ..write('charCount: $charCount, ')
          ..write('paragraphCount: $paragraphCount, ')
          ..write('readParagraphCount: $readParagraphCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('readChunkCount: $readChunkCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookId,
      orderIndex,
      title,
      href,
      charCount,
      paragraphCount,
      readParagraphCount,
      chunkCount,
      readChunkCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.orderIndex == this.orderIndex &&
          other.title == this.title &&
          other.href == this.href &&
          other.charCount == this.charCount &&
          other.paragraphCount == this.paragraphCount &&
          other.readParagraphCount == this.readParagraphCount &&
          other.chunkCount == this.chunkCount &&
          other.readChunkCount == this.readChunkCount);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> orderIndex;
  final Value<String> title;
  final Value<String?> href;
  final Value<int> charCount;
  final Value<int> paragraphCount;
  final Value<int> readParagraphCount;
  final Value<int> chunkCount;
  final Value<int> readChunkCount;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.href = const Value.absent(),
    this.charCount = const Value.absent(),
    this.paragraphCount = const Value.absent(),
    this.readParagraphCount = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.readChunkCount = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int orderIndex,
    required String title,
    this.href = const Value.absent(),
    required int charCount,
    required int paragraphCount,
    this.readParagraphCount = const Value.absent(),
    required int chunkCount,
    this.readChunkCount = const Value.absent(),
  })  : bookId = Value(bookId),
        orderIndex = Value(orderIndex),
        title = Value(title),
        charCount = Value(charCount),
        paragraphCount = Value(paragraphCount),
        chunkCount = Value(chunkCount);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? orderIndex,
    Expression<String>? title,
    Expression<String>? href,
    Expression<int>? charCount,
    Expression<int>? paragraphCount,
    Expression<int>? readParagraphCount,
    Expression<int>? chunkCount,
    Expression<int>? readChunkCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (title != null) 'title': title,
      if (href != null) 'href': href,
      if (charCount != null) 'char_count': charCount,
      if (paragraphCount != null) 'paragraph_count': paragraphCount,
      if (readParagraphCount != null)
        'read_paragraph_count': readParagraphCount,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (readChunkCount != null) 'read_chunk_count': readChunkCount,
    });
  }

  ChaptersCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? orderIndex,
      Value<String>? title,
      Value<String?>? href,
      Value<int>? charCount,
      Value<int>? paragraphCount,
      Value<int>? readParagraphCount,
      Value<int>? chunkCount,
      Value<int>? readChunkCount}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      orderIndex: orderIndex ?? this.orderIndex,
      title: title ?? this.title,
      href: href ?? this.href,
      charCount: charCount ?? this.charCount,
      paragraphCount: paragraphCount ?? this.paragraphCount,
      readParagraphCount: readParagraphCount ?? this.readParagraphCount,
      chunkCount: chunkCount ?? this.chunkCount,
      readChunkCount: readChunkCount ?? this.readChunkCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (href.present) {
      map['href'] = Variable<String>(href.value);
    }
    if (charCount.present) {
      map['char_count'] = Variable<int>(charCount.value);
    }
    if (paragraphCount.present) {
      map['paragraph_count'] = Variable<int>(paragraphCount.value);
    }
    if (readParagraphCount.present) {
      map['read_paragraph_count'] = Variable<int>(readParagraphCount.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (readChunkCount.present) {
      map['read_chunk_count'] = Variable<int>(readChunkCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('title: $title, ')
          ..write('href: $href, ')
          ..write('charCount: $charCount, ')
          ..write('paragraphCount: $paragraphCount, ')
          ..write('readParagraphCount: $readParagraphCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('readChunkCount: $readChunkCount')
          ..write(')'))
        .toString();
  }
}

class $ChunksTable extends Chunks with TableInfo<$ChunksTable, Chunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chapters (id) ON DELETE CASCADE'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _charCountMeta =
      const VerificationMeta('charCount');
  @override
  late final GeneratedColumn<int> charCount = GeneratedColumn<int>(
      'char_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paragraphStartIndexMeta =
      const VerificationMeta('paragraphStartIndex');
  @override
  late final GeneratedColumn<int> paragraphStartIndex = GeneratedColumn<int>(
      'paragraph_start_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paragraphEndIndexMeta =
      const VerificationMeta('paragraphEndIndex');
  @override
  late final GeneratedColumn<int> paragraphEndIndex = GeneratedColumn<int>(
      'paragraph_end_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _copiedCountMeta =
      const VerificationMeta('copiedCount');
  @override
  late final GeneratedColumn<int> copiedCount = GeneratedColumn<int>(
      'copied_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastCopiedAtMeta =
      const VerificationMeta('lastCopiedAt');
  @override
  late final GeneratedColumn<DateTime> lastCopiedAt = GeneratedColumn<DateTime>(
      'last_copied_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead =
      GeneratedColumn<bool>('is_read', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_read" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        chapterId,
        orderIndex,
        title,
        content,
        charCount,
        paragraphStartIndex,
        paragraphEndIndex,
        copiedCount,
        lastCopiedAt,
        isRead,
        readAt
      ];
  @override
  String get aliasedName => _alias ?? 'chunks';
  @override
  String get actualTableName => 'chunks';
  @override
  VerificationContext validateIntegrity(Insertable<Chunk> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['text']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('char_count')) {
      context.handle(_charCountMeta,
          charCount.isAcceptableOrUnknown(data['char_count']!, _charCountMeta));
    } else if (isInserting) {
      context.missing(_charCountMeta);
    }
    if (data.containsKey('paragraph_start_index')) {
      context.handle(
          _paragraphStartIndexMeta,
          paragraphStartIndex.isAcceptableOrUnknown(
              data['paragraph_start_index']!, _paragraphStartIndexMeta));
    } else if (isInserting) {
      context.missing(_paragraphStartIndexMeta);
    }
    if (data.containsKey('paragraph_end_index')) {
      context.handle(
          _paragraphEndIndexMeta,
          paragraphEndIndex.isAcceptableOrUnknown(
              data['paragraph_end_index']!, _paragraphEndIndexMeta));
    } else if (isInserting) {
      context.missing(_paragraphEndIndexMeta);
    }
    if (data.containsKey('copied_count')) {
      context.handle(
          _copiedCountMeta,
          copiedCount.isAcceptableOrUnknown(
              data['copied_count']!, _copiedCountMeta));
    }
    if (data.containsKey('last_copied_at')) {
      context.handle(
          _lastCopiedAtMeta,
          lastCopiedAt.isAcceptableOrUnknown(
              data['last_copied_at']!, _lastCopiedAtMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chunk(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text'])!,
      charCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_count'])!,
      paragraphStartIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}paragraph_start_index'])!,
      paragraphEndIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}paragraph_end_index'])!,
      copiedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}copied_count'])!,
      lastCopiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_copied_at']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $ChunksTable createAlias(String alias) {
    return $ChunksTable(attachedDatabase, alias);
  }
}

class Chunk extends DataClass implements Insertable<Chunk> {
  final int id;
  final int bookId;
  final int chapterId;
  final int orderIndex;
  final String title;
  final String content;
  final int charCount;
  final int paragraphStartIndex;
  final int paragraphEndIndex;
  final int copiedCount;
  final DateTime? lastCopiedAt;
  final bool isRead;
  final DateTime? readAt;
  const Chunk(
      {required this.id,
      required this.bookId,
      required this.chapterId,
      required this.orderIndex,
      required this.title,
      required this.content,
      required this.charCount,
      required this.paragraphStartIndex,
      required this.paragraphEndIndex,
      required this.copiedCount,
      this.lastCopiedAt,
      required this.isRead,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_id'] = Variable<int>(chapterId);
    map['order_index'] = Variable<int>(orderIndex);
    map['title'] = Variable<String>(title);
    map['text'] = Variable<String>(content);
    map['char_count'] = Variable<int>(charCount);
    map['paragraph_start_index'] = Variable<int>(paragraphStartIndex);
    map['paragraph_end_index'] = Variable<int>(paragraphEndIndex);
    map['copied_count'] = Variable<int>(copiedCount);
    if (!nullToAbsent || lastCopiedAt != null) {
      map['last_copied_at'] = Variable<DateTime>(lastCopiedAt);
    }
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  ChunksCompanion toCompanion(bool nullToAbsent) {
    return ChunksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      orderIndex: Value(orderIndex),
      title: Value(title),
      content: Value(content),
      charCount: Value(charCount),
      paragraphStartIndex: Value(paragraphStartIndex),
      paragraphEndIndex: Value(paragraphEndIndex),
      copiedCount: Value(copiedCount),
      lastCopiedAt: lastCopiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCopiedAt),
      isRead: Value(isRead),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory Chunk.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chunk(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      charCount: serializer.fromJson<int>(json['charCount']),
      paragraphStartIndex:
          serializer.fromJson<int>(json['paragraphStartIndex']),
      paragraphEndIndex: serializer.fromJson<int>(json['paragraphEndIndex']),
      copiedCount: serializer.fromJson<int>(json['copiedCount']),
      lastCopiedAt: serializer.fromJson<DateTime?>(json['lastCopiedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapterId': serializer.toJson<int>(chapterId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'charCount': serializer.toJson<int>(charCount),
      'paragraphStartIndex': serializer.toJson<int>(paragraphStartIndex),
      'paragraphEndIndex': serializer.toJson<int>(paragraphEndIndex),
      'copiedCount': serializer.toJson<int>(copiedCount),
      'lastCopiedAt': serializer.toJson<DateTime?>(lastCopiedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  Chunk copyWith(
          {int? id,
          int? bookId,
          int? chapterId,
          int? orderIndex,
          String? title,
          String? content,
          int? charCount,
          int? paragraphStartIndex,
          int? paragraphEndIndex,
          int? copiedCount,
          Value<DateTime?> lastCopiedAt = const Value.absent(),
          bool? isRead,
          Value<DateTime?> readAt = const Value.absent()}) =>
      Chunk(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        orderIndex: orderIndex ?? this.orderIndex,
        title: title ?? this.title,
        content: content ?? this.content,
        charCount: charCount ?? this.charCount,
        paragraphStartIndex: paragraphStartIndex ?? this.paragraphStartIndex,
        paragraphEndIndex: paragraphEndIndex ?? this.paragraphEndIndex,
        copiedCount: copiedCount ?? this.copiedCount,
        lastCopiedAt:
            lastCopiedAt.present ? lastCopiedAt.value : this.lastCopiedAt,
        isRead: isRead ?? this.isRead,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  @override
  String toString() {
    return (StringBuffer('Chunk(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('charCount: $charCount, ')
          ..write('paragraphStartIndex: $paragraphStartIndex, ')
          ..write('paragraphEndIndex: $paragraphEndIndex, ')
          ..write('copiedCount: $copiedCount, ')
          ..write('lastCopiedAt: $lastCopiedAt, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookId,
      chapterId,
      orderIndex,
      title,
      content,
      charCount,
      paragraphStartIndex,
      paragraphEndIndex,
      copiedCount,
      lastCopiedAt,
      isRead,
      readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chunk &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.orderIndex == this.orderIndex &&
          other.title == this.title &&
          other.content == this.content &&
          other.charCount == this.charCount &&
          other.paragraphStartIndex == this.paragraphStartIndex &&
          other.paragraphEndIndex == this.paragraphEndIndex &&
          other.copiedCount == this.copiedCount &&
          other.lastCopiedAt == this.lastCopiedAt &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt);
}

class ChunksCompanion extends UpdateCompanion<Chunk> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapterId;
  final Value<int> orderIndex;
  final Value<String> title;
  final Value<String> content;
  final Value<int> charCount;
  final Value<int> paragraphStartIndex;
  final Value<int> paragraphEndIndex;
  final Value<int> copiedCount;
  final Value<DateTime?> lastCopiedAt;
  final Value<bool> isRead;
  final Value<DateTime?> readAt;
  const ChunksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.charCount = const Value.absent(),
    this.paragraphStartIndex = const Value.absent(),
    this.paragraphEndIndex = const Value.absent(),
    this.copiedCount = const Value.absent(),
    this.lastCopiedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  ChunksCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapterId,
    required int orderIndex,
    required String title,
    required String content,
    required int charCount,
    required int paragraphStartIndex,
    required int paragraphEndIndex,
    this.copiedCount = const Value.absent(),
    this.lastCopiedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
  })  : bookId = Value(bookId),
        chapterId = Value(chapterId),
        orderIndex = Value(orderIndex),
        title = Value(title),
        content = Value(content),
        charCount = Value(charCount),
        paragraphStartIndex = Value(paragraphStartIndex),
        paragraphEndIndex = Value(paragraphEndIndex);
  static Insertable<Chunk> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapterId,
    Expression<int>? orderIndex,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? charCount,
    Expression<int>? paragraphStartIndex,
    Expression<int>? paragraphEndIndex,
    Expression<int>? copiedCount,
    Expression<DateTime>? lastCopiedAt,
    Expression<bool>? isRead,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (title != null) 'title': title,
      if (content != null) 'text': content,
      if (charCount != null) 'char_count': charCount,
      if (paragraphStartIndex != null)
        'paragraph_start_index': paragraphStartIndex,
      if (paragraphEndIndex != null) 'paragraph_end_index': paragraphEndIndex,
      if (copiedCount != null) 'copied_count': copiedCount,
      if (lastCopiedAt != null) 'last_copied_at': lastCopiedAt,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
    });
  }

  ChunksCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? chapterId,
      Value<int>? orderIndex,
      Value<String>? title,
      Value<String>? content,
      Value<int>? charCount,
      Value<int>? paragraphStartIndex,
      Value<int>? paragraphEndIndex,
      Value<int>? copiedCount,
      Value<DateTime?>? lastCopiedAt,
      Value<bool>? isRead,
      Value<DateTime?>? readAt}) {
    return ChunksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      orderIndex: orderIndex ?? this.orderIndex,
      title: title ?? this.title,
      content: content ?? this.content,
      charCount: charCount ?? this.charCount,
      paragraphStartIndex: paragraphStartIndex ?? this.paragraphStartIndex,
      paragraphEndIndex: paragraphEndIndex ?? this.paragraphEndIndex,
      copiedCount: copiedCount ?? this.copiedCount,
      lastCopiedAt: lastCopiedAt ?? this.lastCopiedAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (charCount.present) {
      map['char_count'] = Variable<int>(charCount.value);
    }
    if (paragraphStartIndex.present) {
      map['paragraph_start_index'] = Variable<int>(paragraphStartIndex.value);
    }
    if (paragraphEndIndex.present) {
      map['paragraph_end_index'] = Variable<int>(paragraphEndIndex.value);
    }
    if (copiedCount.present) {
      map['copied_count'] = Variable<int>(copiedCount.value);
    }
    if (lastCopiedAt.present) {
      map['last_copied_at'] = Variable<DateTime>(lastCopiedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChunksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('charCount: $charCount, ')
          ..write('paragraphStartIndex: $paragraphStartIndex, ')
          ..write('paragraphEndIndex: $paragraphEndIndex, ')
          ..write('copiedCount: $copiedCount, ')
          ..write('lastCopiedAt: $lastCopiedAt, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

class $BookParagraphsTable extends BookParagraphs
    with TableInfo<$BookParagraphsTable, BookParagraph> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookParagraphsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chapters (id) ON DELETE CASCADE'));
  static const VerificationMeta _chunkIdMeta =
      const VerificationMeta('chunkId');
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
      'chunk_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chunks (id) ON DELETE SET NULL'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _charCountMeta =
      const VerificationMeta('charCount');
  @override
  late final GeneratedColumn<int> charCount = GeneratedColumn<int>(
      'char_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead =
      GeneratedColumn<bool>('is_read', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_read" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        chapterId,
        chunkId,
        orderIndex,
        content,
        charCount,
        isRead,
        readAt
      ];
  @override
  String get aliasedName => _alias ?? 'paragraphs';
  @override
  String get actualTableName => 'paragraphs';
  @override
  VerificationContext validateIntegrity(Insertable<BookParagraph> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('chunk_id')) {
      context.handle(_chunkIdMeta,
          chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['text']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('char_count')) {
      context.handle(_charCountMeta,
          charCount.isAcceptableOrUnknown(data['char_count']!, _charCountMeta));
    } else if (isInserting) {
      context.missing(_charCountMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookParagraph map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookParagraph(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_id'])!,
      chunkId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chunk_id']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text'])!,
      charCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_count'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $BookParagraphsTable createAlias(String alias) {
    return $BookParagraphsTable(attachedDatabase, alias);
  }
}

class BookParagraph extends DataClass implements Insertable<BookParagraph> {
  final int id;
  final int bookId;
  final int chapterId;
  final int? chunkId;
  final int orderIndex;
  final String content;
  final int charCount;
  final bool isRead;
  final DateTime? readAt;
  const BookParagraph(
      {required this.id,
      required this.bookId,
      required this.chapterId,
      this.chunkId,
      required this.orderIndex,
      required this.content,
      required this.charCount,
      required this.isRead,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter_id'] = Variable<int>(chapterId);
    if (!nullToAbsent || chunkId != null) {
      map['chunk_id'] = Variable<int>(chunkId);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['text'] = Variable<String>(content);
    map['char_count'] = Variable<int>(charCount);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  BookParagraphsCompanion toCompanion(bool nullToAbsent) {
    return BookParagraphsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      chunkId: chunkId == null && nullToAbsent
          ? const Value.absent()
          : Value(chunkId),
      orderIndex: Value(orderIndex),
      content: Value(content),
      charCount: Value(charCount),
      isRead: Value(isRead),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory BookParagraph.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookParagraph(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      chunkId: serializer.fromJson<int?>(json['chunkId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      content: serializer.fromJson<String>(json['content']),
      charCount: serializer.fromJson<int>(json['charCount']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapterId': serializer.toJson<int>(chapterId),
      'chunkId': serializer.toJson<int?>(chunkId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'content': serializer.toJson<String>(content),
      'charCount': serializer.toJson<int>(charCount),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  BookParagraph copyWith(
          {int? id,
          int? bookId,
          int? chapterId,
          Value<int?> chunkId = const Value.absent(),
          int? orderIndex,
          String? content,
          int? charCount,
          bool? isRead,
          Value<DateTime?> readAt = const Value.absent()}) =>
      BookParagraph(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        chunkId: chunkId.present ? chunkId.value : this.chunkId,
        orderIndex: orderIndex ?? this.orderIndex,
        content: content ?? this.content,
        charCount: charCount ?? this.charCount,
        isRead: isRead ?? this.isRead,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  @override
  String toString() {
    return (StringBuffer('BookParagraph(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chunkId: $chunkId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('content: $content, ')
          ..write('charCount: $charCount, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, chapterId, chunkId, orderIndex,
      content, charCount, isRead, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookParagraph &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.chunkId == this.chunkId &&
          other.orderIndex == this.orderIndex &&
          other.content == this.content &&
          other.charCount == this.charCount &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt);
}

class BookParagraphsCompanion extends UpdateCompanion<BookParagraph> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapterId;
  final Value<int?> chunkId;
  final Value<int> orderIndex;
  final Value<String> content;
  final Value<int> charCount;
  final Value<bool> isRead;
  final Value<DateTime?> readAt;
  const BookParagraphsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chunkId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.content = const Value.absent(),
    this.charCount = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  BookParagraphsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapterId,
    this.chunkId = const Value.absent(),
    required int orderIndex,
    required String content,
    required int charCount,
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
  })  : bookId = Value(bookId),
        chapterId = Value(chapterId),
        orderIndex = Value(orderIndex),
        content = Value(content),
        charCount = Value(charCount);
  static Insertable<BookParagraph> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapterId,
    Expression<int>? chunkId,
    Expression<int>? orderIndex,
    Expression<String>? content,
    Expression<int>? charCount,
    Expression<bool>? isRead,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chunkId != null) 'chunk_id': chunkId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (content != null) 'text': content,
      if (charCount != null) 'char_count': charCount,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
    });
  }

  BookParagraphsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? chapterId,
      Value<int?>? chunkId,
      Value<int>? orderIndex,
      Value<String>? content,
      Value<int>? charCount,
      Value<bool>? isRead,
      Value<DateTime?>? readAt}) {
    return BookParagraphsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chunkId: chunkId ?? this.chunkId,
      orderIndex: orderIndex ?? this.orderIndex,
      content: content ?? this.content,
      charCount: charCount ?? this.charCount,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (charCount.present) {
      map['char_count'] = Variable<int>(charCount.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookParagraphsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chunkId: $chunkId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('content: $content, ')
          ..write('charCount: $charCount, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ChunksTable chunks = $ChunksTable(this);
  late final $BookParagraphsTable bookParagraphs = $BookParagraphsTable(this);
  late final BookDao bookDao = BookDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [books, chapters, chunks, bookParagraphs];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('chapters', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('chunks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('chapters',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('chunks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('paragraphs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('chapters',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('paragraphs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('chunks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('paragraphs', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

mixin _$BookDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $ChaptersTable get chapters => attachedDatabase.chapters;
  $ChunksTable get chunks => attachedDatabase.chunks;
  $BookParagraphsTable get bookParagraphs => attachedDatabase.bookParagraphs;
}
