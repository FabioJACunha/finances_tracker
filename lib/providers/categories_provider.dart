import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../services/category_service.dart';
import 'db_provider.dart';

// DAO provider (direct access to data layer)
final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao;
});

// Service provider (business logic layer)
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryService(db);
});

// Stream provider for READ operations (watching all categories)
final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  final dao = ref.watch(categoriesDaoProvider);
  return dao.watchAll();
});

// Stream provider for watching categories by transaction type
final categoriesByTypeProvider =
StreamProvider.family<List<Category>, TransactionType>((
    ref,
    transactionType,
    ) {
  final service = ref.watch(categoryServiceProvider);
  return service.watchCategoriesForTransactionType(transactionType);
});

// Future provider for getting a specific category by ID
final categoryByIdProvider = FutureProvider.family<Category?, int>((ref, id) {
  final dao = ref.watch(categoriesDaoProvider);
  return dao.getById(id);
});

// Provider for category colors map (name -> Color)
final categoryColorsMapProvider = StreamProvider<Map<String, Color>>((
    ref,
    ) async* {
  final categories = ref.watch(categoriesListProvider);

  yield* categories.when(
    data: (cats) async* {
      final colorMap = <String, Color>{};
      for (final cat in cats) {
        colorMap[cat.name] = Color(cat.colorValue);
      }
      yield colorMap;
    },
    loading: () async* {
      yield <String, Color>{};
    },
    error: (_, _) async* {
      yield <String, Color>{};
    },
  );
});

// Provider for category icons map (name -> IconData)
final categoryIconsMapProvider = StreamProvider<Map<String, IconData>>((
    ref,
    ) async* {
  final categories = ref.watch(categoriesListProvider);

  yield* categories.when(
    data: (cats) async* {
      final iconMap = <String, IconData>{};
      for (final cat in cats) {
        iconMap[cat.name] = IconData(
          cat.iconCodePoint,
          fontFamily: 'MaterialIcons',
        );
      }
      yield iconMap;
    },
    loading: () async* {
      yield <String, IconData>{};
    },
    error: (_, _) async* {
      yield <String, IconData>{};
    },
  );
});

// Provider for only EXPENSE-related categories (for the budget form)
// CHANGE: Now returns AsyncValue<List<Category>> to support .when() in the UI.
final expenseCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final categoriesAsync = ref.watch(categoriesListProvider);

  return categoriesAsync.when(
    data: (categories) {
      final filteredList = categories
          .where((c) =>
      c.usageType == CategoryUsageType.expense ||
          c.usageType == CategoryUsageType.both)
          .toList();
      // Return the filtered list wrapped in AsyncValue.data
      return AsyncValue.data(filteredList);
    },
    // Propagate loading and error states
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});