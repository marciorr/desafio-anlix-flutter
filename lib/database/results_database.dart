import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/result.dart';

class ResultsDatabase {
  factory ResultsDatabase() {
    return _resultsDatabase;
  }

  ResultsDatabase._internal();
  static const String tableName = 'results';
  static const String id = 'id';
  static const String cpf = 'cpf';
  static const String epoch = 'epoch';
  static const String resultType = 'result_type';
  static const String resultData = 'result_data';
  static final ResultsDatabase _resultsDatabase = ResultsDatabase._internal();
  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }

    return initDB();
  }

  Future<void> _onCreate(final Database db, final int version) async {
    const sql =
        'CREATE TABLE $tableName ($id INTEGER PRIMARY KEY AUTOINCREMENT, $cpf VARCHAR, $epoch VARCHAR, $resultType VARCHAR, $resultData VARCHAR)'; // ignore: lines_longer_than_80_chars
    await db.execute(sql);
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final dbFileName = join(dbPath, 'anlix_results.db');

    final db = await openDatabase(dbFileName, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> saveResult(final Result resultToSave) async {
    final dataBase = await db;
    try {
      await dataBase?.transaction((final txn) async {
        await txn.insert(tableName, resultToSave.toMap());
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      log('Error inserting data: $e');
    }
  }

  Future<Result?> getResult(
    final String cpf,
    final String epoch,
    final String resultType,
  ) async {
    final dataBase = await db;
    final List<Map<String, dynamic>> maps = await dataBase!.query(
      tableName,
      where: 'cpf = ? AND epoch = ? AND result_type = ?',
      whereArgs: [cpf, epoch, resultType],
    );

    if (maps.isNotEmpty) {
      return Result.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLatestIndCard(final String cpf) async {
    final database = await db;
    final result = await database?.query(
      tableName,
      where: 'result_type = ? AND cpf = ?',
      whereArgs: ['ind_card', cpf],
      orderBy: 'epoch DESC',
      limit: 1,
    );

    if (result!.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getLatestPulmCard(final String cpf) async {
    final database = await db;
    final result = await database?.query(
      tableName,
      where: 'result_type = ? AND cpf = ?',
      whereArgs: ['ind_pulm', cpf],
      orderBy: 'epoch DESC',
      limit: 1,
    );

    if (result!.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>?> getCombinedResultsByDate(
    final int startDate,
    final int endDate,
  ) async {
    final dataBase = await db;

    final indCardResults = await dataBase?.query(
      tableName,
      where: 'result_type = ? AND epoch >= ? AND epoch <= ?',
      whereArgs: ['ind_card', startDate, endDate],
    );

    final indPulmResults = await dataBase?.query(
      tableName,
      where: 'result_type = ? AND epoch >= ? AND epoch <= ?',
      whereArgs: ['ind_pulm', startDate, endDate],
    );

    final combinedResults = <Map<String, dynamic>>[
      if (indCardResults != null) ...indCardResults,
      if (indPulmResults != null) ...indPulmResults,
    ]..sort((final a, final b) {
        final epochA = int.parse(a['epoch'].toString());
        final epochB = int.parse(b['epoch'].toString());
        return epochA.compareTo(epochB);
      });

    return combinedResults;
  }
}
