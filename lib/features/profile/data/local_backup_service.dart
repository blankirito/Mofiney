import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class LocalBackupService {
  LocalBackupService(this._database);

  final AppDatabase _database;

  Future<File> createBackup() async {
    final accounts = await _database.select(_database.accountEntries).get();

    final transactions = await _database
        .select(_database.transactionEntries)
        .get();

    final categories = await _database.select(_database.categoryEntries).get();

    final categoryBudgets = await _database
        .select(_database.categoryBudgetEntries)
        .get();

    final recurringSchedules = await _database
        .select(_database.recurringScheduleEntries)
        .get();

    final settings = await (_database.select(
      _database.appSettingsEntries,
    )..where((table) => table.id.equals(1))).getSingleOrNull();

    final receipts = await _collectReceipts(transactions);

    final payload = {
      'formatVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'app': 'Mofiney',
      'accounts': accounts.map((item) => item.toJson()).toList(),
      'transactions': transactions.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
      'categoryBudgets': categoryBudgets.map((item) => item.toJson()).toList(),
      'recurringSchedules': recurringSchedules
          .map((item) => item.toJson())
          .toList(),
      'settings': settings?.toJson(),
      'receipts': receipts.map((receipt) => receipt.toJson()).toList(),
    };

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/mofiney_backup_$timestamp.json');

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );

    return file;
  }

  Future<List<_BackupReceipt>> _collectReceipts(
    List<TransactionEntry> transactions,
  ) async {
    final receipts = <_BackupReceipt>[];

    for (final transaction in transactions) {
      final receiptPath = transaction.receiptPath;

      if (receiptPath == null || receiptPath.trim().isEmpty) {
        continue;
      }

      final receiptFile = File(receiptPath);

      if (!await receiptFile.exists()) {
        continue;
      }

      final lastDot = receiptPath.lastIndexOf('.');
      final extension = lastDot == -1 ? '.jpg' : receiptPath.substring(lastDot);

      receipts.add(
        _BackupReceipt(
          transactionId: transaction.id,
          extension: extension,
          encodedBytes: base64Encode(await receiptFile.readAsBytes()),
        ),
      );
    }

    return receipts;
  }

  Future<BackupPreview> validateBackup(File file) async {
    final backup = await _readBackup(file);

    return BackupPreview(
      createdAt: backup.createdAt,
      accountCount: backup.accounts.length,
      transactionCount: backup.transactions.length,
    );
  }

  Future<void> restoreBackup(File file) async {
    final backup = await _readBackup(file);
    final restoredReceiptPaths = await _restoreReceipts(backup.receipts);
    await _database.transaction(() async {
      await _database.delete(_database.transactionEntries).go();
      await _database.delete(_database.recurringScheduleEntries).go();
      await _database.delete(_database.categoryBudgetEntries).go();
      await _database.delete(_database.categoryEntries).go();
      await _database.delete(_database.accountEntries).go();
      await _database.delete(_database.appSettingsEntries).go();

      for (final account in backup.accounts) {
        await _database.into(_database.accountEntries).insert(account);
      }

      for (final category in backup.categories) {
        await _database.into(_database.categoryEntries).insert(category);
      }

      for (final budget in backup.categoryBudgets) {
        await _database.into(_database.categoryBudgetEntries).insert(budget);
      }

      for (final transaction in backup.transactions) {
        final restoredReceiptPath = restoredReceiptPaths[transaction.id];

        await _database
            .into(_database.transactionEntries)
            .insert(
              transaction.copyWith(receiptPath: Value(restoredReceiptPath)),
            );
      }

      for (final schedule in backup.recurringSchedules) {
        await _database
            .into(_database.recurringScheduleEntries)
            .insert(schedule);
      }

      if (backup.settings != null) {
        await _database
            .into(_database.appSettingsEntries)
            .insert(backup.settings!);
      }
    });
  }

  Future<Map<String, String>> _restoreReceipts(
    List<_BackupReceipt> receipts,
  ) async {
    if (receipts.isEmpty) {
      return const <String, String>{};
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final receiptsDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}receipts',
    );

    await receiptsDirectory.create(recursive: true);

    final restoredPaths = <String, String>{};

    for (final receipt in receipts) {
      final safeId = receipt.transactionId.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );

      final safeExtension =
          RegExp(r'^\.[a-zA-Z0-9]{1,10}$').hasMatch(receipt.extension)
          ? receipt.extension
          : '.jpg';

      final restoredFile = File(
        '${receiptsDirectory.path}${Platform.pathSeparator}'
        'receipt_$safeId$safeExtension',
      );

      await restoredFile.writeAsBytes(
        base64Decode(receipt.encodedBytes),
        flush: true,
      );

      restoredPaths[receipt.transactionId] = restoredFile.path;
    }

    return restoredPaths;
  }

  Future<_BackupData> _readBackup(File file) async {
    final decoded = jsonDecode(await file.readAsString());

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('This is not a valid Mofiney backup file.');
    }

    if (decoded['app'] != 'Mofiney' || decoded['formatVersion'] != 1) {
      throw const FormatException('This backup file is not supported.');
    }

    final createdAt = decoded['createdAt'];
    if (createdAt is! String) {
      throw const FormatException(
        'This backup file is missing its creation date.',
      );
    }

    return _BackupData(
      createdAt: DateTime.parse(createdAt),
      accounts: _decodeList(
        decoded['accounts'],
        AccountEntry.fromJson,
        'accounts',
      ),
      transactions: _decodeList(
        decoded['transactions'],
        TransactionEntry.fromJson,
        'transactions',
      ),
      categories: _decodeList(
        decoded['categories'],
        CategoryEntry.fromJson,
        'categories',
      ),
      categoryBudgets: _decodeList(
        decoded['categoryBudgets'],
        CategoryBudgetEntry.fromJson,
        'category budgets',
      ),
      recurringSchedules: _decodeList(
        decoded['recurringSchedules'],
        RecurringScheduleEntry.fromJson,
        'recurring schedules',
      ),
      settings: _decodeOptional(
        decoded['settings'],
        AppSettingsEntry.fromJson,
        'settings',
      ),
      receipts: _decodeReceipts(decoded['receipts']),
    );
  }

  List<T> _decodeList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
    String fieldName,
  ) {
    if (value is! List) {
      throw FormatException('This backup is missing $fieldName.');
    }

    return value.map((item) {
      if (item is! Map) {
        throw FormatException('This backup has invalid $fieldName.');
      }

      return fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  T? _decodeOptional<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
    String fieldName,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw FormatException('This backup has invalid $fieldName.');
    }

    return fromJson(Map<String, dynamic>.from(value));
  }

  List<_BackupReceipt> _decodeReceipts(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is! List) {
      throw const FormatException('This backup has invalid receipts.');
    }

    return value.map((item) {
      if (item is! Map) {
        throw const FormatException('This backup has invalid receipts.');
      }

      return _BackupReceipt.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.accountCount,
    required this.transactionCount,
  });

  final DateTime createdAt;
  final int accountCount;
  final int transactionCount;
}

class _BackupData {
  const _BackupData({
    required this.createdAt,
    required this.accounts,
    required this.transactions,
    required this.categories,
    required this.categoryBudgets,
    required this.recurringSchedules,
    required this.settings,
    required this.receipts,
  });

  final DateTime createdAt;
  final List<AccountEntry> accounts;
  final List<TransactionEntry> transactions;
  final List<CategoryEntry> categories;
  final List<CategoryBudgetEntry> categoryBudgets;
  final List<RecurringScheduleEntry> recurringSchedules;
  final AppSettingsEntry? settings;
  final List<_BackupReceipt> receipts;
}

class _BackupReceipt {
  const _BackupReceipt({
    required this.transactionId,
    required this.extension,
    required this.encodedBytes,
  });

  final String transactionId;
  final String extension;
  final String encodedBytes;

  factory _BackupReceipt.fromJson(Map<String, dynamic> json) {
    final transactionId = json['transactionId'];
    final extension = json['extension'];
    final encodedBytes = json['encodedBytes'];

    if (transactionId is! String ||
        extension is! String ||
        encodedBytes is! String) {
      throw const FormatException('This backup has invalid receipt data.');
    }

    return _BackupReceipt(
      transactionId: transactionId,
      extension: extension,
      encodedBytes: encodedBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'extension': extension,
      'encodedBytes': encodedBytes,
    };
  }
}
