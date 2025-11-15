import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions, Accounts, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<Transaction>> watchByAccount(int accountId) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Inserts a transaction (creates category if needed) and updates the account balance.
  /// `categoryName` can be null or empty -> treated as null (uncategorized).
  Future<int> insertTransactionAndUpdateBalance({
    required int accountId,
    required double amount,
    required TransactionType type,
    String? description,
    String? categoryName,
    DateTime? date,
  }) async {
    return transaction(() async {
      // Ensure category exists (if provided). If null/empty -> leave categoryId null.
      int? categoryId;
      final normalized = categoryName?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        final existing = await (select(
          categories,
        )..where((c) => c.name.equals(normalized))).getSingleOrNull();
        if (existing != null) {
          categoryId = existing.id;
        } else {
          categoryId = await into(
            categories,
          ).insert(CategoriesCompanion(name: Value(normalized)));
        }
      }

      // Build companion with categoryId (nullable)
      final txCompanion = TransactionsCompanion.insert(
        accountId: accountId,
        amount: amount,
        type: type,
        description: Value(description),
        // categoryId is nullable; use Value(categoryId) which accepts null for "absent"? use Value(categoryId) works.
        categoryId: Value(categoryId),
        date: date ?? DateTime.now(),
        currency: const Value('EUR'),
      );

      final id = await into(transactions).insert(txCompanion);

      // Update account balance
      final account = await (select(
        accounts,
      )..where((a) => a.id.equals(accountId))).getSingle();
      double newBalance = account.balance;

      if (type == TransactionType.income) {
        newBalance += amount;
      } else {
        newBalance -= amount;
      }

      await (update(accounts)..where((a) => a.id.equals(accountId))).write(
        AccountsCompanion(balance: Value(newBalance)),
      );

      return id;
    });
  }

  // Keep a simple insert that does not affect balance (if needed elsewhere)
  Future<int> insertTransactionWithoutBalance(TransactionsCompanion t) =>
      into(transactions).insert(t);

  Stream<List<({Transaction transaction, String? categoryName})>>
  watchWithCategoryNameByAccount(int accountId) {
    final tx = transactions;
    final cat = categories;

    final joinQuery =
        select(tx).join([leftOuterJoin(cat, cat.id.equalsExp(tx.categoryId))])
          ..where(tx.accountId.equals(accountId))
          ..orderBy([OrderingTerm.desc(tx.date)]);

    return joinQuery.watch().map((rows) {
      return rows.map((row) {
        return (
          transaction: row.readTable(tx),
          categoryName: row.read(cat.name),
        );
      }).toList();
    });
  }
}
