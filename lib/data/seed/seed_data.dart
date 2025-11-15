import 'package:drift/drift.dart';
import '../db/tables.dart';
import '../db/database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  // If there are already accounts, assume DB is seeded.
  final existing = await db.select(db.accounts).get();
  if (existing.isNotEmpty) return;

  // Insert two accounts
  final accountId1 = await db.into(db.accounts).insert(
    AccountsCompanion.insert(name: 'Main Account', balance: Value(1250.00), excludeFromTotal: Value(false)),
  );
  final accountId2 = await db.into(db.accounts).insert(
    AccountsCompanion.insert(name: 'Savings', balance: Value(5400.00), excludeFromTotal: Value(false)),
  );

  // Seed basic categories
  final basic = ['Food', 'Transport', 'Salary', 'Shopping', 'Entertainment', 'Other'];
  for (final name in basic) {
    // Use insert with ignore on conflict not available simply, but since DB is empty this is fine
    await db.into(db.categories).insert(CategoriesCompanion(name: Value(name)));
  }

  // Insert transactions using DAO so balances update correctly
  await db.transactionsDao.insertTransactionAndUpdateBalance(
    accountId: accountId1,
    amount: 12.50,
    type: TransactionType.expense,
    description: 'Coffee',
    categoryName: 'Food',
    date: DateTime.now(),
  );

  await db.transactionsDao.insertTransactionAndUpdateBalance(
    accountId: accountId1,
    amount: 35.90,
    type: TransactionType.expense,
    description: 'Groceries',
    categoryName: 'Food',
    date: DateTime.now(),
  );

  await db.transactionsDao.insertTransactionAndUpdateBalance(
    accountId: accountId1,
    amount: 900.00,
    type: TransactionType.income,
    description: 'Salary',
    categoryName: 'Salary',
    date: DateTime.now().subtract(const Duration(days: 2)),
  );

  await db.transactionsDao.insertTransactionAndUpdateBalance(
    accountId: accountId2,
    amount: 300.00,
    type: TransactionType.income,
    description: 'Side Hustle',
    categoryName: 'Other',
    date: DateTime.now().subtract(const Duration(days: 10)),
  );
}