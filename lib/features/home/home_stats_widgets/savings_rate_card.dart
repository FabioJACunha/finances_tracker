import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class SavingsRateCard extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;
  final palette = currentPalette;

  SavingsRateCard({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    final dataAsync = ref.watch(
      savingsRateProvider(
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
              loc.cardSavingsRateTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: palette.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            dataAsync.when(
              data: (value) {
                final clampedValue = value.clamp(0.0, 100.0);
                final color = _getSavingsRateColor(clampedValue);
                final rating = _getSavingsRating(loc, clampedValue);
                final description = _getSavingsDescription(loc, clampedValue);

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
                        backgroundColor: palette.bgTerciary,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textMuted,
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

  Color _getSavingsRateColor(double rate) {
    if (rate >= 30) return palette.green;
    if (rate >= 20) return Colors.lightGreen;
    if (rate >= 10) return Colors.orange;
    if (rate > 0) return Colors.deepOrange;
    return palette.red;
  }

  String _getSavingsRating(AppLocalizations loc, double rate) {
    if (rate >= 30) return loc.savingsRatingExcellent;
    if (rate >= 20) return loc.savingsRatingGood;
    if (rate >= 10) return loc.savingsRatingFair;
    if (rate > 0) return loc.savingsRatingLow;
    return loc.savingsRatingNone;
  }

  String _getSavingsDescription(AppLocalizations loc, double rate) {
    if (rate >= 30) return loc.savingsDescriptionExcellent;
    if (rate >= 20) return loc.savingsDescriptionGood;
    if (rate >= 10) return loc.savingsDescriptionFair;
    if (rate > 0) return loc.savingsDescriptionLow;
    return loc.savingsDescriptionNone;
  }
}
