import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import 'db_provider.dart';

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.transactionsDao;
});

final transactionsForAccountProvider =
    StreamProvider.family<List<Transaction>, int>((ref, accountId) {
      final dao = ref.watch(transactionsDaoProvider);
      return dao.watchByAccount(accountId);
    });

final transactionsWithCategoryProvider =
    StreamProvider.family<
      List<({Transaction transaction, String? categoryName})>,
      int
    >((ref, accountId) {
      final dao = ref.watch(transactionsDaoProvider);
      return dao.watchWithCategoryNameByAccount(accountId);
    });
