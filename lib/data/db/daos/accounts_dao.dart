  import 'package:drift/drift.dart';
  import '../database.dart';
  import '../tables.dart';

  part 'accounts_dao.g.dart';

  @DriftAccessor(tables: [Accounts])
  class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
    AccountsDao(super.db);

    Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
    Future<int> insertAccount(AccountsCompanion a) => into(accounts).insert(a);
    Future<bool> updateAccountData(AccountsCompanion a) => update(accounts).replace(a);
    Future<void> adjustBalance(int accountId, double delta) async {
      final account = await (select(accounts)..where((a) => a.id.equals(accountId))).getSingle();
      await (update(accounts)..where((a) => a.id.equals(accountId)))
          .write(AccountsCompanion(balance: Value(account.balance + delta)));
    }
  }
