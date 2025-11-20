import '../data/db/database.dart';
import 'package:drift/drift.dart';

class CategoryService {
  final AppDatabase _db;

  CategoryService(this._db);

  /// Creates a new category
  Future<int> createCategory(String name) async {
    // Business rule: Check for duplicates
    final existing = await _db.categoriesDao.getByName(name.trim());
    if (existing != null) {
      throw Exception('Category "$name" already exists');
    }

    return await _db.categoriesDao.insert(
      CategoriesCompanion.insert(name: name.trim()),
    );
  }

  /// Updates a category name
  Future<void> updateCategory({
    required int id,
    required String newName,
  }) async {
    // Business rule: Check for duplicate names
    final existing = await _db.categoriesDao.getByName(newName.trim());
    if (existing != null && existing.id != id) {
      throw Exception('Category "$newName" already exists');
    }

    await _db.categoriesDao.updateCategory(
      CategoriesCompanion(id: Value(id), name: Value(newName.trim())),
    );
  }

  /// Deletes a category
  Future<void> deleteCategory(int id) async {
    return _db.transaction(() async {
      // Business rule: Set transactions to uncategorized instead of failing
      // (or you could throw an error like with accounts)
      await _db.customStatement(
        'UPDATE transactions SET category_id = NULL WHERE category_id = ?',
        [id],
      );

      await _db.categoriesDao.deleteCategory(id);
    });
  }

  /// Merges two categories (moves all transactions from one to another)
  Future<void> mergeCategories({
    required int fromCategoryId,
    required int toCategoryId,
  }) async {
    return _db.transaction(() async {
      // Move all transactions
      await _db.customStatement(
        'UPDATE transactions SET category_id = ? WHERE category_id = ?',
        [toCategoryId, fromCategoryId],
      );

      // Delete old category
      await _db.categoriesDao.deleteCategory(fromCategoryId);
    });
  }
}
