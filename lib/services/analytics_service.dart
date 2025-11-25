import '../data/db/database.dart';
import '../models/period_args.dart';

class AnalyticsService {
  final AppDatabase _db;

  AnalyticsService(this._db);

  /// Stream of expenses grouped by category for a period
  Stream<Map<String, double>> watchExpensesByCategory(PeriodArgs args) {
    return _db.transactionsDao.watchByAccountWithCategory(args.accountId).map((
      txns,
    ) {
      final filtered = txns.where((data) {
        final date = data.transaction.date;
        return data.transaction.type == TransactionType.expense &&
            !date.isBefore(args.start) &&
            !date.isAfter(args.end);
      }).toList();

      final map = <String, double>{};
      for (var data in filtered) {
        final cat = data.category?.name ?? 'Uncategorized';
        map[cat] = (map[cat] ?? 0.0) + data.transaction.amount;
      }

      return map;
    });
  }

  /// Stream of total income and expense for a period
  Stream<Map<String, double>> watchIncomeExpense(PeriodArgs args) {
    return _db.transactionsDao.watchByAccountWithCategory(args.accountId).map((
      txns,
    ) {
      double income = 0.0, expense = 0.0;

      for (var data in txns) {
        final date = data.transaction.date;
        if (!date.isBefore(args.start) && !date.isAfter(args.end)) {
          if (data.transaction.type == TransactionType.income) {
            income += data.transaction.amount;
          } else {
            expense += data.transaction.amount;
          }
        }
      }

      return {'income': income, 'expense': expense};
    });
  }

  /// Get top N expense categories for a period
  Future<List<MapEntry<String, double>>> getTopExpenseCategories(
    TopCategoriesArgs args,
  ) async {
    final stream = watchExpensesByCategory(
      PeriodArgs(accountId: args.accountId, start: args.start, end: args.end),
    );

    final map = await stream.first;
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(args.topN).toList();
  }

  /// Calculate net balance change (income - expense)
  Future<double> getNetBalanceChange(PeriodArgs args) async {
    final stream = watchIncomeExpense(args);
    final totals = await stream.first;
    return totals['income']! - totals['expense']!;
  }

  /// Calculate savings rate percentage
  Future<double> getSavingsRate(PeriodArgs args) async {
    final stream = watchIncomeExpense(args);
    final totals = await stream.first;

    if (totals['income']! == 0) return 0.0;

    return ((totals['income']! - totals['expense']!) / totals['income']!) * 100;
  }

  /// Stream of balance evolution over time
  Stream<List<MapEntry<DateTime, double>>> watchBalanceEvolution(
    PeriodArgs args,
  ) {
    return _db.transactionsDao.watchByAccount(args.accountId).map((txns) {
      // Filter by start/end
      final filtered = txns
          .where(
            (t) => !t.date.isBefore(args.start) && !t.date.isAfter(args.end),
          )
          .toList();

      // Sort by date
      filtered.sort((a, b) => a.date.compareTo(b.date));

      double balance = 0.0;
      final runningBalance = <MapEntry<DateTime, double>>[];

      for (var t in filtered) {
        if (t.type == TransactionType.income) {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }
        runningBalance.add(MapEntry(t.date, balance));
      }

      return runningBalance;
    });
  }
}
