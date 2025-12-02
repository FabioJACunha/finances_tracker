class DateRangeSelection {
  final DateRangeType type;
  final DateTime start;
  final DateTime end;

  DateRangeSelection({
    required this.type,
    required this.start,
    required this.end,
  });

  // Factory constructors for convenience
  factory DateRangeSelection.week([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final weekday = now.weekday;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weekday - 1));
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return DateRangeSelection(type: DateRangeType.week, start: start, end: end);
  }

  factory DateRangeSelection.month([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRangeSelection(
      type: DateRangeType.month,
      start: start,
      end: end,
    );
  }

  factory DateRangeSelection.year([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    return DateRangeSelection(type: DateRangeType.year, start: start, end: end);
  }

  factory DateRangeSelection.custom(DateTime start, DateTime end) {
    return DateRangeSelection(
      type: DateRangeType.custom,
      start: start,
      end: DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }

  factory DateRangeSelection.lastNMonths(int n, [DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month - n, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRangeSelection(
      type: DateRangeType.custom,
      start: start,
      end: end,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeSelection &&
          type == other.type &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(type, start, end);
}

enum DateRangeType { week, month, year, custom }
