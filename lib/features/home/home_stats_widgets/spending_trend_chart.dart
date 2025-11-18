import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../helpers/app_colors.dart';

// Placeholder for future spending trend chart
class SpendingTrendChart extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, just a placeholder text
    return Card(
      color: AppColors.bgTerciary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Spending Trend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 16),
            Center(child: Text('Coming soon...')),
          ],
        ),
      ),
    );
  }
}
