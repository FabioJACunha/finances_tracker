import 'package:drift/drift.dart';
import '../database.dart';

part 'transactions_dao.g.dart';

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;

  TransactionWithCategory({required this.transaction, this.category});
}

@DriftAccessor(tables: [Transactions, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // Basic CRUD
  Stream<List<Transaction>> watchByAccount(int accountId) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Stream<List<TransactionWithCategory>> watchByAccountWithCategory(
    int accountId,
  ) {
    final query =
        select(transactions).join([
            leftOuterJoin(
              categories,
              categories.id.equalsExp(transactions.categoryId),
            ),
          ])
          ..where(transactions.accountId.equals(accountId))
          ..orderBy([OrderingTerm.asc(transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(transactions),
          category: row.readTableOrNull(categories),
        );
      }).toList();
    });
  }

  Future<List<Transaction>> getByAccountIdOrderedByDate(int accountId) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<Transaction?> getById(int id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Transaction?> getLastTransactionBefore(int accountId, DateTime date) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..where((t) => t.date.isSmallerThanValue(date))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Transaction>> getTransactionsAfterDate(
    int accountId,
    DateTime afterDate,
  ) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..where((t) => t.date.isBiggerOrEqualValue(afterDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<void> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(transaction);
  }

  Future<void> updateResultantBalance(int transactionId, double balance) {
    return (update(transactions)..where((t) => t.id.equals(transactionId)))
        .write(TransactionsCompanion(resultantBalance: Value(balance)));
  }

  Future<void> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Watches total spending for a given account in a period, optionally filtered by category
  Stream<double> watchTotalSpentInPeriod({
    required int accountId,
    int? categoryId, // null = all categories
    required DateTime start,
    required DateTime end,
  }) {
    // Build the query
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.accountId.equals(accountId))
      ..where(transactions.type.equals(TransactionType.expense.index))
      ..where(transactions.date.isBiggerOrEqualValue(start))
      ..where(transactions.date.isSmallerOrEqualValue(end));

    // If categoryId is specified, filter by it
    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }

    return query.watchSingle().map((row) {
      final sum = row.read(transactions.amount.sum());
      return sum ?? 0.0;
    });
  }

  /// Watches transactions filtered by account, date range, and a list of categories.
  Stream<List<Transaction>> watchFilteredTransactions({
    required int accountId,
    required DateTime startDate,
    required DateTime endDate,
    required List<int> categoryIds,
  }) {
    final query = select(transactions)
      ..where((t) => t.accountId.equals(accountId))
      ..where((t) => t.date.isBiggerOrEqualValue(startDate))
      ..where((t) => t.date.isSmallerOrEqualValue(endDate))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]); // Optional: keep them ordered

    // If categoryIds is provided and non-empty, filter by the list.
    // An empty list means "All Categories" (no filtering by category ID).
    if (categoryIds.isNotEmpty) {
      // Use isIn to filter transactions where categoryId matches any ID in the list
      query.where((t) => t.categoryId.isIn(categoryIds));
    } else {
      // If categoryIds is empty, include transactions with any category ID (or null, if allowed)
      // No additional filter needed here, as the lack of filter covers all categories.
      // If your business logic strictly means "only categorized transactions" when the list is empty,
      // you would add: query.where((t) => t.categoryId.isNotNull());
      // Based on the budget logic, leaving it open to all categories is typical.
    }

    return query.watch();
  }
}
