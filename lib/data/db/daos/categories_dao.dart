import 'package:drift/drift.dart';
import '../database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // READ operations
  Stream<List<Category>> watchAll() => select(categories).watch();

  Future<List<Category>> getAll() => select(categories).get();

  Future<Category?> getById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Category?> getByName(String name) =>
      (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();

  Stream<List<Category>> watchByUsageType(CategoryUsageType usageType) {
    return (select(categories)
      ..where((c) =>
      c.usageType.equals(usageType.index) |
      c.usageType.equals(CategoryUsageType.both.index)))
        .watch();
  }

  Future<List<Category>> getByUsageType(CategoryUsageType usageType) {
    return (select(categories)
      ..where((c) =>
      c.usageType.equals(usageType.index) |
      c.usageType.equals(CategoryUsageType.both.index)))
        .get();
  }

  // CREATE operation
  Future<int> insert(CategoriesCompanion category) =>
      into(categories).insert(category);

  // UPDATE operation
  Future<void> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  // DELETE operation - checks for associated transactions first
  Future<bool> canDelete(int id) async {
    final count = await (selectOnly(transactions)
      ..addColumns([transactions.id.count()])
      ..where(transactions.categoryId.equals(id)))
        .getSingle();
    return count.read(transactions.id.count()) == 0;
  }

  Future<int> getTransactionCount(int id) async {
    final count = await (selectOnly(transactions)
      ..addColumns([transactions.id.count()])
      ..where(transactions.categoryId.equals(id)))
        .getSingle();
    return count.read(transactions.id.count()) ?? 0;
  }

  Future<void> deleteCategory(int id) async {
    final hasTransactions = !(await canDelete(id));
    if (hasTransactions) {
      throw Exception(
          'Cannot delete category: it has associated transactions. Please reassign or delete those transactions first.');
    }
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }
}