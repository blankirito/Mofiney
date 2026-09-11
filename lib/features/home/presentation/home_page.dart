import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/utils/money_formatter.dart';
import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';

import '../../transactions/presentation/add_expense_page.dart';
import '../../transactions/presentation/add_income_page.dart';
import '../../transactions/presentation/transfer_page.dart';
import '../../transactions/presentation/scan_receipt_page.dart';
import '../../analytics/presentation/spending_analysis_page.dart';
import '../../analytics/presentation/forecast_page.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/presentation/transaction_detail_page.dart';
import '../../../core/app_dependencies.dart';

import 'dart:async';

import '../../accounts/domain/account.dart';
import '../../accounts/domain/account_balance_calculator.dart';

import '../../../core/database/app_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _balanceHidden = false;

  List<Transaction> _transactions = [];

  List<Account> _accounts = [];

  StreamSubscription<List<Transaction>>? _transactionsSubscription;

  StreamSubscription<List<Account>>? _accountsSubscription;

  AppSettingsEntry? _settings;
  CurrencyConverter _converter = CurrencyConverter('MYR');

  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;

  @override
  void initState() {
    super.initState();

    _watchAccounts();
    _watchTransactions();
    _watchSettings();
  }

  void _watchSettings() {
    _settingsSubscription?.cancel();

    _settingsSubscription = appSettingsRepository.watchSettings().listen(
      (settings) {
        if (!mounted) {
          return;
        }

        setState(() {
          _settings = settings;
        });
        _refreshConversion();
      },
      onError: (Object error) {
        debugPrint('Failed to watch home settings: $error');
      },
    );
  }

  void _watchAccounts() {
    _accountsSubscription?.cancel();

    _accountsSubscription = accountRepository.watchAllAccounts().listen(
      (accounts) {
        if (!mounted) {
          return;
        }

        setState(() {
          _accounts = accounts;
        });
        _refreshConversion();
      },
      onError: (Object error) {
        debugPrint('Failed to watch home accounts: $error');
      },
    );
  }

  void _watchTransactions() {
    _transactionsSubscription?.cancel();

    _transactionsSubscription = transactionRepository
        .watchAllTransactions()
        .listen(
          (transactions) {
            if (!mounted) {
              return;
            }

            setState(() {
              _transactions = transactions;
            });
            _refreshConversion();
          },
          onError: (Object error) {
            debugPrint('Failed to watch home transactions: $error');
          },
        );
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _settingsSubscription?.cancel();

    super.dispose();
  }

  double? get _monthlyBudget => _settings?.monthlyBudget;

  String get _baseCurrency => _settings?.baseCurrency ?? 'MYR';

  String get _currencySymbol {
    return CurrencyCatalog.find(_baseCurrency).symbol;
  }

  Future<void> _refreshConversion() async {
    final base = _baseCurrency;
    final converter = CurrencyConverter(base);
    await converter.warm(_accounts.map((account) => account.currencyCode));
    if (mounted && base == _baseCurrency)
      setState(() => _converter = converter);
  }

  String _transactionCurrency(Transaction transaction) {
    for (final account in _accounts) {
      if (account.id == transaction.accountId) return account.currencyCode;
    }
    return 'MYR';
  }

  double _convertTransaction(Transaction transaction) =>
      _converter.convert(transaction.amount, _transactionCurrency(transaction));

  double _convertAccount(double amount, Account account) =>
      _converter.convert(amount, account.currencyCode);

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
                currencySymbol: _currencySymbol,
                totalBalance: _totalLiquidity,
                todaySpent: _todaySpent,
                monthlySpent: _monthlySpent,
                monthlyIncome: _monthlyIncome,
                remainingBudget: _remainingBudget,
                budgetUsedPercentage: _budgetUsedPercentage,
                budgetRemainingPercentage: _budgetRemainingPercentage,
                isHealthySpendingPace: _isHealthySpendingPace,
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
                currencySymbol: _currencySymbol,
                dailyValues: _dailySpendingCurrentMonth,
                monthlyValues: _monthlySpendingCurrentYear,
                referenceDate: DateTime.now(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SpendingAnalysisPage(
                        transactions: _transactions,
                        accounts: _accounts,
                        currencySymbol: _currencySymbol,
                        convertMyr: (amount) =>
                            _converter.convert(amount, 'MYR'),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              _SpendingForecastCard(
                transactions: _transactions,
                currencySymbol: _currencySymbol,
                forecastAmount: _projectedMonthlySpending,
                convertMyr: (amount) => _converter.convert(amount, 'MYR'),
              ),

              const SizedBox(height: AppSpacing.md),

              _RecentTransactionsSection(
                currencySymbol: _currencySymbol,
                transactions: _recentTransactions,
                convertedAmount: _convertTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isHealthySpendingPace {
    final monthlyBudget = _monthlyBudget;

    if (monthlyBudget == null || monthlyBudget <= 0) {
      return true;
    }

    final now = DateTime.now();

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final expectedSpentByToday = monthlyBudget * (now.day / daysInMonth);

    return _monthlySpent <= expectedSpentByToday;
  }

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  String get _formattedToday {
    final now = DateTime.now();

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    return '${weekdays[now.weekday - 1]}, '
        '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  double get _totalLiquidity {
    double totalAssets = 0;
    double totalLiabilities = 0;

    for (final account in _accounts) {
      if (!account.isActive) {
        continue;
      }

      final balance = AccountBalanceCalculator.calculate(
        account,
        _transactions,
      );

      if (account.type == AccountType.creditCard) {
        totalLiabilities += _convertAccount(balance, account);
      } else {
        totalAssets += _convertAccount(balance, account);
      }
    }

    return totalAssets - totalLiabilities;
  }

  double get _todaySpent {
    final now = DateTime.now();

    return _transactions
        .where((transaction) {
          return transaction.type == TransactionType.expense &&
              transaction.dateTime.year == now.year &&
              transaction.dateTime.month == now.month &&
              transaction.dateTime.day == now.day;
        })
        .fold(
          0.0,
          (sum, transaction) => sum + _convertTransaction(transaction),
        );
  }

  List<double> get _dailySpendingCurrentMonth {
    final now = DateTime.now();

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final values = List<double>.filled(daysInMonth, 0);

    for (final transaction in _transactions) {
      final isCurrentMonth =
          transaction.dateTime.year == now.year &&
          transaction.dateTime.month == now.month;

      if (transaction.type != TransactionType.expense || !isCurrentMonth) {
        continue;
      }

      final index = transaction.dateTime.day - 1;

      if (index >= 0 && index < values.length) {
        values[index] += _convertTransaction(transaction);
      }
    }

    return values;
  }

  List<double> get _monthlySpendingCurrentYear {
    final now = DateTime.now();

    final values = List<double>.filled(12, 0);

    for (final transaction in _transactions) {
      if (transaction.type != TransactionType.expense ||
          transaction.dateTime.year != now.year) {
        continue;
      }

      final index = transaction.dateTime.month - 1;

      values[index] += _convertTransaction(transaction);
    }

    return values;
  }

  double get _monthlySpent {
    final now = DateTime.now();

    return _transactions
        .where((transaction) {
          return transaction.type == TransactionType.expense &&
              transaction.dateTime.year == now.year &&
              transaction.dateTime.month == now.month;
        })
        .fold(
          0.0,
          (sum, transaction) => sum + _convertTransaction(transaction),
        );
  }

  double get _projectedMonthlySpending {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    if (now.day <= 0) {
      return 0;
    }

    final dailyAverage = _monthlySpent / now.day;

    return dailyAverage * daysInMonth;
  }

  double get _monthlyIncome {
    final now = DateTime.now();

    return _transactions
        .where((transaction) {
          return transaction.type == TransactionType.income &&
              transaction.dateTime.year == now.year &&
              transaction.dateTime.month == now.month;
        })
        .fold(
          0.0,
          (sum, transaction) => sum + _convertTransaction(transaction),
        );
  }

  double get _remainingBudget {
    final monthlyBudget = _monthlyBudget;

    if (monthlyBudget == null) {
      return 0;
    }

    return (monthlyBudget - _monthlySpent)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  double? get _budgetUsedPercentage {
    final monthlyBudget = _monthlyBudget;

    if (monthlyBudget == null || monthlyBudget <= 0) {
      return null;
    }

    return (_monthlySpent / monthlyBudget) * 100;
  }

  double? get _budgetRemainingPercentage {
    final used = _budgetUsedPercentage;

    if (used == null) {
      return null;
    }

    return (100 - used).clamp(0.0, 100.0).toDouble();
  }

  List<Transaction> get _recentTransactions {
    final transactions = [..._transactions]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
                      _greeting,
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
                _formattedToday,
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
                '$_baseCurrency · ACTIVE',
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
                MaterialPageRoute(
                  builder: (_) =>
                      AddExpensePage(repository: transactionRepository),
                ),
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
    required this.currencySymbol,
    required this.totalBalance,
    required this.todaySpent,
    required this.monthlySpent,
    required this.monthlyIncome,
    required this.remainingBudget,
    required this.budgetUsedPercentage,
    required this.budgetRemainingPercentage,
    required this.balanceHidden,
    required this.onToggleVisibility,
    required this.isHealthySpendingPace,
  });

  final double totalBalance;
  final double todaySpent;
  final double monthlySpent;
  final double monthlyIncome;
  final double remainingBudget;

  final double? budgetUsedPercentage;
  final double? budgetRemainingPercentage;

  final bool balanceHidden;
  final VoidCallback onToggleVisibility;

  final bool isHealthySpendingPace;

  final String currencySymbol;

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
                currencySymbol,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Text(
                balanceHidden
                    ? '••••••'
                    : MoneyFormatter.amountOnly(totalBalance),
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
                  'Today: ${MoneyFormatter.format(amount: todaySpent, symbol: currencySymbol)}',
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
                  isHealthySpendingPace ? 'Healthy Pace' : 'Above Pace',
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
                    amount: monthlySpent,
                    symbol: currencySymbol,
                  ),
                  subtitle: budgetUsedPercentage == null
                      ? 'No budget set'
                      : '${budgetUsedPercentage!.toStringAsFixed(0)}% of cap',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricCard(
                  title: 'Budget Left',
                  value: MoneyFormatter.format(
                    amount: remainingBudget,
                    symbol: currencySymbol,
                  ),
                  subtitle: budgetRemainingPercentage == null
                      ? 'No budget set'
                      : '${budgetRemainingPercentage!.toStringAsFixed(0)}% left',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricCard(
                  title: 'Income',
                  value: MoneyFormatter.format(
                    amount: monthlyIncome,
                    symbol: currencySymbol,
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
    required this.dailyValues,
    required this.monthlyValues,
    required this.referenceDate,
    required this.onTap,
  });

  final String currencySymbol;

  final List<double> dailyValues;
  final List<double> monthlyValues;

  final DateTime referenceDate;

  final VoidCallback onTap;

  @override
  State<_SpendingOverviewCard> createState() => _SpendingOverviewCardState();
}

class _SpendingOverviewCardState extends State<_SpendingOverviewCard> {
  bool _showMonth = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final values = _showMonth ? widget.dailyValues : widget.monthlyValues;

    String monthName(int month) {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return months[month - 1];
    }

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
                          _showMonth
                              ? '${monthName(widget.referenceDate.month)} '
                                    '${widget.referenceDate.year}'
                              : '${widget.referenceDate.year}',
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
                        _showMonth
                            ? 'Today (Day ${widget.referenceDate.day})'
                            : 'Current year',
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
                              amount: values.isEmpty
                                  ? 0
                                  : values.reduce((a, b) => a > b ? a : b),
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
                    _showMonth ? 'Daily spending' : '12-month view',
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
                child: _DailyBarChart(
                  values: values,
                  currentIndex: _showMonth
                      ? widget.referenceDate.day - 1
                      : widget.referenceDate.month - 1,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _showMonth
                    ? const [
                        _AxisLabel(label: 'Day 1'),
                        _AxisLabel(label: 'Day 10'),
                        _AxisLabel(label: 'Day 20'),
                        _AxisLabel(label: 'Day 30'),
                      ]
                    : const [
                        _AxisLabel(label: 'Jan'),
                        _AxisLabel(label: 'Apr'),
                        _AxisLabel(label: 'Jul'),
                        _AxisLabel(label: 'Oct'),
                        _AxisLabel(label: 'Dec'),
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
  const _DailyBarChart({required this.values, required this.currentIndex});

  final List<double> values;
  final int currentIndex;

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

        final isPeak = value == maxValue;
        final isToday = index == currentIndex;

        final isFuture = index > currentIndex;

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
    required this.convertedAmount,
  });

  final String currencySymbol;
  final List<Transaction> transactions;
  final double Function(Transaction) convertedAmount;

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
                    convertedAmount: convertedAmount(transaction),
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
    required this.convertedAmount,
  });

  final Transaction transaction;
  final String currencySymbol;
  final double convertedAmount;

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

    final date = '${months[dateTime.month - 1]} ${dateTime.day}';

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
        iconBackground = colors.errorContainer.withValues(alpha: 0.65);
        icon = Icons.shopping_bag_outlined;
        break;

      case TransactionType.income:
        accentColor = colors.tertiary;
        iconBackground = colors.tertiaryContainer.withValues(alpha: 0.45);
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
              repository: transactionRepository,
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
                        ? -convertedAmount.abs()
                        : convertedAmount.abs(),
                    symbol: currencySymbol,
                    showSign: transaction.type != TransactionType.transfer,
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
    required this.transactions,
    required this.currencySymbol,
    required this.forecastAmount,
    required this.convertMyr,
  });

  final List<Transaction> transactions;
  final String currencySymbol;
  final double forecastAmount;
  final double Function(double) convertMyr;

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
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'DATA ESTIMATE',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: colors.onPrimaryContainer,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Projected spending this month',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 3),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencySymbol,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                MoneyFormatter.amountOnly(forecastAmount),
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
                        'Based on your recorded expenses so far this month.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'This is a simple pace estimate, not a prediction model.',
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
                      currencySymbol: currencySymbol,
                      convertMyr: convertMyr,
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
