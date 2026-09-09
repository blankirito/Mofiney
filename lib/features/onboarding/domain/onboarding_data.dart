class OnboardingData {
  const OnboardingData({
    this.currencyCode = 'MYR',
    this.currencySymbol = 'RM',
    this.currencyName = 'Malaysian Ringgit',
    this.monthlyBudget,
    this.accountName,
    this.accountType,
    this.openingBalance,
  });

  final String currencyCode;
  final String currencySymbol;
  final String currencyName;

  final double? monthlyBudget;

  final String? accountName;
  final String? accountType;
  final double? openingBalance;

  OnboardingData copyWith({
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
    double? monthlyBudget,
    bool clearMonthlyBudget = false,
    String? accountName,
    String? accountType,
    double? openingBalance,
  }) {
    return OnboardingData(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
      monthlyBudget:
          clearMonthlyBudget ? null : monthlyBudget ?? this.monthlyBudget,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      openingBalance: openingBalance ?? this.openingBalance,
    );
  }
}