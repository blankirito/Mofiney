import 'account.dart';
import '../../transactions/domain/transaction.dart';

class AccountBalanceCalculator {
  const AccountBalanceCalculator._();

  static double calculate(
    Account account,
    List<Transaction> transactions,
  ) {
    double balance = account.openingBalance;

    for (final transaction in transactions) {
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
    }

    return balance;
  }
}