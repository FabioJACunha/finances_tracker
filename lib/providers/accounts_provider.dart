import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import 'db_provider.dart';

final accountsDaoProvider = Provider<AccountsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao;
});

final accountsListProvider = StreamProvider<List<Account>>((ref) {
  final dao = ref.watch(accountsDaoProvider);
  return dao.watchAllAccounts();
});
