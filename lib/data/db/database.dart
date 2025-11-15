import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';            // <--- NativeDatabase
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
import 'daos/accounts_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/categories_dao.dart';

export 'daos/accounts_dao.dart';
export 'daos/transactions_dao.dart';
export 'daos/categories_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Accounts, Transactions, Categories],
  daos: [AccountsDao, TransactionsDao, CategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'app.sqlite');

    // Ensure the file exists (optional)
    final file = File(dbPath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    // Use NativeDatabase — sqlite3_flutter_libs will provide the native lib on Android/iOS
    return NativeDatabase(file, logStatements: false);
  });
}