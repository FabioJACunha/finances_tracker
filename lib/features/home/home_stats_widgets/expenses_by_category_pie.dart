import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../home_stats_provider.dart';

class ExpensesByCategoryPie extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const ExpensesByCategoryPie({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColors = ref.watch(categoryColorProvider);
    final dataAsync = ref.watch(
      expensesByCategoryProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
      ),
    );

    return dataAsync.when(
      data: (data) {
        if (data.isEmpty) return const Text('No expenses');
        final sections = data.entries.map((e) {
          final color = categoryColors[e.key] ??
              Colors.primaries[e.key.hashCode % Colors.primaries.length];
          return PieChartSectionData(
            value: e.value,
            title: '${e.key}\n€${e.value.toStringAsFixed(2)}',
            color: color,
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

        return SizedBox(
          height: 200,
          child: PieChart(PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          )),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Error: $e'),
    );
  }
}

