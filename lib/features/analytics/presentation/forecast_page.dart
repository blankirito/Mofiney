import 'package:flutter/material.dart';

import '../../transactions/domain/transaction.dart';

class ForecastTrendBucket {
  const ForecastTrendBucket({
    required this.label,
    required this.amount,
    required this.isPreview,
  });

  final String label;
  final double amount;
  final bool isPreview;
}

class ForecastCategoryPreview {
  const ForecastCategoryPreview({
    required this.name,
    required this.amount,
    required this.changeLabel,
    required this.changeType,
  });

  final String name;
  final double amount;
  final String changeLabel;
  final ForecastChangeType changeType;
}

enum ForecastChangeType { increase, decrease, stable }

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key, required this.transactions});

  final List<Transaction> transactions;

  DateTime get _referenceDate => DateTime.now();

  List<String> get _previewInsights => const [
    'Food & Dining spending has increased for 3 consecutive months.',
    'Overall spending is projected to increase next month.',
    'Reducing discretionary dining spending may help keep the monthly budget on track.',
  ];

  List<ForecastCategoryPreview> get _categoryPreviews => const [
    ForecastCategoryPreview(
      name: 'Food & Dining',
      amount: 720.00,
      changeLabel: '+18% projected surge',
      changeType: ForecastChangeType.increase,
    ),
    ForecastCategoryPreview(
      name: 'Transportation',
      amount: 380.00,
      changeLabel: 'Stable vs last month',
      changeType: ForecastChangeType.stable,
    ),
    ForecastCategoryPreview(
      name: 'Shopping',
      amount: 450.00,
      changeLabel: '+8% seasonal boost',
      changeType: ForecastChangeType.increase,
    ),
    ForecastCategoryPreview(
      name: 'Bills & Utilities',
      amount: 350.00,
      changeLabel: '-3% recurring reduction',
      changeType: ForecastChangeType.decrease,
    ),
    ForecastCategoryPreview(
      name: 'Other Expenses',
      amount: 780.00,
      changeLabel: 'Discretionary estimate',
      changeType: ForecastChangeType.stable,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forecast Details')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForecastHeader(context),

              const SizedBox(height: 16),

              _buildPredictionCard(context),

              const SizedBox(height: 16),

              _buildForecastSummary(context),

              const SizedBox(height: 16),

              _buildTrendCard(context),

              const SizedBox(height: 16),

              _buildCategoryForecastCard(context),

              const SizedBox(height: 16),

              _buildInsightsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  double? get _forecastChangePercentage {
    if (_sixMonthAverage <= 0) {
      return null;
    }

    return ((_predictedNextMonthSpending - _sixMonthAverage) /
            _sixMonthAverage) *
        100;
  }

  int get _daysInCurrentMonth {
    return DateTime(_referenceDate.year, _referenceDate.month + 1, 0).day;
  }

  double get _currentDailyPace {
    final currentDay = _referenceDate.day;

    if (currentDay <= 0) {
      return 0;
    }

    return _currentMonthExpenses / currentDay;
  }

  double get _predictedNextMonthSpending {
    if (_currentMonthExpenses <= 0) {
      return _sixMonthAverage;
    }

    return _currentDailyPace * _daysInCurrentMonth;
  }

  double get _forecastLowerRange {
    return _predictedNextMonthSpending * 0.9;
  }

  double get _forecastUpperRange {
    return _predictedNextMonthSpending * 1.1;
  }

  Widget _buildInsightsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 22, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Intelligent Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ..._previewInsights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Preventive budget alerts will be connected after forecast and budget settings are available.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Set Preventive Budget Alert'),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Insights and alert recommendations are preview content until the forecast engine is connected.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Transportation':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills & Utilities':
        return Icons.receipt_long_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildCategoryForecastRow(
    BuildContext context, {
    required ForecastCategoryPreview item,
    required double total,
  }) {
    final colors = Theme.of(context).colorScheme;

    final percentage = total <= 0 ? 0.0 : item.amount / total;

    final IconData icon;
    final Color accentColor;

    switch (item.changeType) {
      case ForecastChangeType.increase:
        icon = Icons.arrow_upward_rounded;
        accentColor = colors.error;

      case ForecastChangeType.decrease:
        icon = Icons.arrow_downward_rounded;
        accentColor = colors.tertiary;

      case ForecastChangeType.stable:
        icon = Icons.horizontal_rule_rounded;
        accentColor = colors.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _categoryIcon(item.name),
                    size: 18,
                    color: accentColor,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          Icon(icon, size: 14, color: accentColor),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              item.changeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM ${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colors.surfaceContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryForecastCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const previewTotal = 2680.00;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Category-Level Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'OCT PREVIEW',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._categoryPreviews.map(
            (item) => _buildCategoryForecastRow(
              context,
              item: item,
              total: previewTotal,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Category values are preview data until the forecast engine is connected.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatChartAmount(double amount) {
    if (amount >= 1000) {
      return 'RM ${(amount / 1000).toStringAsFixed(1)}k';
    }

    return 'RM ${amount.toStringAsFixed(2)}';
  }

  Widget _buildTrendCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buckets = _trendBuckets;

    final maxValue = buckets.isEmpty
        ? 0.0
        : buckets
              .map((bucket) => bucket.amount)
              .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '6-Month Trend & Projections',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Actual',
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
              const SizedBox(width: 16),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Preview',
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((bucket) {
                final heightFactor = maxValue <= 0
                    ? 0.0
                    : (bucket.amount / maxValue).clamp(0.0, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatChartAmount(bucket.amount),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: bucket.isPreview
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: bucket.isPreview
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor <= 0
                                  ? 0.02
                                  : heightFactor,
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                  color: bucket.isPreview
                                      ? colors.primaryContainer
                                      : colors.secondaryContainer,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          bucket.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: bucket.isPreview
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: bucket.isPreview
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Historical bars use recorded expenses. '
            'The next-month bar is preview data until the forecast engine is connected.',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required String subtitle,
    bool highlight = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'RM ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              color: highlight ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSummary(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              context,
              label: 'Current ($_currentMonthLabel)',
              amount: _currentMonthExpenses,
              subtitle: 'Current month',
              highlight: true,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _buildSummaryItem(
              context,
              label: 'Previous ($_previousMonthLabel)',
              amount: _previousMonthExpenses,
              subtitle: 'Closed ledger',
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _buildSummaryItem(
              context,
              label: '6-Mo Average',
              amount: _sixMonthAverage,
              subtitle: 'Baseline',
            ),
          ),
        ],
      ),
    );
  }

  String get _currentMonthLabel {
    return _shortMonthName(_referenceDate.month);
  }

  String get _previousMonthLabel {
    final previous = DateTime(_referenceDate.year, _referenceDate.month - 1, 1);

    return _shortMonthName(previous.month);
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

    return months[month - 1];
  }

  List<ForecastTrendBucket> get _trendBuckets {
    final buckets = <ForecastTrendBucket>[];

    // 过去 5 个完整月份
    for (int i = 5; i >= 1; i--) {
      final month = DateTime(_referenceDate.year, _referenceDate.month - i, 1);

      double total = 0;

      for (final transaction in transactions) {
        final sameMonth =
            transaction.dateTime.year == month.year &&
            transaction.dateTime.month == month.month;

        if (sameMonth && transaction.type == TransactionType.expense) {
          total += transaction.amount;
        }
      }

      buckets.add(
        ForecastTrendBucket(
          label: _shortMonthName(month.month),
          amount: total,
          isPreview: false,
        ),
      );
    }

    // 当前月份
    buckets.add(
      ForecastTrendBucket(
        label: _currentMonthLabel,
        amount: _currentMonthExpenses,
        isPreview: false,
      ),
    );

    // 下一月 preview
    final nextMonth = DateTime(
      _referenceDate.year,
      _referenceDate.month + 1,
      1,
    );

    buckets.add(
      ForecastTrendBucket(
        label: _shortMonthName(nextMonth.month),
        amount: _predictedNextMonthSpending,
        isPreview: true,
      ),
    );

    return buckets;
  }

  double get _sixMonthAverage {
    double total = 0;

    for (int i = 1; i <= 6; i++) {
      final month = DateTime(_referenceDate.year, _referenceDate.month - i, 1);

      final monthTotal = transactions
          .where(
            (transaction) =>
                transaction.type == TransactionType.expense &&
                transaction.dateTime.year == month.year &&
                transaction.dateTime.month == month.month,
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);

      total += monthTotal;
    }

    return total / 6;
  }

  double get _previousMonthExpenses {
    final previousMonth = DateTime(
      _referenceDate.year,
      _referenceDate.month - 1,
      1,
    );

    return transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.dateTime.year == previousMonth.year &&
              transaction.dateTime.month == previousMonth.month,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  double get _currentMonthExpenses {
    return transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.dateTime.year == _referenceDate.year &&
              transaction.dateTime.month == _referenceDate.month,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  Widget _buildForecastHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_graph_rounded,
            size: 20,
            color: colors.onPrimaryContainer,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREDICTIVE INTELLIGENCE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'Forecast Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.info_outline_rounded),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final predictedAmount = _predictedNextMonthSpending;

    final lowerRange = _forecastLowerRange;

    final upperRange = _forecastUpperRange;

    final changePercentage = _forecastChangePercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PREDICTED NEXT MONTH SPENDING',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: colors.onErrorContainer,
                    ),

                    const SizedBox(width: 3),

                    if (changePercentage != null)
                      Text(
                        '${changePercentage >= 0 ? '+' : ''}'
                        '${changePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.onErrorContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'RM ${predictedAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.straighten_rounded, size: 16, color: colors.primary),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    'Expected Range: '
                    'RM ${lowerRange.toStringAsFixed(2)} – '
                    'RM ${upperRange.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.query_stats_rounded,
                  size: 17,
                  color: colors.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Forecast values are currently preview data. '
                    'The production prediction model will be connected later.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
