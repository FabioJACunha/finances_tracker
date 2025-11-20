import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import 'db_provider.dart';

// Service providers (for WRITE operations)
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionService(db);
});

final accountServiceProvider = Provider<AccountService>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountService(db);
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryService(db);
});
