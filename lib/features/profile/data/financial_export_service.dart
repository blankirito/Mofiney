import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/export_options.dart';

class FinancialExportService {
  FinancialExportService(this._database);

  final AppDatabase _database;

  Future<List<File>> createCsvExports(ExportOptions options) async {
    final directory = await getTemporaryDirectory();

    final exportDirectory = Directory('${directory.path}/mofiney_exports');

    await exportDirectory.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final files = <File>[];

    if (options.includeTransactions) {
      final transactions = await _database
          .select(_database.transactionEntries)
          .get();

      final filtered = transactions.where(
        (transaction) => _matchesDateRange(
          transaction.transactionDateTime,
          options.dateRange,
        ),
      );

      files.add(
        await _writeCsv(
          exportDirectory,
          'mofiney_transactions_$timestamp.csv',
          [
            [
              'Date',
              'Title',
              'Type',
              'Category',
              'Amount',
              'Account',
              'Note',
              'Tags',
            ],
            ...filtered.map(
              (transaction) => [
                transaction.transactionDateTime.toIso8601String(),
                transaction.title,
                transaction.type,
                transaction.category,
                transaction.amount,
                transaction.account,
                transaction.note ?? '',
                transaction.tags ?? '',
              ],
            ),
          ],
        ),
      );
    }

    if (options.includeAccounts) {
      final accounts = await _database.select(_database.accountEntries).get();

      files.add(
        await _writeCsv(exportDirectory, 'mofiney_accounts_$timestamp.csv', [
          [
            'Name',
            'Type',
            'Opening Balance',
            'Currency',
            'Primary',
            'Active',
            'Credit Limit',
          ],
          ...accounts.map(
            (account) => [
              account.name,
              account.type,
              account.openingBalance,
              account.currencyCode,
              account.isPrimary,
              account.isActive,
              account.creditLimit ?? '',
            ],
          ),
        ]),
      );
    }

    if (options.includeCategories) {
      final categories = await _database
          .select(_database.categoryEntries)
          .get();

      files.add(
        await _writeCsv(exportDirectory, 'mofiney_categories_$timestamp.csv', [
          ['Name', 'Type', 'Active', 'Default'],
          ...categories.map(
            (category) => [
              category.name,
              category.type,
              category.isActive,
              category.isDefault,
            ],
          ),
        ]),
      );
    }

    if (options.includeBudgets) {
      final settings = await (_database.select(
        _database.appSettingsEntries,
      )..where((table) => table.id.equals(1))).getSingleOrNull();

      final categoryBudgets = await _database
          .select(_database.categoryBudgetEntries)
          .get();

      files.add(
        await _writeCsv(exportDirectory, 'mofiney_budgets_$timestamp.csv', [
          ['Budget Type', 'Category ID', 'Monthly Amount'],
          ['Total Monthly Budget', '', settings?.monthlyBudget ?? ''],
          ...categoryBudgets.map(
            (budget) => [
              'Category Budget',
              budget.categoryId,
              budget.monthlyBudget,
            ],
          ),
        ]),
      );
    }

    return files;
  }

  bool _matchesDateRange(DateTime date, ExportDateRange range) {
    final now = DateTime.now();

    switch (range) {
      case ExportDateRange.allTime:
        return true;

      case ExportDateRange.thisMonth:
        return date.year == now.year && date.month == now.month;

      case ExportDateRange.thisYear:
        return date.year == now.year;
    }
  }

  Future<File> _writeCsv(
    Directory directory,
    String fileName,
    List<List<Object?>> rows,
  ) async {
    final file = File('${directory.path}/$fileName');

    final content = rows
        .map((row) => row.map(_escapeCsvValue).join(','))
        .join('\r\n');

    await file.writeAsString('\uFEFF$content', flush: true);

    return file;
  }

  String _escapeCsvValue(Object? value) {
    final text = value?.toString() ?? '';
    return '"${text.replaceAll('"', '""')}"';
  }
}
