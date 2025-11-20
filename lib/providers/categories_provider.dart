import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import 'db_provider.dart';

// DAO provider (direct access to data layer)
final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao;
});

// Stream provider for READ operations (watching data)
final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  final dao = ref.watch(categoriesDaoProvider);
  return dao.watchAll();
});
