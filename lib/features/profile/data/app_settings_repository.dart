import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._database);

  final AppDatabase _database;

  Stream<AppSettingsEntry?> watchSettings() {
    final query = _database.select(_database.appSettingsEntries)
      ..where((table) => table.id.equals(1));

    return query.watchSingleOrNull();
  }

  Future<AppSettingsEntry?> getSettings() async {
    final query = _database.select(_database.appSettingsEntries)
      ..where((table) => table.id.equals(1));

    return query.getSingleOrNull();
  }

  Future<void> ensureSettingsExist() async {
    final existing = await getSettings();

    if (existing != null) {
      return;
    }

    await _database
        .into(_database.appSettingsEntries)
        .insert(
          const AppSettingsEntriesCompanion(
            id: Value(1),
            monthlyBudget: Value(4000),
            baseCurrency: Value('MYR'),
          ),
        );
  }

  Future<void> updateMonthlyBudget(double budget) async {
    await (_database.update(_database.appSettingsEntries)
          ..where((table) => table.id.equals(1)))
        .write(AppSettingsEntriesCompanion(monthlyBudget: Value(budget)));
  }

  Future<void> updateBaseCurrency(String currencyCode) async {
    await (_database.update(_database.appSettingsEntries)
          ..where((table) => table.id.equals(1)))
        .write(AppSettingsEntriesCompanion(baseCurrency: Value(currencyCode)));
  }
}
