import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Stream<List<Account>> watchAll() => select(accounts).watch();

  Future<Account> getById(int id) =>
      (select(accounts)..where((a) => a.id.equals(id))).getSingle();

  Future<Account?> getByIdOrNull(int id) =>
      (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insert(AccountsCompanion account) =>
      into(accounts).insert(account);

  Future<bool> updateAccount(AccountsCompanion account) =>
      update(accounts).replace(account);

  Future<void> updateBalance(int accountId, double newBalance) async {
    await (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(balance: Value(newBalance)),
    );
  }

  Future<void> deleteAccount(int id) async {
    await (delete(accounts)..where((a) => a.id.equals(id))).go();
  }
}
