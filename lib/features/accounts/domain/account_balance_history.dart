import 'account.dart';
import '../../transactions/domain/transaction.dart';

class AccountBalancePoint {
  const AccountBalancePoint({required this.dateTime, required this.balance});

  final DateTime dateTime;
  final double balance;
}

class AccountBalanceHistory {
  const AccountBalanceHistory._();

  static List<AccountBalancePoint> calculate({
    required Account account,
    required List<Transaction> transactions,
  }) {
    final accountTransactions = transactions.where((transaction) {
      return transaction.accountId == account.id ||
          transaction.destinationAccountId == account.id;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    double balance = account.openingBalance;

    final points = <AccountBalancePoint>[
      AccountBalancePoint(
        dateTime: accountTransactions.isEmpty
            ? DateTime.now()
            : accountTransactions.first.dateTime,
        balance: balance,
      ),
    ];

    for (final transaction in accountTransactions) {
      switch (transaction.type) {
        case TransactionType.expense:
          if (transaction.accountId == account.id) {
            if (account.type == AccountType.creditCard) {
              balance += transaction.amount;
            } else {
              balance -= transaction.amount;
            }
          }
          break;

        case TransactionType.income:
          if (transaction.accountId == account.id) {
            balance += transaction.amount;
          }
          break;

        case TransactionType.transfer:
          if (transaction.accountId == account.id) {
            balance -= transaction.amount;
          }

          if (transaction.destinationAccountId == account.id) {
            balance += transaction.amount;
          }
          break;
      }

      points.add(
        AccountBalancePoint(dateTime: transaction.dateTime, balance: balance),
      );
    }

    return points;
  }
}
