import 'package:drift/drift.dart';
import '../db/tables.dart';
import '../db/database.dart';
import '../../services/transaction_service.dart';

Future<void> seedDatabase(AppDatabase db) async {
  // If there are already accounts, assume DB is seeded.
  final existing = await db.accountsDao.watchAll().first;
  if (existing.isNotEmpty) return;

  // Insert two accounts using DAO
  final accountId1 = await db.accountsDao.insert(
    AccountsCompanion.insert(
      name: 'Main Account',
      balance: const Value(1000.00), // Start at 0, transactions will update balance
      excludeFromTotal: const Value(false),
    ),
  );
  final accountId2 = await db.accountsDao.insert(
    AccountsCompanion.insert(
      name: 'Savings',
      balance: const Value(1000.00),
      excludeFromTotal: const Value(false),
    ),
  );

  // Seed basic categories using DAO
  final basic = ['Food', 'Transport', 'Salary', 'Shopping', 'Entertainment', 'Other'];
  for (final name in basic) {
    await db.categoriesDao.insert(CategoriesCompanion(name: Value(name)));
  }

  // Create transaction service for seeding transactions with business logic
  final transactionService = TransactionService(db);

  // Insert transactions using service (handles balance updates correctly)
  await transactionService.createTransaction(
    accountId: accountId1,
    amount: 12.50,
    type: TransactionType.expense,
    title: 'Coffee',
    description: 'Coffee',
    categoryName: 'Food',
    date: DateTime.now(),
  );

  await transactionService.createTransaction(
    accountId: accountId1,
    amount: 35.90,
    type: TransactionType.expense,
    title: 'Groceries',
    description: '',
    categoryName: 'Food',
    date: DateTime.now(),
  );

  await transactionService.createTransaction(
    accountId: accountId1,
    amount: 900.00,
    type: TransactionType.income,
    title: 'Salary Title',
    description: 'Work',
    categoryName: 'Salary',
    date: DateTime.now().subtract(const Duration(days: 2)),
  );

  await transactionService.createTransaction(
    accountId: accountId2,
    amount: 300.00,
    type: TransactionType.income,
    title: 'Side Hustle',
    description: 'Mekanik',
    categoryName: 'Other',
    date: DateTime.now().subtract(const Duration(days: 10)),
  );
}