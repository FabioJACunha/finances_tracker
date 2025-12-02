import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../services/budget_service.dart';
import 'db_provider.dart';
import 'transactions_provider.dart';
import 'categories_provider.dart';
import 'package:flutter/material.dart';

// DAO provider
final budgetsDaoProvider = Provider<BudgetsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.budgetsDao;
});

// Service provider
final budgetServiceProvider = Provider<BudgetService>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetService(db);
});

// Stream provider for the list of all budgets
final budgetsListProvider = StreamProvider<List<Budget>>((ref) {
  final dao = ref.watch(budgetsDaoProvider);
  return dao.watchAll();
});

// --- Helper function to get date range ---
DateTimeRange _getBudgetDateRange(BudgetPeriod period) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;

  if (period == BudgetPeriod.weekly) {
    // Assuming week starts on Monday
    final weekday = now.weekday;
    start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weekday - 1));
    end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  } else {
    // Monthly
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // Last day of month
  }
  return DateTimeRange(start: start, end: end);
}

// --- Provider to calculate spending for a SINGLE budget (Updated) ---
final budgetSpentProvider = StreamProvider.autoDispose.family<double, Budget>((
  ref,
  budget,
) async* {
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final dao = ref.watch(budgetsDaoProvider);
  final range = _getBudgetDateRange(budget.period);

  // Get the list of category IDs linked to the budget
  final categoryIds = await dao.getCategoryIdsForBudget(budget.id);

  // Watch filtered transactions stream
  final transactionsStream = transactionsDao.watchFilteredTransactions(
    accountId: budget.accountId,
    startDate: range.start,
    endDate: range.end,
    categoryIds: categoryIds,
  );

  await for (final transactions in transactionsStream) {
    // Calculate total spending for the budget's account, period, and categories
    final totalSpent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (previousValue, element) => previousValue + element.amount);

    yield totalSpent;
  }
});

// --- NEW PROVIDER: Stream provider that watches category changes ---
final budgetCategoriesProvider = StreamProvider.autoDispose
    .family<List<Category>, int>((ref, budgetId) async* {
      final budgetsDao = ref.watch(budgetsDaoProvider);
      final categoriesDao = ref.watch(categoriesDaoProvider);

      // Watch the budgets DAO's watchAll stream directly to trigger updates when links change
      await for (final _ in budgetsDao.watchAll()) {
        // Fetch current category IDs for this budget
        final categoryIds = await budgetsDao.getCategoryIdsForBudget(budgetId);

        if (categoryIds.isEmpty) {
          yield [];
          continue;
        }

        // Fetch all Category objects concurrently
        final futures = categoryIds.map((id) {
          return categoriesDao.getById(id);
        }).toList();

        final categories = await Future.wait(futures);

        // Filter out any null categories
        yield categories.whereType<Category>().toList();
      }
    });
