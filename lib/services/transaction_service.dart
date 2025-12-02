import 'package:drift/drift.dart';
import '../data/db/database.dart';

class TransactionService {
  final AppDatabase _db;

  TransactionService(this._db);

  /// Creates a transaction and updates resultant balances
  Future<int> createTransaction({
    required int accountId,
    required double amount,
    required TransactionType type,
    String? title,
    String? description,
    int? categoryId,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      // Validate category usage type if provided
      if (categoryId != null) {
        await _validateCategoryUsage(categoryId, type);
      }

      final transactionDate = date ?? DateTime.now();

      // Calculate the resultant balance for this transaction
      final resultantBalance = await _calculateResultantBalance(
        accountId: accountId,
        date: transactionDate,
        amount: amount,
        type: type,
      );

      // Insert transaction with resultant balance
      final transactionId = await _db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: accountId,
          amount: amount,
          type: type,
          title: Value(title),
          description: Value(description),
          categoryId: Value(categoryId),
          date: transactionDate,
          currency: const Value('EUR'),
          resultantBalance: Value(resultantBalance),
        ),
      );

      // Update resultant balances for all transactions after this one
      await _recalculateBalancesAfter(accountId, transactionDate);

      // Update account balance (final balance = last transaction's resultant balance)
      await _updateAccountBalance(accountId);

      return transactionId;
    });
  }

  /// Deletes a transaction and recalculates affected balances
  Future<void> deleteTransaction(int transactionId) async {
    return _db.transaction(() async {
      final transaction = await _db.transactionsDao.getById(transactionId);
      if (transaction == null) return;

      final accountId = transaction.accountId;
      final transactionDate = transaction.date;

      // Delete the transaction
      await _db.transactionsDao.deleteTransaction(transactionId);

      // Recalculate balances for all transactions after this one
      await _recalculateBalancesAfter(accountId, transactionDate);

      // Update account balance
      await _updateAccountBalance(accountId);
    });
  }

  /// Updates a transaction and recalculates affected balances
  Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required double amount,
    required TransactionType type,
    String? title,
    String? description,
    int? categoryId,
    DateTime? date,
  }) async {
    return _db.transaction(() async {
      final oldTransaction = await _db.transactionsDao.getById(transactionId);
      if (oldTransaction == null) return;

      // Validate category usage type if provided
      if (categoryId != null) {
        await _validateCategoryUsage(categoryId, type);
      }

      final transactionDate = date ?? DateTime.now();

      // Determine the earliest affected date
      final earliestDate = oldTransaction.date.isBefore(transactionDate)
          ? oldTransaction.date
          : transactionDate;

      // Calculate resultant balance for the updated transaction
      final resultantBalance = await _calculateResultantBalanceExcluding(
        accountId: accountId,
        date: transactionDate,
        amount: amount,
        type: type,
        excludeTransactionId: transactionId,
      );

      // Update the transaction
      await _db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: Value(transactionId),
          accountId: Value(accountId),
          amount: Value(amount),
          type: Value(type),
          title: Value(title),
          description: Value(description),
          categoryId: Value(categoryId),
          date: Value(transactionDate),
          currency: const Value('EUR'),
          resultantBalance: Value(resultantBalance),
        ),
      );

      // Recalculate balances from the earliest affected date
      await _recalculateBalancesAfter(accountId, earliestDate);

      // If account changed, also update the old account
      if (oldTransaction.accountId != accountId) {
        await _recalculateBalancesAfter(
          oldTransaction.accountId,
          oldTransaction.date,
        );
        await _updateAccountBalance(oldTransaction.accountId);
      }

      // Update account balance
      await _updateAccountBalance(accountId);
    });
  }

  /// Validates that a category can be used with a transaction type
  Future<void> _validateCategoryUsage(
    int categoryId,
    TransactionType type,
  ) async {
    final category = await _db.categoriesDao.getById(categoryId);

    if (category == null) {
      throw Exception('Category not found');
    }

    // Check if category usage type is compatible
    if (category.usageType == CategoryUsageType.both) {
      // 'both' is always compatible
      return;
    }

    final isExpense = type == TransactionType.expense;
    final categoryIsForExpense =
        category.usageType == CategoryUsageType.expense;

    if (isExpense != categoryIsForExpense) {
      final typeName = isExpense ? 'expense' : 'income';
      throw Exception(
        'Category "${category.name}" cannot be used for $typeName transactions',
      );
    }
  }

  /// Calculate what the resultant balance should be for a new transaction
  Future<double> _calculateResultantBalance({
    required int accountId,
    required DateTime date,
    required double amount,
    required TransactionType type,
  }) async {
    // Get the transaction immediately before this date
    final previousTransaction = await _db.transactionsDao
        .getLastTransactionBefore(accountId, date);

    // Starting balance is either previous transaction's resultant balance or 0
    final startingBalance = previousTransaction?.resultantBalance ?? 0.0;

    // Calculate new balance
    return type == TransactionType.income
        ? startingBalance + amount
        : startingBalance - amount;
  }

  /// Calculate resultant balance excluding a specific transaction (for updates)
  Future<double> _calculateResultantBalanceExcluding({
    required int accountId,
    required DateTime date,
    required double amount,
    required TransactionType type,
    required int excludeTransactionId,
  }) async {
    // Get all transactions before this date, excluding the one being updated
    final allTransactions = await _db.transactionsDao
        .getByAccountIdOrderedByDate(accountId);

    double balance = 0.0;
    for (final tx in allTransactions) {
      if (tx.id == excludeTransactionId) continue;
      if (!tx.date.isBefore(date)) break;

      balance += tx.type == TransactionType.income ? tx.amount : -tx.amount;
    }

    // Add the current transaction's effect
    return type == TransactionType.income ? balance + amount : balance - amount;
  }

  /// Recalculate resultant balances for all transactions after a given date
  Future<void> _recalculateBalancesAfter(
    int accountId,
    DateTime afterDate,
  ) async {
    // Get the balance right before afterDate
    final previousTransaction = await _db.transactionsDao
        .getLastTransactionBefore(accountId, afterDate);
    double runningBalance = previousTransaction?.resultantBalance ?? 0.0;

    // Get all transactions from afterDate onwards, ordered by date
    final transactionsToUpdate = await _db.transactionsDao
        .getTransactionsAfterDate(
          accountId,
          afterDate.subtract(const Duration(seconds: 1)),
        );

    // Update each transaction's resultant balance
    for (final tx in transactionsToUpdate) {
      runningBalance += tx.type == TransactionType.income
          ? tx.amount
          : -tx.amount;

      await _db.transactionsDao.updateResultantBalance(tx.id, runningBalance);
    }
  }

  /// Update account balance to match the latest transaction's resultant balance
  Future<void> _updateAccountBalance(int accountId) async {
    final allTransactions = await _db.transactionsDao
        .getByAccountIdOrderedByDate(accountId);

    if (allTransactions.isEmpty) {
      await _db.accountsDao.updateBalance(accountId, 0.0);
    } else {
      // The last transaction's resultant balance is the current account balance
      final lastTransaction = allTransactions.last;
      await _db.accountsDao.updateBalance(
        accountId,
        lastTransaction.resultantBalance,
      );
    }
  }
}
