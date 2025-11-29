import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/period_args.dart';
import '../../../theme/app_colors.dart';

class BalanceEvolutionChart extends ConsumerWidget {
  final int accountId;
  final DateTime start;
  final DateTime end;

  const BalanceEvolutionChart({
    required this.accountId,
    required this.start,
    required this.end,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = currentPalette;

    final dataAsync = ref.watch(
      balanceEvolutionProvider(
        PeriodArgs(accountId: accountId, start: start, end: end),
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
            Text(
              'Balance Evolution',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: palette.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: dataAsync.when(
                data: (points) {
                  if (points.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions in this period',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final chartData = points
                      .map((point) => _ChartData(point.key, point.value))
                      .toList();

                  return SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat('dd/MM'),
                      labelStyle: TextStyle(
                        color: palette.textMuted,
                        fontSize: 10,
                      ),
                      intervalType: DateTimeIntervalType.auto,
                    ),
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value}€',
                      labelStyle: TextStyle(
                        color: palette.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<_ChartData, DateTime>(
                        dataSource: chartData,
                        xValueMapper: (data, _) => data.date,
                        yValueMapper: (data, _) => data.balance,
                        color: palette.secondary,
                        borderColor: palette.secondary,
                        borderWidth: 3,
                        splineType: SplineType.natural,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'point.x: point.y€',
                      header: '',
                    ),
                    trackballBehavior: TrackballBehavior(
                      enable: true,
                      activationMode: ActivationMode.singleTap,
                      tooltipSettings: const InteractiveTooltip(
                        format: 'point.x: point.y€',
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading data: $err',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final DateTime date;
  final double balance;

  _ChartData(this.date, this.balance);
}