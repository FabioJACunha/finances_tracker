import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class IncomeVsExpenseBar extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;
  final palette = currentPalette;

  IncomeVsExpenseBar({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final palette = currentPalette;

    final dataAsync = ref.watch(
      incomeExpenseProvider(
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
              loc.chartIncomeVsExpenseTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: palette.textDark,
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        loc.chartNoTransactionsMessage,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                final chartData = [
                  _ChartData(loc.incomeLabel, income, palette.green),
                  _ChartData(loc.expenseLabel, expense, palette.red),
                ];

                return Column(
                  children: [
                    // Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          loc.incomeLabel,
                          income,
                          palette.green,
                        ),
                        _buildSummaryItem(
                          loc.expenseLabel,
                          expense,
                          palette.red,
                        ),
                        _buildSummaryItem(
                          loc.netLabel,
                          net,
                          net >= 0 ? palette.green : palette.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Chart
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: palette.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}€',
                          labelStyle: TextStyle(
                            color: palette.textMuted,
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
                              textStyle: TextStyle(
                                color: palette.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              builder:
                                  (
                                    data,
                                    point,
                                    series,
                                    pointIndex,
                                    seriesIndex,
                                  ) {
                                    final chartData = data as _ChartData;
                                    return Text(
                                      '${chartData.amount.toStringAsFixed(2)}€',
                                      style: TextStyle(
                                        color: palette.textDark,
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
                  loc.errorLoadingData(err.toString()),
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
          style: TextStyle(
            color: palette.textMuted,
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
