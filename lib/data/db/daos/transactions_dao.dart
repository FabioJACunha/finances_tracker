import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<Transaction>> watchByAccount(int accountId) {
    return (select(transactions)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<Transaction?> getById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Transaction>> getByAccountId(int accountId) {
    return (select(transactions)
      ..where((t) => t.accountId.equals(accountId)))
        .get();
  }

  /// Get all transactions that occurred after a given date for an account
  /// Ordered by date ASC, then by id ASC for same-date transactions
  Future<List<Transaction>> getTransactionsAfterDate(
      int accountId,
      DateTime date,
      ) {
    return (select(transactions)
      ..where((t) =>
      t.accountId.equals(accountId) & t.date.isBiggerOrEqualValue(date))
      ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.id), // Secondary sort by id for consistency
      ]))
        .get();
  }

  /// Get the transaction immediately before a given date (to get starting balance)
  Future<Transaction?> getLastTransactionBefore(
      int accountId,
      DateTime date,
      ) {
    return (select(transactions)
      ..where((t) =>
      t.accountId.equals(accountId) & t.date.isSmallerThanValue(date))
      ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.id), // Secondary sort by id
      ])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Get all transactions for an account ordered by date ascending
  Future<List<Transaction>> getByAccountIdOrderedByDate(int accountId) {
    return (select(transactions)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.id), // Secondary sort by id
      ]))
        .get();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<void> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  /// Update only the resultant balance of a transaction
  Future<void> updateResultantBalance(int id, double newBalance) async {
    await (update(transactions)..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(resultantBalance: Value(newBalance)));
  }

  Future<void> deleteTransaction(int id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // Join query for UI display (read-only, doesn't modify data)
  Stream<List<TransactionWithCategory>> watchByAccountWithCategory(
      int accountId,
      ) {
    final query = select(transactions).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(transactions.categoryId),
      ),
    ])
      ..where(transactions.accountId.equals(accountId))
      ..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(transactions),
          category: row.readTableOrNull(categories),
        );
      }).toList();
    });
  }
}

// Helper class for joined data
class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;

  TransactionWithCategory({required this.transaction, this.category});
}