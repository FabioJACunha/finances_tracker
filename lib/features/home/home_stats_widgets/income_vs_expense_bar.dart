import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../home_stats_provider.dart';

class IncomeVsExpenseBar extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const IncomeVsExpenseBar({required this.accountId, required this.start, required this.end, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(incomeExpenseProvider(PeriodArgs(accountId: accountId, start: start, end: end)));

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: dataAsync.when(
          data: (data) {
            final income = data['income']!;
            final expense = data['expense']!;
            return Column(
              children: [
                const Text('Income vs Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (income > expense ? income : expense) * 1.2,
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: income, color: Colors.green)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: Colors.red)]),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                          if (v == 0) return const Text('Income');
                          if (v == 1) return const Text('Expense');
                          return const SizedBox.shrink();
                        })),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      ),
                    ),
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
