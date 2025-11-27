import 'package:drift/drift.dart';

enum TransactionType { expense, income }

enum CategoryUsageType { expense, income, both }

// Add new enum for Budget Period
enum BudgetPeriod { weekly, monthly }

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  RealColumn get balance => real().withDefault(const Constant(0.0))();

  BoolColumn get excludeFromTotal =>
      boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 255)();

  IntColumn get iconCodePoint => integer()();

  IntColumn get colorValue => integer()();

  IntColumn get usageType => intEnum<CategoryUsageType>()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get accountId => integer().references(Accounts, #id)();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get title => text().nullable()();

  TextColumn get description => text().nullable()();

  IntColumn get type => intEnum<TransactionType>()();

  TextColumn get currency => text().withDefault(const Constant('EUR'))();

  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  RealColumn get resultantBalance => real().withDefault(const Constant(0.0))();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get label => text()();

  IntColumn get accountId => integer().references(Accounts, #id)();

  RealColumn get limit => real()();

  IntColumn get period => intEnum<BudgetPeriod>()();
}

class BudgetCategoryLinks extends Table {
  IntColumn get budgetId => integer().references(Budgets, #id)();

  IntColumn get categoryId => integer().references(Categories, #id)();

  @override
  Set<Column> get primaryKey => {budgetId, categoryId};
}
