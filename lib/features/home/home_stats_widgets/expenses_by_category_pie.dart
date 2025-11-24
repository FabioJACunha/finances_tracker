import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final categoryColorsAsync = ref.watch(categoryColorsMapProvider);
    final dataAsync = ref.watch(
      expensesByCategoryProvider(
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
              "Expenses by category",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            categoryColorsAsync.when(
              data: (categoryColors) {
                return dataAsync.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No expenses in this period',
                            style: TextStyle(
                              color: AppColors.textMuted,
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

                    final sections = data.entries.map((entry) {
                      final color =
                          categoryColors[entry.key] ?? Colors.grey;

                      return PieChartSectionData(
                        value: entry.value,
                        title: '${entry.value.toStringAsFixed(2)} €',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        color: color,
                        radius: 60,
                      );
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: sections,
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 50,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${total.toStringAsFixed(2)} €",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Wrap for captions below, full width
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: data.entries.map((entry) {
                            final color =
                                categoryColors[entry.key] ?? Colors.grey;
                            final percentage =
                            (entry.value / total * 100).toStringAsFixed(1);

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${entry.key} ($percentage%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textDark,
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
