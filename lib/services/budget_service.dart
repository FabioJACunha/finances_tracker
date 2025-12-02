import 'package:drift/drift.dart';
import '../data/db/database.dart';

class BudgetService {
  final AppDatabase _db;

  BudgetService(this._db);

  Future<int> createBudget({
    required String label,
    required double limit,
    required int accountId,
    required BudgetPeriod period,
    required List<int> categoryIds,
  }) async {
    // 1. Insert main budget
    final budgetId = await _db.budgetsDao.insertBudget(
      BudgetsCompanion.insert(
        label: label,
        limit: limit,
        accountId: accountId,
        period: period,
      ),
    );
    // 2. Insert links
    await _db.budgetsDao.setCategoriesForBudget(budgetId, categoryIds);
    return budgetId;
  }

  Future<void> updateBudget({
    required int id,
    required String label,
    required double limit,
    required int accountId,
    required BudgetPeriod period,
    required List<int> categoryIds,
  }) async {
    // Execute both updates in a transaction to ensure atomicity
    await _db.transaction(() async {
      // 1. Update main budget (using update instead of replace to ensure write happens)
      await (_db.update(_db.budgets)..where((b) => b.id.equals(id))).write(
        BudgetsCompanion(
          label: Value(label),
          limit: Value(limit),
          accountId: Value(accountId),
          period: Value(period),
        ),
      );

      // 2. Update links
      await _db.budgetsDao.setCategoriesForBudget(id, categoryIds);
    });
  }

  Future<void> deleteBudget(int id) async {
    return _db.budgetsDao.deleteBudget(id);
  }
}
