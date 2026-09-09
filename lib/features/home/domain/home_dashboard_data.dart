import 'home_transaction.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.currencyCode,
    required this.currencySymbol,
    required this.totalBalance,
    required this.todaySpent,
    required this.monthlySpent,
    required this.monthlyBudget,
    required this.monthlyIncome,
    required this.dailySpending,
    required this.forecastAmount,
    required this.forecastChangePercentage,
    required this.forecastTitle,
    required this.forecastDescription,
    required this.recentTransactions,
  });

  final String currencyCode;
  final String currencySymbol;

  final double totalBalance;
  final double todaySpent;

  final double monthlySpent;
  final double? monthlyBudget;
  final double monthlyIncome;

  final List<double> dailySpending;

  final double? forecastAmount;
  final double? forecastChangePercentage;
  final String? forecastTitle;
  final String? forecastDescription;

  final List<HomeTransaction> recentTransactions;

  double get remainingBudget {
    if (monthlyBudget == null) {
      return 0;
    }

    return (monthlyBudget! - monthlySpent).clamp(
      0,
      double.infinity,
    );
  }

  double? get budgetUsedPercentage {
    if (monthlyBudget == null || monthlyBudget! <= 0) {
      return null;
    }

    return (monthlySpent / monthlyBudget!) * 100;
  }

  double? get budgetRemainingPercentage {
    final used = budgetUsedPercentage;

    if (used == null) {
      return null;
    }

    return (100 - used).clamp(0, 100);
  }

  double get peakDailySpending {
    if (dailySpending.isEmpty) {
      return 0;
    }

    return dailySpending.reduce(
      (a, b) => a > b ? a : b,
    );
  }
}