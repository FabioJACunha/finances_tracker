import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_stats_provider.dart';
import '../../../helpers/app_colors.dart';

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
      color: AppColors.lightGrey,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dataAsync.when(
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Savings Rate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error: $e'),
        ),
      ),
    );
  }
}
