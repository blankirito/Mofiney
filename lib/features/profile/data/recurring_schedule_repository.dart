import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/recurring_schedule.dart';

import 'dart:math' as math;

class RecurringScheduleRepository {
  RecurringScheduleRepository(this._database);

  final AppDatabase _database;

  Stream<List<RecurringSchedule>> watchAllSchedules() {
    return _database
        .select(_database.recurringScheduleEntries)
        .watch()
        .map((rows) => rows.map(_mapRowToSchedule).toList());
  }

  Future<void> insertSchedule(RecurringSchedule schedule) async {
    await _database
        .into(_database.recurringScheduleEntries)
        .insert(_mapScheduleToCompanion(schedule));
  }

  Future<void> updateSchedule(RecurringSchedule schedule) async {
    await (_database.update(_database.recurringScheduleEntries)
          ..where((table) => table.id.equals(schedule.id)))
        .write(_mapScheduleToCompanion(schedule));
  }

  Future<void> deleteSchedule(String id) async {
    await (_database.delete(
      _database.recurringScheduleEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> processDueSchedules({DateTime? now}) async {
    final today = _dateOnly(now ?? DateTime.now());

    final rows = await _database
        .select(_database.recurringScheduleEntries)
        .get();

    for (final row in rows) {
      if (!row.isActive) {
        continue;
      }

      final account = await (_database.select(
        _database.accountEntries,
      )..where((table) => table.id.equals(row.accountId))).getSingleOrNull();

      if (account == null || !account.isActive) {
        continue;
      }

      var dueDate = _dateOnly(row.nextDate);

      while (!dueDate.isAfter(today)) {
        final transactionId = 'recurring_${row.id}_${_dateKey(dueDate)}';

        final nextDate = _advanceDate(dueDate, row.frequency);

        await _database.transaction(() async {
          await _database
              .into(_database.transactionEntries)
              .insert(
                TransactionEntriesCompanion(
                  id: Value(transactionId),
                  title: Value(row.title),
                  category: Value(row.category),
                  accountId: Value(row.accountId),
                  account: Value(account.name),
                  amount: Value(row.amount),
                  type: Value(row.type),
                  transactionDateTime: Value(dueDate),
                  tags: const Value('[]'),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          await (_database.update(
            _database.recurringScheduleEntries,
          )..where((table) => table.id.equals(row.id))).write(
            RecurringScheduleEntriesCompanion(nextDate: Value(nextDate)),
          );
        });

        dueDate = nextDate;
      }
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _dateKey(DateTime value) {
    return '${value.year}'
        '-${value.month.toString().padLeft(2, '0')}'
        '-${value.day.toString().padLeft(2, '0')}';
  }

  DateTime _advanceDate(DateTime date, String frequency) {
    switch (frequency) {
      case 'Weekly':
        return date.add(const Duration(days: 7));

      case 'Yearly':
        return _addMonths(date, 12);

      case 'Monthly':
      default:
        return _addMonths(date, 1);
    }
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final zeroBasedMonth = date.month - 1 + monthsToAdd;

    final year = date.year + zeroBasedMonth ~/ 12;

    final month = zeroBasedMonth % 12 + 1;

    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;

    return DateTime(year, month, math.min(date.day, lastDayOfTargetMonth));
  }

  RecurringSchedule _mapRowToSchedule(RecurringScheduleEntry row) {
    return RecurringSchedule(
      id: row.id,
      title: row.title,
      accountId: row.accountId,
      category: row.category,
      amount: row.amount,
      type: RecurringScheduleType.values.firstWhere(
        (type) => type.name == row.type,
        orElse: () => RecurringScheduleType.expense,
      ),
      frequency: row.frequency,
      nextDate: row.nextDate,
      iconCodePoint: row.iconCodePoint,
      isActive: row.isActive,
    );
  }

  RecurringScheduleEntriesCompanion _mapScheduleToCompanion(
    RecurringSchedule schedule,
  ) {
    return RecurringScheduleEntriesCompanion(
      id: Value(schedule.id),
      title: Value(schedule.title),
      accountId: Value(schedule.accountId),
      category: Value(schedule.category),
      amount: Value(schedule.amount),
      type: Value(schedule.type.name),
      frequency: Value(schedule.frequency),
      nextDate: Value(schedule.nextDate),
      iconCodePoint: Value(schedule.iconCodePoint),
      isActive: Value(schedule.isActive),
    );
  }
}
