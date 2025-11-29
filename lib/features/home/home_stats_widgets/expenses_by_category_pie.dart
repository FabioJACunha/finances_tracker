import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';

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
    final palette = currentPalette;

    final categoryColorsAsync = ref.watch(categoryColorsMapProvider);
    final dataAsync = ref.watch(
      expensesByCategoryProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
      ),
    );

    return Card(
      color: palette.bgTerciary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Expenses by category",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: palette.textDark,
              ),
            ),
            const SizedBox(height: 16),
            categoryColorsAsync.when(
              data: (categoryColors) {
                return dataAsync.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No expenses in this period',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    final total = data.values.fold<double>(
                      0.0,
                          (sum, value) => sum + value,
                    );

                    final chartData = data.entries.map((entry) {
                      final color = categoryColors[entry.key] ?? Colors.grey;
                      return _ChartData(
                        category: entry.key,
                        amount: entry.value,
                        color: color,
                      );
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 250,
                          child: SfCircularChart(
                            legend: Legend(isVisible: false),
                            series: <CircularSeries>[
                              DoughnutSeries<_ChartData, String>(
                                dataSource: chartData,
                                xValueMapper: (data, _) => data.category,
                                yValueMapper: (data, _) => data.amount,
                                pointColorMapper: (data, _) => data.color,
                                dataLabelMapper: (data, _) =>
                                '${data.amount.toStringAsFixed(0)}€',
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition:
                                  ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: palette.textDark,
                                  ),
                                ),
                                innerRadius: '60%',
                              ),
                            ],
                            annotations: <CircularChartAnnotation>[
                              CircularChartAnnotation(
                                widget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${total.toStringAsFixed(2)}€',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: palette.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legend below
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: chartData.map((data) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: data.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  data.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: palette.textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading data: $err',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error loading categories: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String category;
  final double amount;
  final Color color;

  _ChartData({
    required this.category,
    required this.amount,
    required this.color,
  });
}