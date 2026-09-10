import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../domain/transaction.dart';

import 'transaction_detail_page.dart';

import '../data/transaction_repository.dart';

import 'dart:async';

import '../../../core/app_dependencies.dart';
import '../../../core/database/app_database.dart';
import '../../../core/currency/currency_catalog.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.repository});

  final TransactionRepository repository;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  TransactionType? _selectedType;

  String? _selectedAccount;
  String? _selectedCategory;

  double? _minAmount;
  double? _maxAmount;

  DateTime? _startDate;
  DateTime? _endDate;

  List<Transaction> _transactions = [];

  bool _isLoading = true;

  String? _errorMessage;

  StreamSubscription<List<Transaction>>? _transactionsSubscription;
  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;
  String _baseCurrency = 'MYR';

  @override
  void initState() {
    super.initState();

    _watchTransactions();
    _settingsSubscription = appSettingsRepository.watchSettings().listen((
      settings,
    ) {
      if (mounted && settings != null) {
        setState(() {
          _baseCurrency = settings.baseCurrency;
        });
      }
    });
  }

  void _watchTransactions() {
    _transactionsSubscription?.cancel();

    _transactionsSubscription = widget.repository.watchAllTransactions().listen(
      (transactions) {
        if (!mounted) {
          return;
        }

        setState(() {
          _transactions = transactions;
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      },
    );
  }

  double _convertedAmount(Transaction transaction) {
    return transaction.amount;
  }

  String get _currencySymbol => CurrencyCatalog.find(_baseCurrency).symbol;

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    _settingsSubscription?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 40),
                  const SizedBox(height: 12),
                  const Text('Failed to load transactions'),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      _watchTransactions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
              Text(
                'Transactions',
                style: AppTextStyles.headlineLargeMobile.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _buildSearchBar(context),

              const SizedBox(height: AppSpacing.sm),

              _buildTypeTabs(context),

              const SizedBox(height: AppSpacing.md),

              _buildFilterChips(context),

              const SizedBox(height: AppSpacing.md),

              _buildCashFlowSummary(context),

              const SizedBox(height: AppSpacing.md),

              _buildTransactionList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search merchant, category, account...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTabs(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TransactionTypeTab(
              label: 'All',
              selected: _selectedType == null,
              onTap: () {
                setState(() {
                  _selectedType = null;
                });
              },
            ),
          ),
          Expanded(
            child: _TransactionTypeTab(
              label: 'Expense',
              selected: _selectedType == TransactionType.expense,
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.expense;
                });
              },
            ),
          ),
          Expanded(
            child: _TransactionTypeTab(
              label: 'Income',
              selected: _selectedType == TransactionType.income,
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.income;
                });
              },
            ),
          ),
          Expanded(
            child: _TransactionTypeTab(
              label: 'Transfer',
              selected: _selectedType == TransactionType.transfer,
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.transfer;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipButton(
            label: 'Date',
            value: _dateFilterLabel(),
            icon: Icons.calendar_today_outlined,
            onTap: () => _showDateFilter(context),
          ),

          const SizedBox(width: AppSpacing.xs),

          _FilterChipButton(
            label: 'Account',
            value: _selectedAccount ?? 'All',
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => _showAccountFilter(context),
          ),

          const SizedBox(width: AppSpacing.xs),

          _FilterChipButton(
            label: 'Category',
            value: _selectedCategory ?? 'All',
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => _showCategoryFilter(context),
          ),

          const SizedBox(width: AppSpacing.xs),

          _FilterChipButton(
            label: 'Type',
            value: _selectedType == null
                ? 'All'
                : switch (_selectedType!) {
                    TransactionType.expense => 'Expense',
                    TransactionType.income => 'Income',
                    TransactionType.transfer => 'Transfer',
                  },
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => _showTypeFilter(context),
          ),

          const SizedBox(width: AppSpacing.xs),

          _FilterChipButton(
            label: 'Amount',
            value: _amountFilterLabel(),
            icon: Icons.unfold_more_rounded,
            onTap: () => _showAmountFilter(context),
          ),
        ],
      ),
    );
  }

  String _dateFilterLabel() {
    if (_startDate == null && _endDate == null) {
      return 'All';
    }

    final now = DateTime.now();

    final thisMonthStart = DateTime(now.year, now.month, 1);

    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final last3MonthsStart = DateTime(now.year, now.month - 3, 1);

    final last3MonthsEnd = DateTime(now.year, now.month, 0);

    if (_sameDateValue(_startDate, thisMonthStart) &&
        _sameDateValue(_endDate, thisMonthEnd)) {
      return 'This Month';
    }

    if (_sameDateValue(_startDate, lastMonthStart) &&
        _sameDateValue(_endDate, lastMonthEnd)) {
      return 'Last Month';
    }

    if (_sameDateValue(_startDate, last3MonthsStart) &&
        _sameDateValue(_endDate, last3MonthsEnd)) {
      return 'Last 3 Months';
    }

    return 'Custom';
  }

  bool _sameDateValue(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _amountFilterLabel() {
    if (_minAmount == null && _maxAmount == null) {
      return 'All';
    }

    if (_minAmount != null && _maxAmount != null) {
      return '$_currencySymbol ${_minAmount!.toStringAsFixed(0)} - $_currencySymbol ${_maxAmount!.toStringAsFixed(0)}';
    }

    if (_minAmount != null) {
      return '≥ $_currencySymbol ${_minAmount!.toStringAsFixed(0)}';
    }

    return '≤ $_currencySymbol ${_maxAmount!.toStringAsFixed(0)}';
  }

  void _applyThisMonth() {
    final now = DateTime.now();

    setState(() {
      _startDate = DateTime(now.year, now.month, 1);

      _endDate = DateTime(now.year, now.month + 1, 0);
    });
  }

  void _applyLastMonth() {
    final now = DateTime.now();

    setState(() {
      _startDate = DateTime(now.year, now.month - 1, 1);

      _endDate = DateTime(now.year, now.month, 0);
    });
  }

  void _applyLast3Months() {
    final now = DateTime.now();

    setState(() {
      _startDate = DateTime(now.year, now.month - 3, 1);

      _endDate = DateTime(now.year, now.month, 0);
    });
  }

  void _showDateFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Dates'),
                onTap: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });

                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: const Text('This Month'),
                onTap: () {
                  _applyThisMonth();
                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: const Text('Last Month'),
                onTap: () {
                  _applyLastMonth();
                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: const Text('Last 3 Months'),
                onTap: () {
                  _applyLast3Months();
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: const Text('Custom Range'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomDateRange();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCustomDateRange() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _startDate = result.start;
      _endDate = result.end;
    });
  }

  void _showAmountFilter(BuildContext context) {
    final minController = TextEditingController(
      text: _minAmount?.toStringAsFixed(0) ?? '',
    );

    final maxController = TextEditingController(
      text: _maxAmount?.toStringAsFixed(0) ?? '',
    );

    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Range',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Minimum',
                              prefixText: '$_currencySymbol ',
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Maximum',
                              prefixText: '$_currencySymbol ',
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _minAmount = null;
                                _maxAmount = null;
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Reset'),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final minText = minController.text.trim();
                              final maxText = maxController.text.trim();

                              final minValue = minText.isEmpty
                                  ? null
                                  : double.tryParse(minText);

                              final maxValue = maxText.isEmpty
                                  ? null
                                  : double.tryParse(maxText);

                              String? validationError;

                              if (minText.isNotEmpty && minValue == null) {
                                validationError =
                                    'Please enter a valid minimum amount.';
                              } else if (maxText.isNotEmpty &&
                                  maxValue == null) {
                                validationError =
                                    'Please enter a valid maximum amount.';
                              } else if ((minValue != null && minValue < 0) ||
                                  (maxValue != null && maxValue < 0)) {
                                validationError = 'Amount cannot be negative.';
                              } else if (minValue != null &&
                                  maxValue != null &&
                                  minValue > maxValue) {
                                validationError = 'Minimum amount cannot be greater than maximum amount.';
                              }

                              if (validationError != null) {
                                setModalState(() {
                                  errorMessage = validationError;
                                });
                                return;
                              }

                              setState(() {
                                _minAmount = minValue;
                                _maxAmount = maxValue;
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountFilter(BuildContext context) {
    final accounts =
        _transactions
            .expand(
              (transaction) => [
                transaction.account,
                if (transaction.destinationAccount != null)
                  transaction.destinationAccount!,
              ],
            )
            .toSet()
            .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Accounts'),
                trailing: _selectedAccount == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedAccount = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ...accounts.map(
                (account) => ListTile(
                  title: Text(account),
                  trailing: _selectedAccount == account
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAccount = account;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final categories =
        _transactions
            .map((transaction) => transaction.category)
            .toSet()
            .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Categories'),
                trailing: _selectedCategory == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ...categories.map(
                (category) => ListTile(
                  title: Text(category),
                  trailing: _selectedCategory == category
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTypeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeFilterOption(context, label: 'All', type: null),
              _buildTypeFilterOption(
                context,
                label: 'Expense',
                type: TransactionType.expense,
              ),
              _buildTypeFilterOption(
                context,
                label: 'Income',
                type: TransactionType.income,
              ),
              _buildTypeFilterOption(
                context,
                label: 'Transfer',
                type: TransactionType.transfer,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterOption(
    BuildContext context, {
    required String label,
    required TransactionType? type,
  }) {
    return ListTile(
      title: Text(label),
      trailing: _selectedType == type ? const Icon(Icons.check_rounded) : null,
      onTap: () {
        setState(() {
          _selectedType = type;
        });

        Navigator.pop(context);
      },
    );
  }

  String _cashFlowTitle() {
    if (_startDate == null && _endDate == null) {
      return 'ALL TIME CASH FLOW';
    }

    final now = DateTime.now();

    final thisMonthStart = DateTime(now.year, now.month, 1);

    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    if (_sameDateValue(_startDate, thisMonthStart) &&
        _sameDateValue(_endDate, thisMonthEnd)) {
      return '${_monthName(now.month).toUpperCase()} CASH FLOW';
    }

    if (_startDate != null &&
        _endDate != null &&
        _startDate!.year == _endDate!.year &&
        _startDate!.month == _endDate!.month) {
      return '${_monthName(_startDate!.month).toUpperCase()} CASH FLOW';
    }

    return 'SELECTED PERIOD CASH FLOW';
  }

  String _monthName(int month) {
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

  Widget _buildCashFlowSummary(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transactions = _getFilteredTransactions();

    double totalIn = 0;
    double totalOut = 0;

    for (final transaction in transactions) {
      final amount = _convertedAmount(transaction).abs();

      switch (transaction.type) {
        case TransactionType.income:
          totalIn += amount;
          break;

        case TransactionType.expense:
          totalOut += amount;
          break;

        case TransactionType.transfer:
          break;
      }
    }

    final netBalance = totalIn - totalOut;
    final totalFlow = totalIn + totalOut;

    final inflowRatio = totalFlow == 0 ? 0.0 : totalIn / totalFlow;

    final outflowRatio = totalFlow == 0 ? 0.0 : totalOut / totalFlow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _cashFlowTitle(),
                  style: AppTextStyles.labelCaps.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              _CashFlowStatusBadge(
                netBalance: netBalance,
                totalIn: totalIn,
                totalOut: totalOut,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _CashFlowMetric(
                  label: 'Total In',
                  amount: totalIn,
                  prefix: '+',
                  color: colors.tertiary,
                  currencySymbol: _currencySymbol,
                ),
              ),
              Expanded(
                child: _CashFlowMetric(
                  label: 'Total Out',
                  amount: totalOut,
                  prefix: '-',
                  color: colors.error,
                  currencySymbol: _currencySymbol,
                ),
              ),
              Expanded(
                child: _CashFlowMetric(
                  label: 'Net Balance',
                  amount: netBalance.abs(),
                  prefix: netBalance >= 0 ? '+' : '-',
                  color: netBalance >= 0 ? colors.primary : colors.error,
                  currencySymbol: _currencySymbol,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (inflowRatio > 0)
                    Expanded(
                      flex: (inflowRatio * 1000).round(),
                      child: Container(color: colors.tertiary),
                    ),
                  if (outflowRatio > 0)
                    Expanded(
                      flex: (outflowRatio * 1000).round(),
                      child: Container(color: colors.error),
                    ),
                  if (totalFlow == 0)
                    Expanded(
                      child: Container(color: colors.surfaceContainerHigh),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Transaction> _getFilteredTransactions() {
    return _transactions.where((transaction) {
      final matchesType =
          _selectedType == null || transaction.type == _selectedType;

      final matchesAccount =
          _selectedAccount == null ||
          transaction.account == _selectedAccount ||
          transaction.destinationAccount == _selectedAccount;

      final matchesCategory =
          _selectedCategory == null ||
          transaction.category == _selectedCategory;

      final searchableText = [
        transaction.title,
        transaction.category,
        transaction.account,
        transaction.destinationAccount ?? '',
        transaction.paymentMethod ?? '',
      ].join(' ').toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty || searchableText.contains(_searchQuery);

      final amount = transaction.amount.abs();

      final matchesMinAmount = _minAmount == null || amount >= _minAmount!;

      final matchesMaxAmount = _maxAmount == null || amount <= _maxAmount!;

      final transactionDate = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );

      final matchesStartDate =
          _startDate == null || !transactionDate.isBefore(_startDate!);

      final matchesEndDate =
          _endDate == null || !transactionDate.isAfter(_endDate!);

      return matchesType &&
          matchesAccount &&
          matchesCategory &&
          matchesMinAmount &&
          matchesMaxAmount &&
          matchesStartDate &&
          matchesEndDate &&
          matchesSearch;
    }).toList();
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final groups = <DateTime, List<Transaction>>{};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );

      groups.putIfAbsent(date, () => []);
      groups[date]!.add(transaction);
    }

    for (final transactions in groups.values) {
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    final sortedEntries = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildTransactionList(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredTransactions = _getFilteredTransactions();

    final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${filteredTransactions.length} transactions found',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        if (filteredTransactions.isEmpty)
          Text(
            'No records found',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          )
        else
          Column(
            children: groupedTransactions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _TransactionGroup(
                  date: entry.key,
                  transactions: entry.value,
                  repository: widget.repository,
                  currencySymbol: _currencySymbol,
                  convertedAmount: _convertedAmount,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _TransactionTypeTab extends StatelessWidget {
  const _TransactionTypeTab({
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (value != null) ...[
                      TextSpan(
                        text: ': ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: value!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.repository,
    required this.currencySymbol,
    required this.convertedAmount,
  });

  final Transaction transaction;
  final TransactionRepository repository;
  final String currencySymbol;
  final double convertedAmount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Color amountColor;
    IconData icon;
    Color iconBackground;

    switch (transaction.type) {
      case TransactionType.expense:
        amountColor = colors.error;
        icon = Icons.shopping_bag_outlined;
        iconBackground = colors.errorContainer.withValues(alpha: 0.5);
        break;

      case TransactionType.income:
        amountColor = colors.tertiary;
        icon = Icons.payments_outlined;
        iconBackground = colors.tertiaryContainer.withValues(alpha: 0.5);
        break;

      case TransactionType.transfer:
        amountColor = colors.onSurfaceVariant;
        icon = Icons.swap_horiz_rounded;
        iconBackground = colors.secondaryContainer;
        break;
    }

    String amountText;

    switch (transaction.type) {
      case TransactionType.expense:
        amountText =
            '− $currencySymbol ${convertedAmount.abs().toStringAsFixed(2)}';
        break;

      case TransactionType.income:
        amountText =
            '+ $currencySymbol ${convertedAmount.abs().toStringAsFixed(2)}';
        break;

      case TransactionType.transfer:
        amountText =
            '$currencySymbol ${convertedAmount.abs().toStringAsFixed(2)}';
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transaction: transaction,
              repository: repository,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 21, color: amountColor),
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
                    transaction.type == TransactionType.transfer &&
                            transaction.destinationAccount != null
                        ? '${transaction.account} → ${transaction.destinationAccount}'
                        : '${transaction.category} • ${transaction.account}',
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

            Text(
              amountText,
              style: AppTextStyles.amountMedium.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({
    required this.date,
    required this.transactions,
    required this.repository,
    required this.currencySymbol,
    required this.convertedAmount,
  });

  final DateTime date;
  final List<Transaction> transactions;
  final TransactionRepository repository;
  final String currencySymbol;
  final double Function(Transaction) convertedAmount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final groupTotal = transactions.fold<double>(0, (total, transaction) {
      switch (transaction.type) {
        case TransactionType.expense:
          return total - convertedAmount(transaction).abs();

        case TransactionType.income:
          return total + convertedAmount(transaction).abs();

        case TransactionType.transfer:
          return total;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _dateTitle(date),
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '  •  ${_formatDate(date)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Text(
                _formatGroupTotal(groupTotal),
                style: AppTextStyles.amountSmall.copyWith(
                  color: groupTotal > 0
                      ? colors.tertiary
                      : groupTotal < 0
                      ? colors.error
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
              return Column(
                children: [
                  _TransactionRow(
                    transaction: transactions[index],
                    repository: repository,
                    currencySymbol: currencySymbol,
                    convertedAmount: convertedAmount(transactions[index]),
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

  String _dateTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    if (_sameDate(date, today)) {
      return 'Today';
    }

    if (_sameDate(date, yesterday)) {
      return 'Yesterday';
    }

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatGroupTotal(double total) {
    if (total > 0) {
      return '+$currencySymbol '
          '${total.abs().toStringAsFixed(2)}';
    }

    if (total < 0) {
      return '−$currencySymbol '
          '${total.abs().toStringAsFixed(2)}';
    }

    return '$currencySymbol 0.00';
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CashFlowMetric extends StatelessWidget {
  const _CashFlowMetric({
    required this.label,
    required this.amount,
    required this.prefix,
    required this.color,
    required this.currencySymbol,
  });

  final String label;
  final double amount;
  final String prefix;
  final Color color;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$prefix $currencySymbol ${amount.toStringAsFixed(2)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.amountSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CashFlowStatusBadge extends StatelessWidget {
  const _CashFlowStatusBadge({
    required this.netBalance,
    required this.totalIn,
    required this.totalOut,
  });

  final double netBalance;
  final double totalIn;
  final double totalOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasNoActivity = totalIn == 0 && totalOut == 0;
    final isPositive = netBalance >= 0;

    String label;

    if (hasNoActivity) {
      label = 'No Activity';
    } else if (isPositive) {
      label = 'Positive';
    } else {
      label = 'Negative';
    }

    final color = hasNoActivity
        ? colors.onSurfaceVariant
        : isPositive
        ? colors.tertiary
        : colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
