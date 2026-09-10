import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class AccountEntries extends Table {
  @override
  String get tableName => 'accounts';

  TextColumn get id => text()();

  TextColumn get name => text()();

  /// bank | eWallet | cash | creditCard
  TextColumn get type => text()();

  RealColumn get openingBalance => real().named('opening_balance')();

  TextColumn get currencyCode => text().named('currency_code')();

  BoolColumn get isPrimary =>
      boolean().named('is_primary').withDefault(const Constant(false))();

  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  RealColumn get creditLimit => real().named('credit_limit').nullable()();

  IntColumn get statementCycleDay =>
      integer().named('statement_cycle_day').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TransactionEntries extends Table {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  TextColumn get accountId => text().named('account_id')();

  TextColumn get account => text()();

  RealColumn get amount => real()();

  TextColumn get currencyCode =>
      text().named('currency_code').withDefault(const Constant('MYR'))();

  RealColumn get accountAmount => real().named('account_amount').nullable()();

  RealColumn get destinationAccountAmount =>
      real().named('destination_account_amount').nullable()();

  /// expense | income | transfer
  TextColumn get type => text()();

  DateTimeColumn get transactionDateTime => dateTime().named('date_time')();

  TextColumn get paymentMethod => text().named('payment_method').nullable()();

  TextColumn get destinationAccount =>
      text().named('destination_account').nullable()();

  TextColumn get destinationAccountId =>
      text().named('destination_account_id').nullable()();

  TextColumn get note => text().nullable()();

  TextColumn get tags => text().nullable()();

  TextColumn get receiptPath => text().named('receipt_path').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingsEntries extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().withDefault(const Constant(1))();

  RealColumn get monthlyBudget => real().named('monthly_budget').nullable()();

  TextColumn get baseCurrency =>
      text().named('base_currency').withDefault(const Constant('MYR'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CategoryEntries extends Table {
  @override
  String get tableName => 'categories';

  TextColumn get id => text()();

  TextColumn get name => text()();

  /// expense | income
  TextColumn get type => text()();

  /// Material icon codePoint
  IntColumn get iconCodePoint => integer().named('icon_code_point')();

  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();

  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RecurringScheduleEntries extends Table {
  @override
  String get tableName => 'recurring_schedules';

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get accountId => text().named('account_id')();

  TextColumn get category => text()();

  RealColumn get amount => real()();

  /// expense | income
  TextColumn get type => text()();

  /// Monthly for now; designed to support more frequencies later.
  TextColumn get frequency => text()();

  DateTimeColumn get nextDate => dateTime().named('next_date')();

  IntColumn get iconCodePoint => integer().named('icon_code_point')();

  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AccountEntries,
    TransactionEntries,
    AppSettingsEntries,
    CategoryEntries,
    CategoryBudgetEntries,
    RecurringScheduleEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(transactionEntries);
        }

        if (from < 3) {
          await m.createTable(appSettingsEntries);
        }

        if (from < 4) {
          await m.createTable(categoryEntries);
        }

        if (from < 5) {
          await m.createTable(categoryBudgetEntries);
        }
        if (from < 6) {
          await m.createTable(recurringScheduleEntries);
        }
        if (from < 7) {
          await m.addColumn(
            transactionEntries,
            transactionEntries.currencyCode,
          );

          await m.addColumn(
            transactionEntries,
            transactionEntries.accountAmount,
          );

          await m.addColumn(
            transactionEntries,
            transactionEntries.destinationAccountAmount,
          );
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'mofiney',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

class CategoryBudgetEntries extends Table {
  @override
  String get tableName => 'category_budgets';

  /// One recurring monthly limit per category.
  TextColumn get categoryId => text().named('category_id')();

  RealColumn get monthlyBudget => real().named('monthly_budget')();

  @override
  Set<Column<Object>> get primaryKey => {categoryId};
}
