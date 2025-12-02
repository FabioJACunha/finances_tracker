import 'package:drift/drift.dart';
import '../database.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets, BudgetCategoryLinks])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Stream<List<Budget>> watchAll() {
    // Watch both tables - Drift will emit when either changes
    return customSelect(
      'SELECT * FROM budgets ORDER BY id',
      readsFrom: {budgets, budgetCategoryLinks},
    ).watch().map((rows) {
      return rows.map((row) => budgets.map(row.data)).toList();
    });
  }

  Future<Budget?> getById(int id) =>
      (select(budgets)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<int> insertBudget(BudgetsCompanion budget) =>
      into(budgets).insert(budget);

  Future<bool> updateBudget(BudgetsCompanion budget) =>
      update(budgets).replace(budget);

  Future<void> deleteBudget(int id) async {
    await batch((batch) {
      // Delete category links first
      batch.deleteWhere(budgetCategoryLinks, (row) => row.budgetId.equals(id));
      // Then delete the budget
      batch.deleteWhere(budgets, (b) => b.id.equals(id));
    });
  }

  /// Sets all categories for a given budget ID, clearing old ones in a batch.
  Future<void> setCategoriesForBudget(
    int budgetId,
    List<int> categoryIds,
  ) async {
    await batch((batch) {
      // 1. Delete old links
      batch.deleteWhere(
        budgetCategoryLinks,
        (row) => row.budgetId.equals(budgetId),
      );

      // 2. Insert new links
      if (categoryIds.isNotEmpty) {
        batch.insertAll(
          budgetCategoryLinks,
          categoryIds.map((catId) {
            return BudgetCategoryLinksCompanion.insert(
              budgetId: budgetId,
              categoryId: catId,
            );
          }).toList(),
        );
      }
    });
  }

  /// Gets the list of category IDs linked to a budget.
  Future<List<int>> getCategoryIdsForBudget(int budgetId) async {
    final query = select(budgetCategoryLinks)
      ..where((l) => l.budgetId.equals(budgetId));

    final result = await query.map((l) => l.categoryId).get();

    return result.cast<int>();
  }
}
