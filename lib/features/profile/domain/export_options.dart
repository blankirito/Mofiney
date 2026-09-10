enum ExportDateRange { allTime, thisMonth, thisYear }

class ExportOptions {
  const ExportOptions({
    required this.dateRange,
    required this.includeTransactions,
    required this.includeAccounts,
    required this.includeCategories,
    required this.includeBudgets,
  });

  final ExportDateRange dateRange;
  final bool includeTransactions;
  final bool includeAccounts;
  final bool includeCategories;
  final bool includeBudgets;
}
