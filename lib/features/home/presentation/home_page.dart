import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/utils/money_formatter.dart';
import '../domain/home_dashboard_data.dart';
import '../domain/home_transaction.dart';
import '../data/mock_home_dashboard_data.dart';

import '../../transactions/presentation/add_expense_page.dart';
import '../../transactions/presentation/add_income_page.dart';
import '../../transactions/presentation/transfer_page.dart';
import '../../transactions/presentation/scan_receipt_page.dart';
import '../../analytics/presentation/spending_analysis_page.dart';
import '../../analytics/presentation/forecast_page.dart';
import '../../transactions/data/mock_transactions.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/presentation/transaction_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _balanceHidden = false;

  final HomeDashboardData _data = mockHomeDashboardData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),

              const SizedBox(height: AppSpacing.md),

              _buildGreeting(context),

              const SizedBox(height: AppSpacing.md),

              _BalanceCard(
                data: _data,
                balanceHidden: _balanceHidden,
                onToggleVisibility: () {
                  setState(() {
                    _balanceHidden = !_balanceHidden;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              _buildQuickActions(context),

              const SizedBox(height: AppSpacing.md),

              _SpendingOverviewCard(
                currencySymbol: _data.currencySymbol,
                values: _data.dailySpending,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpendingAnalysisPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              _SpendingForecastCard(
                data: _data,
                transactions: mockTransactions,
              ),

              const SizedBox(height: AppSpacing.md),

              _RecentTransactionsSection(
                currencySymbol: _data.currencySymbol,
                transactions: _recentTransactions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Transaction> get _recentTransactions {
    final transactions = [...mockTransactions]
      ..sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      );

    return transactions.take(4).toList();
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            'M',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        Text(
          'Mofiney',
          style: AppTextStyles.headlineMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Spacer(),

        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 2),

        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Good afternoon',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('✨'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Tuesday, 8 Sep 2026',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_data.currencyCode} · ACTIVE',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Expense',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpensePage()),
              );
            },
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Income',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddIncomePage()),
              );
            },
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: _QuickActionCard(
            icon: Icons.swap_horiz_rounded,
            label: 'Transfer',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransferPage()),
              );
            },
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: _QuickActionCard(
            icon: Icons.document_scanner_outlined,
            label: 'Scan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanReceiptPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.data,
    required this.balanceHidden,
    required this.onToggleVisibility,
  });

  final HomeDashboardData data;
  final bool balanceHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TOTAL LIQUIDITY & BALANCE',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              InkWell(
                onTap: onToggleVisibility,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        balanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        balanceHidden ? 'Show' : 'Hide',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.currencySymbol,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Text(
                balanceHidden
                    ? '••••••'
                    : MoneyFormatter.amountOnly(data.totalBalance),
                style: AppTextStyles.displayHeroMobile.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Today: ${MoneyFormatter.format(amount: data.todaySpent, symbol: data.currencySymbol)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Healthy Pace',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Spent',
                  value: MoneyFormatter.format(
                    amount: data.monthlySpent,
                    symbol: data.currencySymbol,
                  ),
                  subtitle: data.budgetUsedPercentage == null
                      ? 'No budget set'
                      : '${data.budgetUsedPercentage!.toStringAsFixed(0)}% of cap',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricCard(
                  title: 'Remaining',
                  value: MoneyFormatter.format(
                    amount: data.remainingBudget,
                    symbol: data.currencySymbol,
                  ),
                  subtitle: data.budgetRemainingPercentage == null
                      ? 'No budget set'
                      : '${data.budgetRemainingPercentage!.toStringAsFixed(0)}% left',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricCard(
                  title: 'Income',
                  value: MoneyFormatter.format(
                    amount: data.monthlyIncome,
                    symbol: data.currencySymbol,
                  ),
                  subtitle: 'This month',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.amountSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.onPrimaryContainer, size: 21),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurface,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingOverviewCard extends StatefulWidget {
  const _SpendingOverviewCard({
    required this.currencySymbol,
    required this.values,
    required this.onTap,
  });

  final String currencySymbol;
  final List<double> values;
  final VoidCallback onTap;

  @override
  State<_SpendingOverviewCard> createState() => _SpendingOverviewCardState();
}

class _SpendingOverviewCardState extends State<_SpendingOverviewCard> {
  bool _showMonth = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending Overview',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Daily cadence tracking',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        _TimeRangeButton(
                          label: 'Month',
                          selected: _showMonth,
                          onTap: () {
                            setState(() {
                              _showMonth = true;
                            });
                          },
                        ),
                        _TimeRangeButton(
                          label: 'Year',
                          selected: !_showMonth,
                          onTap: () {
                            setState(() {
                              _showMonth = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 17,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _showMonth ? 'September 2026' : '2026',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _showMonth ? 'Today (Day 5)' : 'Current year',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Peak outflow: ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          TextSpan(
                            text: MoneyFormatter.format(
                              amount: widget.values.isEmpty
                                  ? 0
                                  : widget.values.reduce(
                                      (a, b) => a > b ? a : b,
                                    ),
                              symbol: widget.currencySymbol,
                            ),
                            style: AppTextStyles.amountSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    _showMonth ? '30-day projection' : '12-month view',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                height: 120,
                child: _showMonth
                    ? _DailyBarChart(values: widget.values)
                    : _YearPlaceholder(),
              ),

              const SizedBox(height: 8),

              if (_showMonth)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AxisLabel(label: 'Day 1'),
                    _AxisLabel(label: 'Day 10'),
                    _AxisLabel(label: 'Day 20'),
                    _AxisLabel(label: 'Day 30'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeButton extends StatelessWidget {
  const _TimeRangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelCaps.copyWith(
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (values.isEmpty) {
      return Center(
        child: Text(
          'No spending data yet',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) {
      return Center(
        child: Text(
          'No spending yet',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final value = values[index];
        final heightFactor = (value / maxValue).clamp(0.08, 1.0);

        final day = index + 1;
        final isPeak = value == maxValue;
        final isToday = day == 5;
        final isFuture = day > 5;

        Color barColor;

        if (isPeak) {
          barColor = colors.error;
        } else if (isToday) {
          barColor = colors.primary;
        } else if (isFuture) {
          barColor = colors.surfaceContainerHighest;
        } else {
          barColor = colors.secondaryContainer;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isFuture
                        ? barColor.withValues(alpha: 0.45)
                        : barColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                    border: isToday
                        ? Border.all(color: colors.primaryContainer, width: 1.5)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _YearPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Year view will use monthly totals',
        style: AppTextStyles.bodySmall.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        color: colors.onSurfaceVariant,
        fontSize: 9,
      ),
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({
    required this.currencySymbol,
    required this.transactions,
  });

  final String currencySymbol;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Transactions',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Later: switch MainShell to Transactions tab.
              },
              child: const Text('View all'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            children: List.generate(transactions.length, (index) {
              final transaction = transactions[index];

              return Column(
                children: [
                  _TransactionRow(
                    transaction: transaction,
                    currencySymbol: currencySymbol,
                  ),
                  if (index != transactions.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 64),
                      child: Divider(
                        height: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.currencySymbol,
  });

  final Transaction transaction;
  final String currencySymbol;

  String _buildSubtitle(Transaction transaction) {
    final dateTime = transaction.dateTime;

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

    final date =
        '${months[dateTime.month - 1]} ${dateTime.day}';

    if (transaction.type == TransactionType.transfer) {
      return 'Transfer · $date';
    }

    return '${transaction.category} · $date';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final Color accentColor;
    final Color iconBackground;
    final IconData icon;

    switch (transaction.type) {
      case TransactionType.expense:
        accentColor = colors.error;
        iconBackground =
            colors.errorContainer.withValues(alpha: 0.65);
        icon = Icons.shopping_bag_outlined;
        break;

      case TransactionType.income:
        accentColor = colors.tertiary;
        iconBackground =
            colors.tertiaryContainer.withValues(alpha: 0.45);
        icon = Icons.payments_outlined;
        break;

      case TransactionType.transfer:
        accentColor = colors.onSurface;
        iconBackground = colors.surfaceContainerHigh;
        icon = Icons.swap_horiz_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 21, color: accentColor),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(transaction),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MoneyFormatter.format(
                    amount: transaction.type == TransactionType.expense
                        ? -transaction.amount.abs()
                        : transaction.amount.abs(),
                    symbol: currencySymbol,
                    showSign:
                        transaction.type != TransactionType.transfer,
                  ),
                  style: AppTextStyles.amountMedium.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.account,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingForecastCard extends StatelessWidget {
  const _SpendingForecastCard({
    required this.data,
    required this.transactions,
  });

  final HomeDashboardData data;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colors.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Expanded(
                child: Text(
                  'Spending Forecast',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '+12.4% vs Sep',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: colors.onErrorContainer,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Projected spending next month',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 3),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.currencySymbol,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                MoneyFormatter.amountOnly(data.forecastAmount ?? 0),
                style: AppTextStyles.amountLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 17,
                    color: colors.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food & Dining spending is trending higher this month.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Your recent dining expenses are above '
                        'your current monthly average.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForecastPage(
                      transactions: transactions,
                    ),
                  ),
                );
              },
              label: const Text('View prediction details'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}
