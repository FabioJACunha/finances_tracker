import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  Future<int> insertCategory(CategoriesCompanion c) => into(categories).insert(c);

  Future<Category?> getCategoryByName(String name) {
    return (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();
  }

  Future<int> ensureCategory(String name) async {
    final existing = await getCategoryByName(name);
    if (existing != null) return existing.id;
    return await insertCategory(CategoriesCompanion(name: Value(name)));
  }
}