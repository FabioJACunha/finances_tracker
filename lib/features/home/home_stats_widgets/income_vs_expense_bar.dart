import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';

class IncomeVsExpenseBar extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const IncomeVsExpenseBar({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(
      incomeExpenseProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
      ),
    );

    return Card(
      color: AppColors.bgTerciary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income vs Expense',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            dataAsync.when(
              data: (data) {
                final income = data['income']!;
                final expense = data['expense']!;
                final net = income - expense;

                if (income == 0 && expense == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No transactions in this period',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                final chartData = [
                  _ChartData('Income', income, AppColors.green),
                  _ChartData('Expense', expense, AppColors.red),
                ];

                return Column(
                  children: [
                    // Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Income', income, AppColors.green),
                        _buildSummaryItem('Expense', expense, AppColors.red),
                        _buildSummaryItem(
                          'Net',
                          net,
                          net >= 0 ? AppColors.green : AppColors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Chart
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          labelStyle: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}€',
                          labelStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<_ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (data, _) => data.category,
                            yValueMapper: (data, _) => data.amount,
                            pointColorMapper: (data, _) => data.color,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              builder: (data, point, series, pointIndex, seriesIndex) {
                                final chartData = data as _ChartData;
                                return Text(
                                  '${chartData.amount.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          format: 'point.x: point.y€',
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error loading data: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)}€',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  final String category;
  final double amount;
  final Color color;

  _ChartData(this.category, this.amount, this.color);
}