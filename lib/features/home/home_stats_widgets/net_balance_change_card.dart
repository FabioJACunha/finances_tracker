import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_stats_provider.dart';
import '../../../helpers/app_colors.dart';

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
        child: dataAsync.when(
          data: (value) => Column(
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
              Text(
                '€${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: value >= 0 ? Colors.green : Colors.red,
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
