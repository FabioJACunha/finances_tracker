import 'package:drift/drift.dart';
import '../data/db/database.dart';
import '../data/db/tables.dart';

class TransactionService {
  final AppDatabase _db;

  TransactionService(this._db);

  /// Creates a transaction with proper business logic:
  /// - Ensures category exists (creates if needed)
  /// - Updates account balance
  /// - All wrapped in a database transaction
  Future<int> createTransaction({
    required int accountId,
    required double amount,
    required TransactionType type,
    String? title,
    String? description,
    String? categoryName,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      // 1. Handle category (if provided)
      int? categoryId;
      if (categoryName != null && categoryName.trim().isNotEmpty) {
        categoryId = await _ensureCategory(categoryName.trim());
      }

      // 2. Insert transaction
      final transactionId = await _db.transactionsDao.insert(
        TransactionsCompanion.insert(
          accountId: accountId,
          amount: amount,
          type: type,
          title: Value(title),
          description: Value(description),
          categoryId: Value(categoryId),
          date: date ?? DateTime.now(),
          currency: const Value('EUR'),
        ),
      );

      // 3. Update account balance
      await _updateAccountBalance(accountId, amount, type);

      return transactionId;
    });
  }

  /// Deletes a transaction and reverses the account balance change
  Future<void> deleteTransaction(int transactionId) async {
    return _db.transaction(() async {
      final transaction = await _db.transactionsDao.getById(transactionId);
      if (transaction == null) return;

      // Reverse the balance change
      final reverseAmount = transaction.amount;
      final reverseType = transaction.type == TransactionType.income
          ? TransactionType.expense
          : TransactionType.income;

      await _updateAccountBalance(
        transaction.accountId,
        reverseAmount,
        reverseType,
      );

      // Delete the transaction
      await _db.transactionsDao.deleteTransaction(transactionId);
    });
  }

  /// Updates a transaction and adjusts account balance accordingly
  Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required double amount,
    required TransactionType type,
    String? title,
    String? description,
    String? categoryName,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      // Get old transaction to reverse its balance effect
      final oldTransaction = await _db.transactionsDao.getById(transactionId);
      if (oldTransaction == null) return;

      // Reverse old balance change
      final reverseType = oldTransaction.type == TransactionType.income
          ? TransactionType.expense
          : TransactionType.income;
      await _updateAccountBalance(
        oldTransaction.accountId,
        oldTransaction.amount,
        reverseType,
      );

      // Handle category
      int? categoryId;
      if (categoryName != null && categoryName.trim().isNotEmpty) {
        categoryId = await _ensureCategory(categoryName.trim());
      }

      // Update transaction
      await _db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: Value(transactionId),
          accountId: Value(accountId),
          amount: Value(amount),
          type: Value(type),
          title: Value(title),
          description: Value(description),
          categoryId: Value(categoryId),
          date: Value(date ?? DateTime.now()),
          currency: const Value('EUR'),
        ),
      );

      // Apply new balance change
      await _updateAccountBalance(accountId, amount, type);
    });
  }

  // Private helper methods
  Future<int> _ensureCategory(String name) async {
    final existing = await _db.categoriesDao.getByName(name);
    if (existing != null) return existing.id;

    return await _db.categoriesDao.insert(
      CategoriesCompanion.insert(name: name),
    );
  }

  Future<void> _updateAccountBalance(
    int accountId,
    double amount,
    TransactionType type,
  ) async {
    final account = await _db.accountsDao.getById(accountId);
    final delta = type == TransactionType.income ? amount : -amount;
    final newBalance = account.balance + delta;

    await _db.accountsDao.updateBalance(accountId, newBalance);
  }
}
