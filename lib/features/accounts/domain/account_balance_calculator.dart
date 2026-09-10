import 'account.dart';
import '../../transactions/domain/transaction.dart';

class AccountBalanceCalculator {
  const AccountBalanceCalculator._();

  static double calculate(Account account, List<Transaction> transactions) {
    double balance = account.openingBalance;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.expense:
          if (transaction.accountId == account.id) {
            if (account.type == AccountType.creditCard) {
              balance += transaction.accountAmount;
            } else {
              balance -= transaction.accountAmount;
            }
          }
          break;

        case TransactionType.income:
          if (transaction.accountId == account.id) {
            balance += transaction.accountAmount;
          }
          break;

        case TransactionType.transfer:
          if (transaction.accountId == account.id) {
            if (account.type == AccountType.creditCard) {
              balance += transaction.accountAmount;
            } else {
              balance -= transaction.accountAmount;
            }
          }

          if (transaction.destinationAccountId == account.id) {
            final receivedAmount =
                transaction.destinationAccountAmount ??
                transaction.accountAmount;

            if (account.type == AccountType.creditCard) {
              balance -= receivedAmount;
            } else {
              balance += receivedAmount;
            }
          }
          break;
      }
    }

    return balance;
  }
}
