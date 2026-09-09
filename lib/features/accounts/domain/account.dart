enum AccountType {
  bank,
  eWallet,
  cash,
  creditCard,
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    this.isPrimary = false,
    this.isActive = true,
    this.creditLimit,
    this.statementCycleDay,
  });

  final String id;
  final String name;
  final AccountType type;

  /// Balance when the account is first created.
  ///
  /// Future current balance will be calculated from:
  /// opening balance + transactions.
  final double openingBalance;

  final bool isPrimary;
  final bool isActive;

  /// Credit-card only.
  final double? creditLimit;

  /// Credit-card only.
  /// Example: 18 = statement cycle on the 18th.
  final int? statementCycleDay;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? openingBalance,
    bool? isPrimary,
    bool? isActive,
    double? creditLimit,
    int? statementCycleDay,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      creditLimit: creditLimit ?? this.creditLimit,
      statementCycleDay:
          statementCycleDay ?? this.statementCycleDay,
    );
  }
}