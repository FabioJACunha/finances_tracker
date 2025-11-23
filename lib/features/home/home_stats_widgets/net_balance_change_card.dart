import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/analytics_provider.dart';
import '../../../helpers/app_colors.dart';
import '../../../models/period_args.dart';

class NetBalanceChangeCard extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const NetBalanceChangeCard({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(
      netBalanceChangeProvider(
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
              'Net Balance Change',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            dataAsync.when(
              data: (value) {
                final isPositive = value >= 0;
                final color = isPositive ? AppColors.green : AppColors.red;
                final icon = isPositive ? Icons.trending_up : Icons
                    .trending_down;

                return Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${value >= 0 ? '+' : ''}${value.toStringAsFixed(
                                2)} €',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            isPositive ? 'Surplus' : 'Deficit',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
              const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) =>
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error loading data',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
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