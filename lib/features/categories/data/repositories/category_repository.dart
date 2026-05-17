import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final _uuid = const Uuid();

  Future<List<CategoryModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'categories',
      where: 'is_deleted = 0',
      orderBy: 'name ASC',
    );
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel> add(String name) async {
    final db = await AppDatabase.instance.database;
    final category = CategoryModel(id: _uuid.v4(), name: name);
    await db.insert('categories', category.toMap());
    return category;
  }

  Future<void> softDelete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'categories',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getUnsynced() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'categories',
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getDeleted() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'categories',
      where: 'is_deleted = 1',
    );
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    final db = await AppDatabase.instance.database;
    for (final id in ids) {
      await db.update(
        'categories',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> permanentDelete(List<String> ids) async {
    final db = await AppDatabase.instance.database;
    for (final id in ids) {
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    }
  }
}
