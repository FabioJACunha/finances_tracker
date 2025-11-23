import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/analytics_provider.dart';
import '../../../helpers/app_colors.dart';
import '../../../models/period_args.dart';

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
    final categoryColors = ref.watch(categoryColorProvider);
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
      color: AppColors.bgTerciary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 3 Expense Categories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            dataAsync.when(
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

                // Calculate total for percentages
                final total = data.fold<double>(
                  0.0,
                  (sum, entry) => sum + entry.value,
                );

                return Column(
                  children: data.asMap().entries.map((mapEntry) {
                    final index = mapEntry.key;
                    final entry = mapEntry.value;
                    final categoryName = entry.key;
                    final amount = entry.value;
                    final percentage = (amount / total * 100);

                    // Get color from category colors or generate one
                    final color =
                        categoryColors[categoryName] ??
                        Colors.primaries[categoryName.hashCode %
                            Colors.primaries.length];

                    // Medal icons for top 3
                    final medalIcons = [
                      Icons.emoji_events, // 1st place trophy
                      Icons.workspace_premium, // 2nd place
                      Icons.military_tech, // 3rd place
                    ];
                    final medalColors = [
                      Colors.amber, // Gold
                      Colors.grey[400]!, // Silver
                      Colors.brown[300]!, // Bronze
                    ];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                medalIcons[index],
                                color: medalColors[index],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${amount.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 6,
                                    backgroundColor: AppColors.bgSecondary,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 45,
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Error loading data',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
