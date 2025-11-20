import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() => select(categories).watch();

  Future<Category?> getById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Category?> getByName(String name) =>
      (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();

  Future<int> insert(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<void> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  Future<void> deleteCategory(int id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }
}
