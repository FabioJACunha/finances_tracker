import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../db/tables.dart';
import '../db/database.dart';
import '../../services/transaction_service.dart';

Future<void> seedDatabase(AppDatabase db) async {
  // If there are already accounts, assume DB is seeded.
  final existing = await db.accountsDao.watchAll().first;
  if (existing.isNotEmpty) return;

  // Insert account
  final accountId = await db.accountsDao.insert(
    AccountsCompanion.insert(
      name: 'Main Account',
      balance: const Value(0.00),
      excludeFromTotal: const Value(false),
    ),
  );

  // Seed categories with icons, colors, and usage types
  final categories = {
    'Food': _CategorySeed(
      icon: Icons.restaurant,
      color: Colors.orange,
      usageType: CategoryUsageType.expense,
    ),
    'Transport': _CategorySeed(
      icon: Icons.directions_car_filled,
      color: Colors.blue,
      usageType: CategoryUsageType.expense,
    ),
    'Salary': _CategorySeed(
      icon: Icons.euro,
      color: Colors.green,
      usageType: CategoryUsageType.income,
    ),
    'Shopping': _CategorySeed(
      icon: Icons.shopping_bag_outlined,
      color: Colors.purple,
      usageType: CategoryUsageType.expense,
    ),
    'Entertainment': _CategorySeed(
      icon: Icons.movie,
      color: Colors.pink,
      usageType: CategoryUsageType.expense,
    ),
    'Bills': _CategorySeed(
      icon: Icons.receipt_outlined,
      color: Colors.red,
      usageType: CategoryUsageType.expense,
    ),
    'Health': _CategorySeed(
      icon: Icons.local_hospital_outlined,
      color: Colors.teal,
      usageType: CategoryUsageType.expense,
    ),
    'Freelance': _CategorySeed(
      icon: Icons.card_travel_outlined,
      color: Colors.indigo,
      usageType: CategoryUsageType.income,
    ),
    'Other': _CategorySeed(
      icon: Icons.more_horiz,
      color: Colors.grey,
      usageType: CategoryUsageType.both,
    ),
  };

  final categoryIds = <String, int>{};
  for (final entry in categories.entries) {
    final id = await db.categoriesDao.insert(
      CategoriesCompanion.insert(
        name: entry.key,
        iconCodePoint: entry.value.icon.codePoint,
        colorValue: entry.value.color.toARGB32(),
        usageType: entry.value.usageType,
      ),
    );
    categoryIds[entry.key] = id;
  }

  final transactionService = TransactionService(db);
  final now = DateTime.now();

  // Helper to create date
  DateTime date(int daysAgo, int hour, int minute) {
    final d = now.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  // ============================================
  // MONTH 1 (Current month - last 30 days)
  // ============================================

  // Day 1 (today)
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 4.50,
    type: TransactionType.expense,
    title: 'Morning Coffee',
    description: 'Starbucks',
    categoryId: categoryIds['Food'],
    date: date(0, 8, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 12.90,
    type: TransactionType.expense,
    title: 'Lunch',
    description: 'Sandwich shop',
    categoryId: categoryIds['Food'],
    date: date(0, 13, 15),
  );

  // Day 2
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 45.00,
    type: TransactionType.expense,
    title: 'Gas',
    description: 'Shell station',
    categoryId: categoryIds['Transport'],
    date: date(1, 18, 45),
  );

  // Day 3
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 2500.00,
    type: TransactionType.income,
    title: 'Monthly Salary',
    description: 'Company XYZ',
    categoryId: categoryIds['Salary'],
    date: date(2, 9, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 89.99,
    type: TransactionType.expense,
    title: 'New Shoes',
    description: 'Nike store',
    categoryId: categoryIds['Shopping'],
    date: date(2, 15, 30),
  );

  // Day 5
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 150.00,
    type: TransactionType.expense,
    title: 'Electricity Bill',
    description: 'Monthly bill',
    categoryId: categoryIds['Bills'],
    date: date(4, 10, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 35.00,
    type: TransactionType.expense,
    title: 'Internet',
    description: 'Monthly subscription',
    categoryId: categoryIds['Bills'],
    date: date(4, 10, 5),
  );

  // Day 7
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 67.50,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(6, 11, 20),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 15.99,
    type: TransactionType.expense,
    title: 'Netflix',
    description: 'Monthly subscription',
    categoryId: categoryIds['Entertainment'],
    date: date(6, 12, 0),
  );

  // Day 10
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 350.00,
    type: TransactionType.income,
    title: 'Freelance Project',
    description: 'Website design',
    categoryId: categoryIds['Freelance'],
    date: date(9, 14, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 25.00,
    type: TransactionType.expense,
    title: 'Cinema',
    description: 'Movie night',
    categoryId: categoryIds['Entertainment'],
    date: date(9, 20, 0),
  );

  // Day 12
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 42.00,
    type: TransactionType.expense,
    title: 'Pharmacy',
    description: 'Medicine',
    categoryId: categoryIds['Health'],
    date: date(11, 16, 45),
  );

  // Day 14
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 78.90,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(13, 10, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 30.00,
    type: TransactionType.expense,
    title: 'Uber rides',
    description: 'Weekly transport',
    categoryId: categoryIds['Transport'],
    date: date(13, 22, 15),
  );

  // Day 17
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 199.99,
    type: TransactionType.expense,
    title: 'Headphones',
    description: 'Sony WH-1000XM5',
    categoryId: categoryIds['Shopping'],
    date: date(16, 13, 0),
  );

  // Day 20
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 55.00,
    type: TransactionType.expense,
    title: 'Dinner out',
    description: 'Italian restaurant',
    categoryId: categoryIds['Food'],
    date: date(19, 20, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 200.00,
    type: TransactionType.income,
    title: 'Birthday gift',
    description: 'From grandma',
    categoryId: categoryIds['Other'],
    date: date(19, 12, 0),
  );

  // Day 22
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 85.00,
    type: TransactionType.expense,
    title: 'Doctor visit',
    description: 'Annual checkup',
    categoryId: categoryIds['Health'],
    date: date(21, 9, 30),
  );

  // Day 25
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 62.30,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(24, 11, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 9.99,
    type: TransactionType.expense,
    title: 'Spotify',
    description: 'Monthly subscription',
    categoryId: categoryIds['Entertainment'],
    date: date(24, 11, 5),
  );

  // Day 28
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 120.00,
    type: TransactionType.expense,
    title: 'Concert tickets',
    description: 'Live music event',
    categoryId: categoryIds['Entertainment'],
    date: date(27, 19, 0),
  );

  // ============================================
  // MONTH 2 (Previous month - 31 to 60 days ago)
  // ============================================

  // Day 32
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 2500.00,
    type: TransactionType.income,
    title: 'Monthly Salary',
    description: 'Company XYZ',
    categoryId: categoryIds['Salary'],
    date: date(31, 9, 0),
  );

  // Day 33
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 145.00,
    type: TransactionType.expense,
    title: 'Electricity Bill',
    description: 'Monthly bill',
    categoryId: categoryIds['Bills'],
    date: date(32, 10, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 35.00,
    type: TransactionType.expense,
    title: 'Internet',
    description: 'Monthly subscription',
    categoryId: categoryIds['Bills'],
    date: date(32, 10, 10),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 50.00,
    type: TransactionType.expense,
    title: 'Phone bill',
    description: 'Monthly plan',
    categoryId: categoryIds['Bills'],
    date: date(32, 10, 15),
  );

  // Day 35
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 72.40,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(34, 12, 30),
  );

  // Day 38
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 500.00,
    type: TransactionType.income,
    title: 'Freelance Project',
    description: 'Logo design',
    categoryId: categoryIds['Freelance'],
    date: date(37, 15, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 38.00,
    type: TransactionType.expense,
    title: 'Gas',
    description: 'BP station',
    categoryId: categoryIds['Transport'],
    date: date(37, 17, 30),
  );

  // Day 40
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 249.99,
    type: TransactionType.expense,
    title: 'Winter Jacket',
    description: 'Zara',
    categoryId: categoryIds['Shopping'],
    date: date(39, 14, 0),
  );

  // Day 42
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 81.20,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(41, 10, 45),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 15.99,
    type: TransactionType.expense,
    title: 'Netflix',
    description: 'Monthly subscription',
    categoryId: categoryIds['Entertainment'],
    date: date(41, 11, 0),
  );

  // Day 45
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 65.00,
    type: TransactionType.expense,
    title: 'Dentist',
    description: 'Cleaning',
    categoryId: categoryIds['Health'],
    date: date(44, 11, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 22.50,
    type: TransactionType.expense,
    title: 'Books',
    description: 'Amazon order',
    categoryId: categoryIds['Entertainment'],
    date: date(44, 16, 0),
  );

  // Day 48
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 95.00,
    type: TransactionType.expense,
    title: 'Restaurant',
    description: 'Birthday dinner',
    categoryId: categoryIds['Food'],
    date: date(47, 20, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 45.00,
    type: TransactionType.expense,
    title: 'Taxi',
    description: 'Night out',
    categoryId: categoryIds['Transport'],
    date: date(47, 23, 30),
  );

  // Day 50
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 68.70,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(49, 11, 15),
  );

  // Day 53
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 9.99,
    type: TransactionType.expense,
    title: 'Spotify',
    description: 'Monthly subscription',
    categoryId: categoryIds['Entertainment'],
    date: date(52, 12, 0),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 35.00,
    type: TransactionType.expense,
    title: 'Gym membership',
    description: 'Monthly fee',
    categoryId: categoryIds['Health'],
    date: date(52, 12, 10),
  );

  // Day 55
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 180.00,
    type: TransactionType.income,
    title: 'Sold old phone',
    description: 'OLX sale',
    categoryId: categoryIds['Other'],
    date: date(54, 14, 0),
  );

  // Day 57
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 59.90,
    type: TransactionType.expense,
    title: 'Weekly Groceries',
    description: 'Supermarket',
    categoryId: categoryIds['Food'],
    date: date(56, 10, 30),
  );
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 42.00,
    type: TransactionType.expense,
    title: 'Gas',
    description: 'Shell station',
    categoryId: categoryIds['Transport'],
    date: date(56, 18, 0),
  );

  // Day 60
  await transactionService.createTransaction(
    accountId: accountId,
    amount: 150.00,
    type: TransactionType.expense,
    title: 'New game',
    description: 'PlayStation store',
    categoryId: categoryIds['Entertainment'],
    date: date(59, 21, 0),
  );
}

// Helper class for category seed data
class _CategorySeed {
  final IconData icon;
  final Color color;
  final CategoryUsageType usageType;

  _CategorySeed({
    required this.icon,
    required this.color,
    required this.usageType,
  });
}