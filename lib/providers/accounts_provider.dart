import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import 'db_provider.dart';

// DAO provider (direct access to data layer)
final accountsDaoProvider = Provider<AccountsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao;
});

// Stream provider for READ operations (watching data)
final accountsListProvider = StreamProvider<List<Account>>((ref) {
  final dao = ref.watch(accountsDaoProvider);
  return dao.watchAll();
});

// Computed provider: total balance across all accounts
final totalBalanceProvider = Provider<double>((ref) {
  final accountsAsync = ref.watch(accountsListProvider);
  return accountsAsync.maybeWhen(
    data: (accounts) => accounts
        .where((account) => !account.excludeFromTotal)
        .fold(0.0, (sum, account) => sum + account.balance),
    orElse: () => 0.0,
  );
});