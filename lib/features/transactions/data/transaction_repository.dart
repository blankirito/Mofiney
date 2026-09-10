import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/transaction.dart';

class TransactionRepository {
  TransactionRepository(this._database);

  final AppDatabase _database;

  Future<List<Transaction>> getAllTransactions() async {
    final rows = await _database.select(_database.transactionEntries).get();

    return rows.map(_mapRowToTransaction).toList();
  }

  Stream<List<Transaction>> watchAllTransactions() {
    return _database
        .select(_database.transactionEntries)
        .watch()
        .map((rows) => rows.map(_mapRowToTransaction).toList());
  }

  Future<Transaction?> getTransactionById(String id) async {
    final query = _database.select(_database.transactionEntries)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapRowToTransaction(row);
  }

  Future<void> insertTransaction(Transaction transaction) async {
    await _database
        .into(_database.transactionEntries)
        .insert(_mapTransactionToCompanion(transaction));
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await (_database.update(_database.transactionEntries)
          ..where((table) => table.id.equals(transaction.id)))
        .write(_mapTransactionToCompanion(transaction));
  }

  Future<void> deleteTransaction(String id) async {
    await (_database.delete(
      _database.transactionEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> seedTransactionsIfEmpty(List<Transaction> transactions) async {
    final existing = await getAllTransactions();

    if (existing.isNotEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.transactionEntries,
        transactions.map(_mapTransactionToCompanion).toList(),
      );
    });
  }

  Transaction _mapRowToTransaction(TransactionEntry row) {
    return Transaction(
      id: row.id,
      title: row.title,
      category: row.category,
      accountId: row.accountId,
      account: row.account,

      amount: row.amount,

      currencyCode: row.currencyCode,

      accountAmount: row.accountAmount ?? row.amount,

      destinationAccountAmount: row.destinationAccountAmount,

      type: _transactionTypeFromString(row.type),
      dateTime: row.transactionDateTime,
      paymentMethod: row.paymentMethod,
      destinationAccount: row.destinationAccount,
      destinationAccountId: row.destinationAccountId,
      note: row.note,
      tags: row.tags == null
          ? const []
          : List<String>.from(jsonDecode(row.tags!)),
      receiptPath: row.receiptPath,
    );
  }

  TransactionEntriesCompanion _mapTransactionToCompanion(
    Transaction transaction,
  ) {
    return TransactionEntriesCompanion(
      id: Value(transaction.id),
      title: Value(transaction.title),
      category: Value(transaction.category),
      accountId: Value(transaction.accountId),
      account: Value(transaction.account),
      amount: Value(transaction.amount),
      currencyCode: Value(transaction.currencyCode),

      accountAmount: Value(transaction.accountAmount),

      destinationAccountAmount: Value(transaction.destinationAccountAmount),
      type: Value(transaction.type.name),
      transactionDateTime: Value(transaction.dateTime),
      paymentMethod: Value(transaction.paymentMethod),
      destinationAccount: Value(transaction.destinationAccount),
      destinationAccountId: Value(transaction.destinationAccountId),
      note: Value(transaction.note),
      tags: Value(jsonEncode(transaction.tags)),
      receiptPath: Value(transaction.receiptPath),
    );
  }

  TransactionType _transactionTypeFromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
