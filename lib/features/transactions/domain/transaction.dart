enum TransactionType { expense, income, transfer }

class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.accountId,
    required this.account,
    required this.amount,
    required this.type,
    required this.dateTime,
    this.paymentMethod,
    this.destinationAccount,
    this.destinationAccountId,
    this.note,
    this.tags = const [],
    this.receiptPath,
    required this.currencyCode,
    required this.accountAmount,
    this.destinationAccountAmount,
  });

  final String title;
  final String category;

  final String accountId;
  final String account;

  final double amount;
  final TransactionType type;
  final DateTime dateTime;

  final String? paymentMethod;
  final String? destinationAccount;
  final String? destinationAccountId;

  final String? note;
  final List<String> tags;
  final String? receiptPath;

  final String id;
  final double accountAmount;
  final double? destinationAccountAmount;
  final String currencyCode;
}
