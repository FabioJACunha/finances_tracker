import '../data/db/database.dart';
import 'package:drift/drift.dart';

class AccountService {
  final AppDatabase _db;

  AccountService(this._db);

  /// Creates a new account
  Future<int> createAccount({
    required String name,
    double initialBalance = 0.0,
    bool excludeFromTotal = false,
  }) async {
    return await _db.accountsDao.insert(
      AccountsCompanion.insert(
        name: name,
        balance: Value(initialBalance),
        excludeFromTotal: Value(excludeFromTotal),
      ),
    );
  }

  /// Updates account details (not balance - use transactions for that)
  Future<void> updateAccount({
    required int id,
    String? name,
    bool? excludeFromTotal,
  }) async {
    await _db.accountsDao.updateAccount(
      AccountsCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        excludeFromTotal: excludeFromTotal != null
            ? Value(excludeFromTotal)
            : const Value.absent(),
      ),
    );
  }

  /// Deletes an account (you might want to add business rules here)
  Future<void> deleteAccount(int id) async {
    return _db.transaction(() async {
      // Business rule: Check if account has transactions
      final transactions = await _db.transactionsDao.getByAccountIdOrderedByDate(id);
      if (transactions.isNotEmpty) {
        throw Exception('Cannot delete account with existing transactions');
      }

      await _db.accountsDao.deleteAccount(id);
    });
  }

  /// Transfers money between accounts
  Future<void> transferBetweenAccounts({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? description,
  }) async {
    return _db.transaction(() async {
      // Create expense in source account
      await _db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: fromAccountId,
          amount: amount,
          type: TransactionType.expense,
          title: Value('Transfer to account'),
          description: Value(description),
          date: DateTime.now(),
          currency: const Value('EUR'),
        ),
      );

      // Update source balance
      final fromAccount = await _db.accountsDao.getById(fromAccountId);
      await _db.accountsDao.updateBalance(
        fromAccountId,
        fromAccount.balance - amount,
      );

      // Create income in destination account
      await _db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: toAccountId,
          amount: amount,
          type: TransactionType.income,
          title: Value('Transfer from account'),
          description: Value(description),
          date: DateTime.now(),
          currency: const Value('EUR'),
        ),
      );

      // Update destination balance
      final toAccount = await _db.accountsDao.getById(toAccountId);
      await _db.accountsDao.updateBalance(
        toAccountId,
        toAccount.balance + amount,
      );
    });
  }
}
