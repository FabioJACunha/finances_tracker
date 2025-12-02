import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    final palette = currentPalette;

    final dataAsync = ref.watch(
      netBalanceChangeProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
      ),
    );

    return Card(
      color: palette.bgTerciary,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.cardNetBalanceChangeTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: palette.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            dataAsync.when(
              data: (value) {
                final isPositive = value >= 0;
                final color = isPositive ? palette.green : palette.red;
                final icon = isPositive
                    ? Icons.trending_up
                    : Icons.trending_down;

                return Row(
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            isPositive ? loc.surplusLabel : loc.deficitLabel,
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
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.errorLoadingData(err.toString()),
                      style: const TextStyle(color: Colors.red, fontSize: 14),
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
