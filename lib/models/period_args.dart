class PeriodArgs {
  final int accountId;
  final DateTime start;
  final DateTime end;

  PeriodArgs({required this.accountId, required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodArgs &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(accountId, start, end);
}

class TopCategoriesArgs {
  final int accountId;
  final DateTime start;
  final DateTime end;
  final int topN;

  TopCategoriesArgs({
    required this.accountId,
    required this.start,
    required this.end,
    required this.topN,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopCategoriesArgs &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          start == other.start &&
          end == other.end &&
          topN == other.topN;

  @override
  int get hashCode => Object.hash(accountId, start, end, topN);
}
