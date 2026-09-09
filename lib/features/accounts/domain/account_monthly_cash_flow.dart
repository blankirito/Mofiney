import '../../transactions/domain/transaction.dart';

class AccountMonthlyCashFlow {
  const AccountMonthlyCashFlow({
    required this.income,
    required this.expenses,
    required this.incomeCount,
    required this.expenseCount,
  });

  final double income;
  final double expenses;

  final int incomeCount;
  final int expenseCount;

  double get netCashFlow => income - expenses;

  static AccountMonthlyCashFlow calculate({
    required String accountId,
    required List<Transaction> transactions,
    required DateTime month,
  }) {
    double income = 0;
    double expenses = 0;

    int incomeCount = 0;
    int expenseCount = 0;

    for (final transaction in transactions) {
      final isSameMonth =
          transaction.dateTime.year == month.year &&
          transaction.dateTime.month == month.month;

      if (!isSameMonth) {
        continue;
      }

      switch (transaction.type) {
        case TransactionType.income:
          if (transaction.accountId == accountId) {
            income += transaction.amount;
            incomeCount++;
          }
          break;

        case TransactionType.expense:
          if (transaction.accountId == accountId) {
            expenses += transaction.amount;
            expenseCount++;
          }
          break;

        case TransactionType.transfer:
          if (transaction.destinationAccountId == accountId) {
            income += transaction.amount;
            incomeCount++;
          }

          if (transaction.accountId == accountId) {
            expenses += transaction.amount;
            expenseCount++;
          }
          break;
      }
    }

    return AccountMonthlyCashFlow(
      income: income,
      expenses: expenses,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
    );
  }
}