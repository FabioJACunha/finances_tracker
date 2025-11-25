import '../data/db/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color, IconData, Icons;

class CategoryService {
  final AppDatabase _db;

  CategoryService(this._db);

  /// Creates a new category
  Future<int> createCategory({
    required String name,
    IconData? icon,
    Color? color,
    CategoryUsageType? usageType,
  }) async {
    // Business rule: Check for duplicates
    final existing = await _db.categoriesDao.getByName(name.trim());
    if (existing != null) {
      throw Exception('Category "$name" already exists');
    }

    // Use defaults if not provided
    final finalIcon = icon ?? Icons.category;
    final finalColor = color ?? const Color(0xFF6200EE);
    final finalUsageType = usageType ?? CategoryUsageType.both;

    return await _db.categoriesDao.insert(
      CategoriesCompanion.insert(
        name: name.trim(),
        iconCodePoint: finalIcon.codePoint,
        colorValue: finalColor.toARGB32(),
        usageType: finalUsageType,
      ),
    );
  }

  /// Updates a category
  Future<void> updateCategory({
    required int id,
    String? newName,
    IconData? newIcon,
    Color? newColor,
    CategoryUsageType? newUsageType,
  }) async {
    // Get existing category to preserve unchanged values
    final existing = await _db.categoriesDao.getById(id);
    if (existing == null) {
      throw Exception('Category not found');
    }

    // Business rule: Check for duplicate names if name is being changed
    if (newName != null && newName.trim() != existing.name) {
      final duplicate = await _db.categoriesDao.getByName(newName.trim());
      if (duplicate != null && duplicate.id != id) {
        throw Exception('Category "$newName" already exists');
      }
    }

    // Business rule: Check if usage type change is compatible with existing transactions
    if (newUsageType != null && newUsageType != existing.usageType) {
      await _validateUsageTypeChange(id, newUsageType);
    }

    await _db.categoriesDao.updateCategory(
      CategoriesCompanion(
        id: Value(id),
        name: newName != null ? Value(newName.trim()) : Value(existing.name),
        iconCodePoint: newIcon != null
            ? Value(newIcon.codePoint)
            : Value(existing.iconCodePoint),
        colorValue: newColor != null
            ? Value(newColor.toARGB32())
            : Value(existing.colorValue),
        usageType: newUsageType != null
            ? Value(newUsageType)
            : Value(existing.usageType),
      ),
    );
  }

  /// Validates if usage type change is compatible with existing transactions
  Future<void> _validateUsageTypeChange(
    int categoryId,
    CategoryUsageType newUsageType,
  ) async {
    if (newUsageType == CategoryUsageType.both) {
      // 'both' is always compatible
      return;
    }

    // Check if there are transactions of incompatible type
    final incompatibleType = newUsageType == CategoryUsageType.expense
        ? TransactionType.income
        : TransactionType.expense;

    final incompatibleCount =
        await (_db.selectOnly(_db.transactions)
              ..addColumns([_db.transactions.id.count()])
              ..where(_db.transactions.categoryId.equals(categoryId))
              ..where(_db.transactions.type.equals(incompatibleType.index)))
            .getSingle();

    final count = incompatibleCount.read(_db.transactions.id.count()) ?? 0;

    if (count > 0) {
      final typeName = incompatibleType == TransactionType.income
          ? 'income'
          : 'expense';
      throw Exception(
        'Cannot change usage type: category has $count $typeName transaction(s). Reassign them first.',
      );
    }
  }

  /// Deletes a category (fails if it has associated transactions)
  Future<void> deleteCategory(int id) async {
    // Business rule: Cannot delete if transactions exist
    final canDelete = await _db.categoriesDao.canDelete(id);
    if (!canDelete) {
      final count = await _db.categoriesDao.getTransactionCount(id);
      throw Exception(
        'Cannot delete category: it has $count associated transaction(s). Please reassign or delete those transactions first.',
      );
    }

    await _db.categoriesDao.deleteCategory(id);
  }

  /// Merges two categories (moves all transactions from one to another)
  Future<void> mergeCategories({
    required int fromCategoryId,
    required int toCategoryId,
  }) async {
    if (fromCategoryId == toCategoryId) {
      throw Exception('Cannot merge a category with itself');
    }

    // Verify both categories exist
    final fromCategory = await _db.categoriesDao.getById(fromCategoryId);
    final toCategory = await _db.categoriesDao.getById(toCategoryId);

    if (fromCategory == null || toCategory == null) {
      throw Exception('One or both categories not found');
    }

    return _db.transaction(() async {
      // Business rule: Target category must support all transaction types from source
      if (toCategory.usageType != CategoryUsageType.both) {
        // Check if fromCategory has incompatible transactions
        final incompatibleType =
            toCategory.usageType == CategoryUsageType.expense
            ? TransactionType.income
            : TransactionType.expense;

        final incompatibleCount =
            await (_db.selectOnly(_db.transactions)
                  ..addColumns([_db.transactions.id.count()])
                  ..where(_db.transactions.categoryId.equals(fromCategoryId))
                  ..where(_db.transactions.type.equals(incompatibleType.index)))
                .getSingle();

        final count = incompatibleCount.read(_db.transactions.id.count()) ?? 0;

        if (count > 0) {
          final typeName = incompatibleType == TransactionType.income
              ? 'income'
              : 'expense';
          throw Exception(
            'Cannot merge: target category does not support $typeName transactions, but source has $count $typeName transaction(s).',
          );
        }
      }

      // Move all transactions
      await _db.customStatement(
        'UPDATE transactions SET category_id = ? WHERE category_id = ?',
        [toCategoryId, fromCategoryId],
      );

      // Delete old category
      await _db.categoriesDao.deleteCategory(fromCategoryId);
    });
  }

  /// Gets categories filtered by transaction type
  Future<List<Category>> getCategoriesForTransactionType(
    TransactionType type,
  ) async {
    final usageType = type == TransactionType.expense
        ? CategoryUsageType.expense
        : CategoryUsageType.income;
    return await _db.categoriesDao.getByUsageType(usageType);
  }

  /// Watches categories filtered by transaction type
  Stream<List<Category>> watchCategoriesForTransactionType(
    TransactionType type,
  ) {
    final usageType = type == TransactionType.expense
        ? CategoryUsageType.expense
        : CategoryUsageType.income;
    return _db.categoriesDao.watchByUsageType(usageType);
  }
}
