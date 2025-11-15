import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_stats_provider.dart';

class TopExpenseCategories extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const TopExpenseCategories({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(
      topExpenseCategoriesProvider(
        TopCategoriesArgs(
          accountId: accountId,
          start: start,
          end: end,
          topN: 3,
        ),
      ),
    );

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dataAsync.when(
          data: (data) {
            if (data.isEmpty) return const Text('No expenses');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 3 Expense Categories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...data.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('${e.key}: €${e.value.toStringAsFixed(2)}'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error: $e'),
        ),
      ),
    );
  }
}
