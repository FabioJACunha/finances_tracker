import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../home_stats_provider.dart';
import 'package:collection/collection.dart';
import '../../../helpers/app_colors.dart';

class BalanceEvolutionChart extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const BalanceEvolutionChart({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(
      balanceEvolutionProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
      ),
    );

    return Card(
      color: AppColors.lightGrey,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: dataAsync.when(
          data: (points) {
            if (points.isEmpty) {
              return const Text('No transactions in this period');
            }

            final flSpots = points
                .mapIndexed((i, e) => FlSpot(i.toDouble(), e.value))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance Evolution',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen, fontSize: 20),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: flSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              final date = points[index].key;
                              return Text('${date.day}/${date.month}');
                            },
                          ),
                        ),
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
