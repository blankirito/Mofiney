import '../domain/transaction.dart';

final List<Transaction> mockTransactions = [
    Transaction(
    title: 'GrabFood',
    category: 'Food & Dining',
    accountId: 'maybank',
    account: 'Maybank',
    amount: 28.90,
    type: TransactionType.expense,
    dateTime: DateTime(2026, 8, 5, 12, 43),
    paymentMethod: 'Card',
    note: 'Lunch with team',
    tags: const [
      'work',
      'lunch',
    ],
    receiptPath: 'mock_receipt_grabfood.jpg',
  ),

  Transaction(
    title: 'Petrol (Petronas)',
    category: 'Transportation',
    accountId: 'cimb',
    account: 'CIMB',
    amount: 80.00,
    type: TransactionType.expense,
    dateTime: DateTime(2026, 9, 7, 8, 15),
    paymentMethod: 'Debit Card',
  ),

  Transaction(
    title: 'Jaya Grocer',
    category: 'Groceries',
    accountId: 'maybank',
    account: 'Maybank',
    amount: 62.80,
    type: TransactionType.expense,
    dateTime: DateTime(2026, 9, 8, 18, 30),
    paymentMethod: 'Card',
  ),

  Transaction(
    title: 'Starbucks Coffee',
    category: 'Food & Dining',
    accountId: 'tng',
    account: "Touch 'n Go",
    amount: 21.50,
    type: TransactionType.expense,
    dateTime: DateTime(2026, 9, 4, 14, 10),
    paymentMethod: 'E-Wallet',
  ),

  Transaction(
    title: 'Salary',
    category: 'Income',
    accountId: 'cimb',
    account: 'CIMB',
    amount: 4000.00,
    type: TransactionType.income,
    dateTime: DateTime(2026, 9, 1, 9, 0),
    paymentMethod: 'Manual',
  ),

  Transaction(
    title: 'Transfer to Maybank',
    category: 'Transfer',
    accountId: 'cimb',
    account: 'CIMB',
    amount: 500.00,
    type: TransactionType.transfer,
    dateTime: DateTime(2026, 9, 1, 9, 30),
    destinationAccount: 'Maybank',
    destinationAccountId: 'maybank',
  ),

  Transaction(
    title: "Touch 'n Go Reload",
    category: 'Transfer',
    accountId: 'maybank',
    account: 'Maybank',
    amount: 100.00,
    type: TransactionType.transfer,
    dateTime: DateTime(2026, 8, 31, 16, 15),
    destinationAccount: "Touch 'n Go",
    destinationAccountId: 'tng',
  ),

  Transaction(
    title: 'Uniqlo Mid Valley',
    category: 'Shopping',
    accountId: 'cimb-visa',
    account: 'Credit Card',
    amount: 149.90,
    type: TransactionType.expense,
    dateTime: DateTime(2026, 8, 31, 13, 20),
    paymentMethod: 'Card',
  ),
];