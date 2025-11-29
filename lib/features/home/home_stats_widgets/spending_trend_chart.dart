import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';

class SpendingTrendChart extends ConsumerStatefulWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const SpendingTrendChart({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  ConsumerState<SpendingTrendChart> createState() =>
      _SpendingTrendChartState();
}

class _SpendingTrendChartState extends ConsumerState<SpendingTrendChart> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categoryColorsAsync = ref.watch(categoryColorsMapProvider);
    final palette = currentPalette;

    // Calculate previous period
    final duration = widget.end.difference(widget.start);
    final previousStart = widget.start.subtract(duration);
    final previousEnd = widget.start.subtract(const Duration(seconds: 1));

    final currentDataAsync = ref.watch(
      expensesByCategoryProvider(
        PeriodArgs(
          accountId: widget.accountId,
          start: widget.start,
          end: widget.end,
        ),
      ),
    );

    final previousDataAsync = ref.watch(
      expensesByCategoryProvider(
        PeriodArgs(
          accountId: widget.accountId,
          start: previousStart,
          end: previousEnd,
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Spending Trend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: palette.textDark,
                      fontSize: 20,
                    ),
                  ),
                ),
                // Category dropdown
                categoriesAsync.when(
                  data: (categories) {
                    return DropdownButton<String?>(
                      value: _selectedCategory,
                      hint: Text(
                        'All',
                        style: TextStyle(color: palette.textDark),
                      ),
                      dropdownColor: palette.bgTerciary,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'All Categories',
                            style: TextStyle(color: palette.textDark),
                          ),
                        ),
                        ...categories.map((cat) {
                          return DropdownMenuItem<String?>(
                            value: cat.name,
                            child: Row(
                              children: [
                                Icon(
                                  IconData(
                                    cat.iconCodePoint,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 16,
                                  color: Color(cat.colorValue),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    color: palette.textDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            categoryColorsAsync.when(
              data: (categoryColors) {
                return currentDataAsync.when(
                  data: (currentData) {
                    return previousDataAsync.when(
                      data: (previousData) {
                        // Filter by selected category if any
                        double currentAmount = 0.0;
                        double previousAmount = 0.0;

                        if (_selectedCategory == null) {
                          // All categories
                          currentAmount = currentData.values
                              .fold(0.0, (sum, val) => sum + val);
                          previousAmount = previousData.values
                              .fold(0.0, (sum, val) => sum + val);
                        } else {
                          // Specific category
                          currentAmount =
                              currentData[_selectedCategory] ?? 0.0;
                          previousAmount =
                              previousData[_selectedCategory] ?? 0.0;
                        }

                        final chartData = [
                          _ChartData('Previous', previousAmount),
                          _ChartData('Current', currentAmount),
                        ];

                        final change = currentAmount - previousAmount;
                        final percentChange = previousAmount > 0
                            ? (change / previousAmount) * 100
                            : 0.0;

                        return Column(
                          children: [
                            // Comparison summary
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: palette.bgTerciary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPeriodItem(
                                    'Previous',
                                    previousAmount,
                                    palette.textMuted,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: palette.textMuted,
                                  ),
                                  _buildPeriodItem(
                                    'Current',
                                    currentAmount,
                                    palette.secondary,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: palette.textMuted,
                                  ),
                                  _buildChangeItem(change, percentChange),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Chart
                            SizedBox(
                              height: 200,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  labelStyle: TextStyle(
                                    color: palette.textDark,
                                    fontWeight: FontWeight.w600,
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
                                    xValueMapper: (data, _) => data.period,
                                    yValueMapper: (data, _) => data.amount,
                                    color: palette.secondary,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(
                                        color: palette.textDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      builder: (data, point, series,
                                          pointIndex, seriesIndex) {
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
                          'Error loading previous period: $err',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading current period: $err',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 200,
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

  Widget _buildPeriodItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
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

  Widget _buildChangeItem(double change, double percentChange) {
    final isPositive = change >= 0;
    final color = isPositive ? AppColors.red : AppColors.green;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}€',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  final String period;
  final double amount;

  _ChartData(this.period, this.amount);
}