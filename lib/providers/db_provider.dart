import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/database.dart';
import '../data/seed/seed_data.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Run seeding asynchronously (don't await here). UI streams will update when inserts complete.
  seedDatabase(db).catchError((e, st) {
    // optional: log the error
    // print('DB seeding error: $e\n$st');
  });

  ref.onDispose(() {
    db.close();
  });

  return db;
});
