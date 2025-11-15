import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/tables.dart';
import '../../providers/transactions_provider.dart';
import 'package:flutter/material.dart';

/// Fixed colors for categories
const Map<String, Color> categoryColors = {
  'Food & Drink': Colors.orange,
  'Transport': Colors.blue,
  'Shopping': Colors.purple,
  'Salary': Colors.green,
  'Freelance': Colors.teal,
  'Bills': Colors.red,
  'Uncategorized': Colors.grey,
};

final categoryColorProvider = Provider<Map<String, Color>>(
  (ref) => categoryColors,
);

/// ----- Parameter Classes -----
class PeriodArgs {
  final int accountId;
  final DateTime start;
  final DateTime end;

  PeriodArgs({required this.accountId, required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodArgs &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(accountId, start, end);
}

class TopCategoriesArgs {
  final int accountId;
  final DateTime start;
  final DateTime end;
  final int topN;

  TopCategoriesArgs({
    required this.accountId,
    required this.start,
    required this.end,
    required this.topN,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopCategoriesArgs &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          start == other.start &&
          end == other.end &&
          topN == other.topN;

  @override
  int get hashCode => Object.hash(accountId, start, end, topN);
}

/// ----- Providers -----

/// Aggregated expenses by category
final expensesByCategoryProvider =
    StreamProvider.family<Map<String, double>, PeriodArgs>((ref, args) {
      final dao = ref.read(transactionsDaoProvider);

      return dao.watchWithCategoryNameByAccount(args.accountId).map((txns) {
        final filtered = txns.where((t) {
          final date = t.transaction.date;
          return t.transaction.type == TransactionType.expense &&
              !date.isBefore(args.start) &&
              !date.isAfter(args.end);
        }).toList();

        final map = <String, double>{};
        for (var t in filtered) {
          final cat = t.categoryName ?? 'Uncategorized';
          map[cat] = (map[cat] ?? 0.0) + t.transaction.amount;
        }

        return map;
      });
    });

final incomeExpenseProvider = StreamProvider.family
    .autoDispose<Map<String, double>, PeriodArgs>((ref, args) {
      final dao = ref.read(transactionsDaoProvider);

      return dao.watchWithCategoryNameByAccount(args.accountId).map((txns) {
        double income = 0.0, expense = 0.0;
        for (var t in txns) {
          final date = t.transaction.date;
          if (!date.isBefore(args.start) && !date.isAfter(args.end)) {
            if (t.transaction.type == TransactionType.income) {
              income += t.transaction.amount;
            } else {
              expense += t.transaction.amount;
            }
          }
        }
        return {'income': income, 'expense': expense};
      });
    });

/// Top N expense categories - Use autoDispose
final topExpenseCategoriesProvider = FutureProvider.family
    .autoDispose<List<MapEntry<String, double>>, TopCategoriesArgs>((
      ref,
      args,
    ) async {
      // Watch the stream provider directly
      final mapAsync = ref.watch(
        expensesByCategoryProvider(
          PeriodArgs(
            accountId: args.accountId,
            start: args.start,
            end: args.end,
          ),
        ),
      );

      // Wait for the data
      final map = mapAsync.when(
        data: (data) => data,
        loading: () => <String, double>{},
        error: (_, _) => <String, double>{},
      );

      final sortedEntries = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedEntries.take(args.topN).toList();
    });

/// Net balance change - Use autoDispose
final netBalanceChangeProvider = FutureProvider.family
    .autoDispose<double, PeriodArgs>((ref, args) async {
      final totals = await ref.watch(incomeExpenseProvider(args).future);
      return totals['income']! - totals['expense']!;
    });

/// Savings rate % (income not spent) - Use autoDispose
final savingsRateProvider = FutureProvider.family
    .autoDispose<double, PeriodArgs>((ref, args) async {
      final totals = await ref.watch(incomeExpenseProvider(args).future);
      if (totals['income']! == 0) return 0.0;
      return ((totals['income']! - totals['expense']!) / totals['income']!) *
          100;
    });

final balanceEvolutionProvider =
    StreamProvider.family<List<MapEntry<DateTime, double>>, PeriodArgs>((
      ref,
      args,
    ) {
      final dao = ref.read(transactionsDaoProvider);

      return dao.watchByAccount(args.accountId).map((txns) {
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
    });
