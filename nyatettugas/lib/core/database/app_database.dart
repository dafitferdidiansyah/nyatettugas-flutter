import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// 1. Tabel Mata Kuliah
class Courses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get day => text()(); // Monday, Tuesday, etc.
  TextColumn get time => text()(); // 08:00
  TextColumn get room => text().nullable()();
  TextColumn get lecturer => text().nullable()();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF2196F3))();
}

// 2. Tabel Tugas
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get courseId => integer().references(Courses, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get deadline => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

// 3. Tabel Lampiran
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()(); // 'image' atau 'pdf'
}

// 4. Tabel Settings (Key-Value)
class Preferences extends Table {
  TextColumn get key => text().primaryKey()();
  TextColumn get value => text()();
}

@DriftDatabase(tables: [Courses, Tasks, Attachments, Preferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'coursetrak.sqlite'));
    return NativeDatabase(file);
  });
}