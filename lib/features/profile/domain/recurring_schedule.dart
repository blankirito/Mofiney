enum RecurringScheduleType { expense, income }

class RecurringSchedule {
  const RecurringSchedule({
    required this.id,
    required this.title,
    required this.accountId,
    required this.category,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.nextDate,
    required this.iconCodePoint,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String accountId;
  final String category;
  final double amount;
  final RecurringScheduleType type;
  final String frequency;
  final DateTime nextDate;
  final int iconCodePoint;
  final bool isActive;

  RecurringSchedule copyWith({
    String? id,
    String? title,
    String? accountId,
    String? category,
    double? amount,
    RecurringScheduleType? type,
    String? frequency,
    DateTime? nextDate,
    int? iconCodePoint,
    bool? isActive,
  }) {
    return RecurringSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isActive: isActive ?? this.isActive,
    );
  }
}
