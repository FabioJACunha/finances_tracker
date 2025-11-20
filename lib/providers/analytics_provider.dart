import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../models/period_args.dart';
import '../helpers/category_colors.dart';
import 'db_provider.dart';

// Service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final db = ref.watch(databaseProvider);
  return AnalyticsService(db);
});

// Category colors provider
final categoryColorProvider = Provider<Map<String, Color>>(
  (ref) => categoryColors,
);

// Stream providers for reactive data
final expensesByCategoryProvider =
    StreamProvider.family<Map<String, double>, PeriodArgs>((ref, args) {
      final service = ref.watch(analyticsServiceProvider);
      return service.watchExpensesByCategory(args);
    });

final incomeExpenseProvider = StreamProvider.family
    .autoDispose<Map<String, double>, PeriodArgs>((ref, args) {
      final service = ref.watch(analyticsServiceProvider);
      return service.watchIncomeExpense(args);
    });

final balanceEvolutionProvider =
    StreamProvider.family<List<MapEntry<DateTime, double>>, PeriodArgs>((
      ref,
      args,
    ) {
      final service = ref.watch(analyticsServiceProvider);
      return service.watchBalanceEvolution(args);
    });

// Future providers for computed values
final topExpenseCategoriesProvider = FutureProvider.family
    .autoDispose<List<MapEntry<String, double>>, TopCategoriesArgs>((
      ref,
      args,
    ) {
      final service = ref.watch(analyticsServiceProvider);
      return service.getTopExpenseCategories(args);
    });

final netBalanceChangeProvider = FutureProvider.family
    .autoDispose<double, PeriodArgs>((ref, args) {
      final service = ref.watch(analyticsServiceProvider);
      return service.getNetBalanceChange(args);
    });

final savingsRateProvider = FutureProvider.family
    .autoDispose<double, PeriodArgs>((ref, args) {
      final service = ref.watch(analyticsServiceProvider);
      return service.getSavingsRate(args);
    });
