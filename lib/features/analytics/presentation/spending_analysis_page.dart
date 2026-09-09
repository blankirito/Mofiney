import 'package:flutter/material.dart';
import '../../transactions/data/mock_transactions.dart';
import '../../transactions/domain/transaction.dart';
import '../../accounts/data/mock_accounts.dart';

enum SpendingPeriod {
  month,
  threeMonths,
  sixMonths,
  year,
}

class SpendingDateRange {
  const SpendingDateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    return !date.isBefore(start) && date.isBefore(end);
  }
}

class SpendingBucket {
  const SpendingBucket({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

class SpendingAnalysisPage extends StatefulWidget {
  const SpendingAnalysisPage({super.key});

  @override
  State<SpendingAnalysisPage> createState() =>
      _SpendingAnalysisPageState();
}

class _SpendingAnalysisPageState extends State<SpendingAnalysisPage> {
  SpendingPeriod _selectedPeriod = SpendingPeriod.month;

  final DateTime _referenceDate = DateTime(2026, 9, 1);

  List<Transaction> get _transactions => mockTransactions;
  
  bool _isExpenseInSelectedPeriod(
    Transaction transaction,
  ) {
    return transaction.type == TransactionType.expense &&
        _isInSelectedPeriod(transaction);
  }

  bool _isInSelectedPeriod(Transaction transaction) {
    return _selectedDateRange.contains(
      transaction.dateTime,
    );
  }

  int get _daysInSelectedPeriod {
    return _selectedDateRange.end
        .difference(_selectedDateRange.start)
        .inDays;
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return 'September 2026';

      case SpendingPeriod.threeMonths:
        return 'Jul - Sep 2026';

      case SpendingPeriod.sixMonths:
        return 'Apr - Sep 2026';

      case SpendingPeriod.year:
        return '2026';
    }
  }

  SpendingDateRange get _selectedDateRange {
    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return SpendingDateRange(
          start: DateTime(
            _referenceDate.year,
            _referenceDate.month,
            1,
          ),
          end: DateTime(
            _referenceDate.year,
            _referenceDate.month + 1,
            1,
          ),
        );

      case SpendingPeriod.threeMonths:
        return SpendingDateRange(
          start: DateTime(
            _referenceDate.year,
            _referenceDate.month - 2,
            1,
          ),
          end: DateTime(
            _referenceDate.year,
            _referenceDate.month + 1,
            1,
          ),
        );

      case SpendingPeriod.sixMonths:
        return SpendingDateRange(
          start: DateTime(
            _referenceDate.year,
            _referenceDate.month - 5,
            1,
          ),
          end: DateTime(
            _referenceDate.year,
            _referenceDate.month + 1,
            1,
          ),
        );

      case SpendingPeriod.year:
        return SpendingDateRange(
          start: DateTime(
            _referenceDate.year,
            1,
            1,
          ),
          end: DateTime(
            _referenceDate.year + 1,
            1,
            1,
          ),
        );
    }
  }

  double? get _expenseChangePercentage {
    if (_previousTotalExpenses == 0) {
      return null;
    }

    return ((_totalExpenses - _previousTotalExpenses) /
            _previousTotalExpenses) *
        100;
  }

  double get _previousTotalExpenses {
    return _transactions
        .where(_isExpenseInPreviousPeriod)
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  bool _isExpenseInPreviousPeriod(
    Transaction transaction,
  ) {
    return transaction.type == TransactionType.expense &&
        _previousDateRange.contains(transaction.dateTime);
  }

  SpendingDateRange get _previousDateRange {
    final current = _selectedDateRange;

    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return SpendingDateRange(
          start: DateTime(
            current.start.year,
            current.start.month - 1,
            1,
          ),
          end: current.start,
        );

      case SpendingPeriod.threeMonths:
      case SpendingPeriod.sixMonths:
        final durationInMonths =
            _selectedPeriod == SpendingPeriod.threeMonths ? 3 : 6;

        return SpendingDateRange(
          start: DateTime(
            current.start.year,
            current.start.month - durationInMonths,
            1,
          ),
          end: current.start,
        );

      case SpendingPeriod.year:
        return SpendingDateRange(
          start: DateTime(
            current.start.year - 1,
            1,
            1,
          ),
          end: current.start,
        );
    }
  }

  List<SpendingBucket> _buildMonthlyBuckets({
    required int startMonth,
    required int count,
  }) {
    final buckets = <SpendingBucket>[];

    for (int i = 0; i < count; i++) {
      final date = DateTime(
        _referenceDate.year,
        startMonth + i,
        1,
      );

      double total = 0;

      for (final transaction in _transactions) {
        final sameMonth =
            transaction.dateTime.year == date.year &&
            transaction.dateTime.month == date.month;

        if (sameMonth &&
            transaction.type == TransactionType.expense) {
          total += transaction.amount;
        }
      }

      buckets.add(
        SpendingBucket(
          label: _shortMonthName(date.month),
          amount: total,
        ),
      );
    }

    return buckets;
  }

  List<SpendingBucket> _buildWeeklyBuckets() {
    final totals = List<double>.filled(4, 0);

    for (final transaction in _transactions) {
      if (!_isExpenseInSelectedPeriod(transaction)) {
        continue;
      }

      final day = transaction.dateTime.day;

      final int index;

      if (day <= 7) {
        index = 0;
      } else if (day <= 14) {
        index = 1;
      } else if (day <= 21) {
        index = 2;
      } else {
        index = 3;
      }

      totals[index] += transaction.amount;
    }

    return List.generate(
      4,
      (index) => SpendingBucket(
        label: 'W${index + 1}',
        amount: totals[index],
      ),
    );
  }

  List<SpendingBucket> get _trajectoryBuckets {
    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return _buildWeeklyBuckets();

      case SpendingPeriod.threeMonths:
        return _buildMonthlyBuckets(
          startMonth: _referenceDate.month - 2,
          count: 3,
        );

      case SpendingPeriod.sixMonths:
        return _buildMonthlyBuckets(
          startMonth: _referenceDate.month - 5,
          count: 6,
        );

      case SpendingPeriod.year:
        return _buildMonthlyBuckets(
          startMonth: 1,
          count: 12,
        );
    }
  }

  List<SpendingBucket> _buildPreviousMonthlyBuckets({
    required int count,
  }) {
    final range = _previousDateRange;
    final buckets = <SpendingBucket>[];

    for (int i = 0; i < count; i++) {
      final date = DateTime(
        range.start.year,
        range.start.month + i,
        1,
      );

      double total = 0;

      for (final transaction in _transactions) {
        final sameMonth =
            transaction.dateTime.year == date.year &&
            transaction.dateTime.month == date.month;

        if (sameMonth &&
            transaction.type == TransactionType.expense) {
          total += transaction.amount;
        }
      }

      buckets.add(
        SpendingBucket(
          label: _shortMonthName(date.month),
          amount: total,
        ),
      );
    }

    return buckets;
  }

  List<SpendingBucket> _buildPreviousWeeklyBuckets() {
    final totals = List<double>.filled(4, 0);

    for (final transaction in _transactions) {
      if (!_isExpenseInPreviousPeriod(transaction)) {
        continue;
      }

      final day = transaction.dateTime.day;

      final int index;

      if (day <= 7) {
        index = 0;
      } else if (day <= 14) {
        index = 1;
      } else if (day <= 21) {
        index = 2;
      } else {
        index = 3;
      }

      totals[index] += transaction.amount;
    }

    return List.generate(
      4,
      (index) => SpendingBucket(
        label: 'W${index + 1}',
        amount: totals[index],
      ),
    );
  }

  List<SpendingBucket> get _previousTrajectoryBuckets {
    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return _buildPreviousWeeklyBuckets();

      case SpendingPeriod.threeMonths:
        return _buildPreviousMonthlyBuckets(
          count: 3,
        );

      case SpendingPeriod.sixMonths:
        return _buildPreviousMonthlyBuckets(
          count: 6,
        );

      case SpendingPeriod.year:
        return _buildPreviousMonthlyBuckets(
          count: 12,
        );
    }
  }

  Map<String, double> get _categoryExpenses {
    final totals = <String, double>{};

    for (final transaction in _transactions) {
      if (!_isExpenseInSelectedPeriod(transaction)) {
        continue;
      }

      totals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return totals;
  }

  Map<String, double> get _accountExpenses {
    final totals = <String, double>{};

    for (final transaction in _transactions) {
      if (!_isExpenseInSelectedPeriod(transaction)) {
        continue;
      }

      totals.update(
        transaction.accountId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return totals;
  }

  String _accountName(String accountId) {
    for (final account in mockAccounts) {
      if (account.id == accountId) {
        return account.name;
      }
    }

    return 'Unknown Account';
  }

  MapEntry<String, double>? get _leadCategory {
    if (_categoryExpenses.isEmpty) {
      return null;
    }

    return _categoryExpenses.entries.reduce(
      (current, next) =>
          next.value > current.value ? next : current,
    );
  }

  String? get _mostFrequentMerchant {
    final counts = <String, int>{};

    for (final transaction in _transactions) {
      if (!_isExpenseInSelectedPeriod(transaction)) {
        continue;
      }

      counts.update(
        transaction.title,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    if (counts.isEmpty) {
      return null;
    }

    return counts.entries.reduce(
      (current, next) =>
          next.value > current.value ? next : current,
    ).key;
  }

  MapEntry<DateTime, double>? get _highestSpendingDay {
    final totals = <DateTime, double>{};

    for (final transaction in _transactions) {
      if (!_isExpenseInSelectedPeriod(transaction)) {
        continue;
      }

      final day = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );

      totals.update(
        day,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    if (totals.isEmpty) {
      return null;
    }

    return totals.entries.reduce(
      (current, next) =>
          next.value > current.value ? next : current,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 16),

              _buildPeriodSelector(context),

              const SizedBox(height: 16),

              _buildTotalExpendituresCard(context),

              const SizedBox(height: 16),

              _buildCashFlowDynamicsCard(context),

              const SizedBox(height: 16),

              _buildWeeklyTrajectoryCard(context),

              const SizedBox(height: 16),

              _buildCategoryBreakdownCard(context),

              const SizedBox(height: 16),

              _buildAccountBreakdownCard(context),

              const SizedBox(height: 16),

              _buildKeyObservationsCard(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservationRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? detail,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colors.onPrimaryContainer,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        if (detail != null)
          Text(
            detail,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildKeyObservationsCard(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    final leadCategory = _leadCategory;
    final merchant = _mostFrequentMerchant;
    final highestDay = _highestSpendingDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY RECORDED OBSERVATIONS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          _buildObservationRow(
            context,
            icon: Icons.pie_chart_outline_rounded,
            label: 'LEAD CATEGORY',
            value: leadCategory == null
                ? 'No data'
                : leadCategory.key,
            detail: leadCategory == null
                ? null
                : 'RM ${leadCategory.value.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 16),

          _buildObservationRow(
            context,
            icon: Icons.storefront_rounded,
            label: 'MOST FREQUENTED MERCHANT',
            value: merchant ?? 'No data',
          ),

          const SizedBox(height: 16),

          _buildObservationRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'HIGHEST SPENDING DAY',
            value: highestDay == null
                ? 'No data'
                : '${_shortMonthName(highestDay.key.month)} ${highestDay.key.day}',
            detail: highestDay == null
                ? null
                : 'RM ${highestDay.value.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 18),

          Divider(
            color: colors.outlineVariant,
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Insights are based only on transactions recorded in Finora.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  Widget _buildAccountBreakdownRow(
    BuildContext context, {
    required String accountId,
    required double amount,
  }) {
    final colors = Theme.of(context).colorScheme;

    final percentage = _totalExpenses <= 0
        ? 0.0
        : amount / _totalExpenses;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 19,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _accountName(accountId),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% of expenses',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBreakdownCard(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    final entries = _accountExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT BREAKDOWN',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Expense distribution across accounts',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          ...entries.map(
            (entry) => _buildAccountBreakdownRow(
              context,
              accountId: entry.key,
              amount: entry.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context, {
    required String category,
    required double amount,
  }) {
    final colors = Theme.of(context).colorScheme;

    final percentage = _totalExpenses <= 0
        ? 0.0
        : amount / _totalExpenses;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                'RM ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 44,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: colors.surfaceContainerHigh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final entries = _categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING BY CATEGORY',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${entries.length} recorded expense classifications',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          ...entries.map(
            (entry) => _buildCategoryRow(
              context,
              category: entry.key,
              amount: entry.value,
            ),
          ),
        ],
      ),
    );
  }

  String get _trajectorySubtitle {
    switch (_selectedPeriod) {
      case SpendingPeriod.month:
        return 'Spending by week';

      case SpendingPeriod.threeMonths:
        return 'Spending across the last 3 months';

      case SpendingPeriod.sixMonths:
        return 'Spending across the last 6 months';

      case SpendingPeriod.year:
        return 'Spending throughout the year';
    }
  }

  Widget _buildWeeklyTrajectoryCard(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;
    final buckets = _trajectoryBuckets;
    final previousBuckets = _previousTrajectoryBuckets;

    final values = buckets
        .map((bucket) => bucket.amount)
        .toList();

    final previousValues = previousBuckets
        .map((bucket) => bucket.amount)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING TRAJECTORY',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _trajectorySubtitle,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              const SizedBox(width: 6),

              Text(
                'Current',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(width: 18),

              SizedBox(
                width: 18,
                height: 3,
                child: CustomPaint(
                  painter: _LegendDashPainter(
                    color: colors.outline,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              Text(
                'Previous',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrajectoryPainter(
                values: values,
                previousValues: previousValues,
                lineColor: colors.primary,
                previousLineColor: colors.outline,
                gridColor: colors.outlineVariant,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: buckets.map((bucket) {
              return Expanded(
                child: Text(
                  bucket.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          Row(
            children: buckets.map((bucket) {
              return Expanded(
                child: Text(
                  'RM ${bucket.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    bool showSign = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    final sign = showSign
        ? amount > 0
            ? '+'
            : amount < 0
                ? '-'
                : ''
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(height: 10),

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${sign}RM ${amount.abs().toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowDynamicsCard(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CASH FLOW DYNAMICS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildCashFlowMetric(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'INFLOW',
                  amount: _totalIncome,
                  color: colors.tertiary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildCashFlowMetric(
                  context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'OUTFLOW',
                  amount: _totalExpenses,
                  color: colors.error,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildCashFlowMetric(
                  context,
                  icon: _netCashFlow >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  label: 'NET',
                  amount: _netCashFlow,
                  color: _netCashFlow >= 0
                      ? colors.primary
                      : colors.error,
                  showSign: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalExpendituresCard(
    BuildContext context,
  ) {
    final colors = Theme.of(context).colorScheme;
    final change = _expenseChangePercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL EXPENDITURES',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'RM ${_totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      change == null
                        ? Icons.remove_rounded
                        : change <= 0
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                      size: 15,
                      color: change == null
                        ? colors.onSurfaceVariant
                        : change <= 0
                            ? colors.tertiary
                            : colors.error,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      change == null
                        ? 'N/A'
                        : '${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: change == null
                          ? colors.onSurfaceVariant
                          : change <= 0
                              ? colors.tertiary
                              : colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            change == null
                ? 'No previous-period data'
                : 'vs previous period',
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                'Daily Pace:',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  'RM ${_dailyPace.toStringAsFixed(2)} / day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  'On Target',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double get _totalIncome {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.income &&
              _isInSelectedPeriod(transaction),
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  double get _netCashFlow {
    return _totalIncome - _totalExpenses;
  }

  double get _dailyPace {
    if (_daysInSelectedPeriod == 0) {
      return 0;
    }

    return _totalExpenses / _daysInSelectedPeriod;
  }

  double get _totalExpenses {
    return _transactions
        .where(_isExpenseInSelectedPeriod)
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Analytics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: colors.primary,
            ),

            const SizedBox(width: 6),

            Text(
              _periodLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.tertiary,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '$_daysInSelectedPeriod DAYS LOGGED',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w700,
                color: colors.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton(
            context,
            period: SpendingPeriod.month,
            label: 'Month',
          ),
          _buildPeriodButton(
            context,
            period: SpendingPeriod.threeMonths,
            label: '3 Months',
          ),
          _buildPeriodButton(
            context,
            period: SpendingPeriod.sixMonths,
            label: '6 Months',
          ),
          _buildPeriodButton(
            context,
            period: SpendingPeriod.year,
            label: 'Year',
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context, {
    required SpendingPeriod period,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = _selectedPeriod == period;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  const _TrajectoryPainter({
    required this.values,
    required this.previousValues,
    required this.lineColor,
    required this.previousLineColor,
    required this.gridColor,
  });

  final List<double> values;
  final List<double> previousValues;

  final Color lineColor;
  final Color previousLineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty && previousValues.isEmpty) {
      return;
    }

    // Grid
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // IMPORTANT:
    // Current + Previous share the SAME Y-axis scale.
    final allValues = [
      ...values,
      ...previousValues,
    ];

    if (allValues.isEmpty) {
      return;
    }

    final maxValue = allValues.reduce(
      (a, b) => a > b ? a : b,
    );

    if (maxValue <= 0) {
      return;
    }

    // Draw previous first so current stays visually dominant.
    _drawPreviousLine(
      canvas,
      size,
      maxValue,
    );

    _drawCurrentLine(
      canvas,
      size,
      maxValue,
    );
  }

  void _drawCurrentLine(
    Canvas canvas,
    Size size,
    double maxValue,
  ) {
    if (values.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final point = _calculatePoint(
        values: values,
        index: i,
        size: size,
        maxValue: maxValue,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }

      canvas.drawCircle(
        point,
        4,
        pointPaint,
      );
    }

    canvas.drawPath(
      path,
      linePaint,
    );
  }

  void _drawPreviousLine(
    Canvas canvas,
    Size size,
    double maxValue,
  ) {
    if (previousValues.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = previousLineColor.withValues(
        alpha: 0.75,
      )
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final points = List.generate(
      previousValues.length,
      (index) => _calculatePoint(
        values: previousValues,
        index: index,
        size: size,
        maxValue: maxValue,
      ),
    );

    const dashLength = 6.0;
    const gapLength = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      final delta = end - start;
      final distance = delta.distance;

      if (distance == 0) {
        continue;
      }

      final direction = delta / distance;

      double travelled = 0;

      while (travelled < distance) {
        final dashEnd =
            (travelled + dashLength)
                .clamp(0.0, distance);

        canvas.drawLine(
          start + direction * travelled,
          start + direction * dashEnd,
          paint,
        );

        travelled += dashLength + gapLength;
      }
    }
  }

  Offset _calculatePoint({
    required List<double> values,
    required int index,
    required Size size,
    required double maxValue,
  }) {
    final x = values.length == 1
        ? size.width / 2
        : size.width *
            index /
            (values.length - 1);

    final normalized =
        values[index] / maxValue;

    final y = size.height -
        (normalized * size.height * 0.85);

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(
    covariant _TrajectoryPainter oldDelegate,
  ) {
    return oldDelegate.values != values ||
        oldDelegate.previousValues != previousValues ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.previousLineColor !=
            previousLineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _LegendDashPainter extends CustomPainter {
  const _LegendDashPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashLength = 4.0;
    const gapLength = 3.0;

    double x = 0;

    while (x < size.width) {
      final end =
          (x + dashLength).clamp(0.0, size.width);

      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(end, size.height / 2),
        paint,
      );

      x += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(
    covariant _LegendDashPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}