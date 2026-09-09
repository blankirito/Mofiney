enum HomeTransactionType {
  expense,
  income,
  transfer,
}

class HomeTransaction {
  const HomeTransaction({
    required this.title,
    required this.subtitle,
    required this.account,
    required this.amount,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String account;
  final double amount;
  final HomeTransactionType type;
}