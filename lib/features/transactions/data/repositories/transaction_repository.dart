import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _uuid = const Uuid();

  Future<List<TransactionModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''');
    return result.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getRecent({int limit = 10}) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('''
      SELECT t.*, c.name as category_name
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
      LIMIT ?
    ''', [limit]);
    return result.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel> add({
    required double amount,
    required String note,
    required String type,
    required String categoryId,
    DateTime? timestamp,
  }) async {
    final db = await AppDatabase.instance.database;
    final txn = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      note: note,
      type: type.toLowerCase(),
      categoryId: categoryId,
      timestamp: timestamp ?? DateTime.now(),
    );
    await db.insert('transactions', txn.toMap());
    return txn;
  }

  Future<void> softDelete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByType(String type) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = ? AND is_deleted = 0
    ''', [type.toLowerCase()]);
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getMonthlyDebit() async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE type = 'debit' AND is_deleted = 0
      AND timestamp >= ?
    ''', [monthStart]);
    return (result.first['total'] as num).toDouble();
  }

  Future<List<TransactionModel>> getUnsynced() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'transactions',
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getDeleted() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'transactions',
      where: 'is_deleted = 1',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    final db = await AppDatabase.instance.database;
    for (final id in ids) {
      await db.update(
        'transactions',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> permanentDelete(List<String> ids) async {
    final db = await AppDatabase.instance.database;
    for (final id in ids) {
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> saveFetched(List<TransactionModel> transactions) async {
    final db = await AppDatabase.instance.database;
    final batch = db.batch();
    for (final txn in transactions) {
      batch.insert(
        'transactions',
        {
          'id': txn.id,
          'amount': txn.amount,
          'note': txn.note,
          'type': txn.type,
          'category_id': txn.categoryId,
          'timestamp': txn.timestamp.toIso8601String(),
          'is_synced': 1,
          'is_deleted': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
