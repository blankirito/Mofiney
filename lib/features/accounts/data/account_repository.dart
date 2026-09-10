import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/account.dart';

class AccountRepository {
  AccountRepository(this._database);

  final AppDatabase _database;

  Future<List<Account>> getAllAccounts() async {
    final rows = await _database.select(_database.accountEntries).get();

    return rows.map(_mapRowToAccount).toList();
  }

  Future<Account?> getAccountById(String id) async {
    final query = _database.select(_database.accountEntries)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapRowToAccount(row);
  }

  Future<void> insertAccount(Account account) async {
    await _database.transaction(() async {
      if (account.isPrimary) {
        await _database
            .update(_database.accountEntries)
            .write(const AccountEntriesCompanion(isPrimary: Value(false)));
      }

      await _database
          .into(_database.accountEntries)
          .insert(_mapAccountToCompanion(account));
    });
  }

  Future<void> updateAccount(Account account) async {
    await _database.transaction(() async {
      if (account.isPrimary) {
        await (_database.update(_database.accountEntries)
              ..where((table) => table.id.equals(account.id).not()))
            .write(const AccountEntriesCompanion(isPrimary: Value(false)));
      }

      await (_database.update(_database.accountEntries)
            ..where((table) => table.id.equals(account.id)))
          .write(_mapAccountToCompanion(account));
    });
  }

  Future<void> deleteAccount(String id) async {
    await (_database.delete(
      _database.accountEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Account _mapRowToAccount(AccountEntry row) {
    return Account(
      id: row.id,
      name: row.name,
      type: _accountTypeFromString(row.type),
      openingBalance: row.openingBalance,
      currencyCode: row.currencyCode,
      isPrimary: row.isPrimary,
      isActive: row.isActive,
      creditLimit: row.creditLimit,
      statementCycleDay: row.statementCycleDay,
    );
  }

  AccountEntriesCompanion _mapAccountToCompanion(Account account) {
    return AccountEntriesCompanion(
      id: Value(account.id),
      name: Value(account.name),
      type: Value(account.type.name),
      openingBalance: Value(account.openingBalance),
      currencyCode: Value(account.currencyCode),
      isPrimary: Value(account.isPrimary),
      isActive: Value(account.isActive),
      creditLimit: Value(account.creditLimit),
      statementCycleDay: Value(account.statementCycleDay),
    );
  }

  AccountType _accountTypeFromString(String value) {
    return AccountType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => AccountType.bank,
    );
  }

  Future<void> seedAccountsIfEmpty(List<Account> accounts) async {
    final existingAccounts = await getAllAccounts();

    if (existingAccounts.isNotEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.accountEntries,
        accounts.map(_mapAccountToCompanion).toList(),
      );
    });
  }

  Stream<List<Account>> watchAllAccounts() {
    return _database
        .select(_database.accountEntries)
        .watch()
        .map((rows) => rows.map(_mapRowToAccount).toList());
  }
}
