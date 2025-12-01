import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../data/db/daos/transactions_dao.dart';
import '../models/period_args.dart';
import 'db_provider.dart';

// DAO provider (direct access to data layer)
final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.transactionsDao;
});

// Stream provider for READ operations (watching data with category info)
final transactionsWithCategoryProvider =
    StreamProvider.family<List<TransactionWithCategory>, int>((ref, accountId) {
      final dao = ref.watch(transactionsDaoProvider);
      return dao.watchByAccountWithCategory(accountId);
    });

// Stream provider for transactions with date range filtering
final transactionsWithCategoryInRangeProvider =
    StreamProvider.family<List<TransactionWithCategory>, TransactionRangeArgs>((
      ref,
      args,
    ) {
      final dao = ref.watch(transactionsDaoProvider);
      return dao.watchByAccountWithCategoryInRange(
        args.accountId,
        args.start,
        args.end,
      );
    });
