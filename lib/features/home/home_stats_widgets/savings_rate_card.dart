import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/analytics_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/period_args.dart';

class SavingsRateCard extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const SavingsRateCard({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(
      savingsRateProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
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
              'Savings Rate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            dataAsync.when(
              data: (value) {
                final clampedValue = value.clamp(0.0, 100.0);
                final color = _getSavingsRateColor(clampedValue);
                final rating = _getSavingsRating(clampedValue);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.savings_outlined, color: color, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '${value.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            rating,
                            style: TextStyle(
                              fontSize: 14,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: clampedValue / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.bgTerciary,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSavingsDescription(clampedValue),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 100,
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

  Color _getSavingsRateColor(double rate) {
    if (rate >= 30) return AppColors.green;
    if (rate >= 20) return Colors.lightGreen;
    if (rate >= 10) return Colors.orange;
    if (rate > 0) return Colors.deepOrange;
    return AppColors.red;
  }

  String _getSavingsRating(double rate) {
    if (rate >= 30) return 'Excellent';
    if (rate >= 20) return 'Good';
    if (rate >= 10) return 'Fair';
    if (rate > 0) return 'Low';
    return 'None';
  }

  String _getSavingsDescription(double rate) {
    if (rate >= 30) return 'You\'re saving a great portion of your income!';
    if (rate >= 20) return 'Healthy savings rate, keep it up!';
    if (rate >= 10) return 'Consider increasing your savings goal.';
    if (rate > 0) return 'Try to save more of your income.';
    return 'No savings in this period. Income equals or is less than expenses.';
  }
}
