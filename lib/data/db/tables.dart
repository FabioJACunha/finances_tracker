import 'package:drift/drift.dart';

enum TransactionType { expense, income }

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
}
