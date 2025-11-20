import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
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
    return (select(
      transactions,
    )..where((t) => t.accountId.equals(accountId))).get();
  }

  // Simple insert - just inserts, no business logic
  Future<int> insert(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<void> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  Future<void> deleteTransaction(int id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // Join query for UI display (read-only, doesn't modify data)
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
