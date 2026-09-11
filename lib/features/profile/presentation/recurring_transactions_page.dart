import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'dart:async';

import '../../../core/app_dependencies.dart';
import '../../../core/utils/money_input_parser.dart';
import '../../accounts/domain/account.dart';
import '../domain/recurring_schedule.dart';
import '../../categories/domain/category.dart';

import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';
import '../../../core/database/app_database.dart';

enum _RecurringFilter { all, expense, income }

enum _RecurringType { expense, income }

class _RecurringItem {
  const _RecurringItem({
    required this.title,
    required this.account,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    required this.type,
    required this.icon,
    required this.isActive,
    required this.id,
    required this.accountId,
  });

  final String title;
  final String account;
  final double amount;
  final String frequency;
  final String nextDate;
  final _RecurringType type;
  final IconData icon;
  final bool isActive;
  final String id;
  final String accountId;
}

class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  _RecurringFilter _filter = _RecurringFilter.all;

  List<RecurringSchedule> _schedules = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<_RecurringItem> _items = [];

  StreamSubscription<List<RecurringSchedule>>? _schedulesSubscription;

  StreamSubscription<List<Account>>? _accountsSubscription;

  StreamSubscription<List<Category>>? _categoriesSubscription;

  AppSettingsEntry? _settings;

  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;

  CurrencyConverter _converter = CurrencyConverter('MYR');

  @override
  void initState() {
    super.initState();

    _watchSchedules();
    _watchAccounts();
    _watchCategories();
    _watchSettings();
  }

  void _watchSchedules() {
    _schedulesSubscription?.cancel();

    _schedulesSubscription = recurringScheduleRepository
        .watchAllSchedules()
        .listen(
          (schedules) {
            if (!mounted) {
              return;
            }

            setState(() {
              _schedules = schedules;
              _rebuildItems();
            });
          },
          onError: (Object error) {
            debugPrint('Failed to watch recurring schedules: $error');
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
          _rebuildItems();
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch recurring accounts: $error');
      },
    );
  }

  void _watchCategories() {
    _categoriesSubscription?.cancel();

    _categoriesSubscription = categoryRepository.watchAllCategories().listen(
      (categories) {
        if (!mounted) {
          return;
        }

        setState(() {
          _categories = categories;
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch recurring categories: $error');
      },
    );
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

        _refreshConverter();
      },
      onError: (Object error) {
        debugPrint('Failed to watch recurring display settings: $error');
      },
    );
  }

  Future<void> _refreshConverter() async {
    final converter = CurrencyConverter(_baseCurrency);

    await converter.warm(const ['MYR']);

    if (!mounted) {
      return;
    }

    setState(() {
      _converter = converter;
    });
  }

  void _rebuildItems() {
    final accountNames = {
      for (final account in _accounts) account.id: account.name,
    };

    _items = _schedules
        .map(
          (schedule) => _RecurringItem(
            id: schedule.id,
            title: schedule.title,
            accountId: schedule.accountId,
            account: accountNames[schedule.accountId] ?? 'Archived account',
            amount: schedule.amount,
            frequency: schedule.frequency,
            nextDate: _formatScheduleDate(schedule.nextDate),
            type: schedule.type == RecurringScheduleType.expense
                ? _RecurringType.expense
                : _RecurringType.income,
            icon: _iconFromCodePoint(schedule.iconCodePoint),
            isActive: schedule.isActive,
          ),
        )
        .toList();
  }

  String _formatScheduleDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    _accountsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _settingsSubscription?.cancel();

    super.dispose();
  }

  String get _baseCurrency {
    return _settings?.baseCurrency ?? 'MYR';
  }

  String get _currencySymbol {
    return CurrencyCatalog.find(_baseCurrency).symbol;
  }

  String _money(double amount) {
    final displayAmount = _converter.convert(amount, 'MYR');

    return '$_currencySymbol ${displayAmount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredItems = _items.where((item) {
      switch (_filter) {
        case _RecurringFilter.all:
          return true;
        case _RecurringFilter.expense:
          return item.type == _RecurringType.expense;
        case _RecurringFilter.income:
          return item.type == _RecurringType.income;
      }
    }).toList();

    final monthlyExpense = _items
        .where((item) => item.type == _RecurringType.expense && item.isActive)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final monthlyIncome = _items
        .where((item) => item.type == _RecurringType.income && item.isActive)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final net = monthlyIncome - monthlyExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: SafeArea(
        top: false,
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
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'MONTHLY OUTFLOW',
                      value: '-${_money(monthlyExpense)}',
                      isNegative: true,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Expanded(
                    child: _SummaryTile(
                      label: 'MONTHLY INFLOW',
                      value: '+${_money(monthlyIncome)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Text(
                      'Estimated Net',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${net >= 0 ? '+' : '-'}${_money(net.abs())}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: net >= 0 ? colors.tertiary : colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        label: 'All',
                        count: _items.length,
                        selected: _filter == _RecurringFilter.all,
                        onTap: () {
                          setState(() {
                            _filter = _RecurringFilter.all;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        label: 'Expense',
                        count: _items
                            .where(
                              (item) => item.type == _RecurringType.expense,
                            )
                            .length,
                        selected: _filter == _RecurringFilter.expense,
                        onTap: () {
                          setState(() {
                            _filter = _RecurringFilter.expense;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _FilterTab(
                        label: 'Income',
                        count: _items
                            .where((item) => item.type == _RecurringType.income)
                            .length,
                        selected: _filter == _RecurringFilter.income,
                        onTap: () {
                          setState(() {
                            _filter = _RecurringFilter.income;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Text(
                    'SCHEDULED ITEMS',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  TextButton.icon(
                    onPressed: _addRecurring,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              ...filteredItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _RecurringCard(
                    item: item,
                    amountLabel: _money(item.amount),
                    onToggleActive: () {
                      _toggleRecurring(item);
                    },
                    onEdit: () {
                      _editRecurring(item);
                    },
                    onDelete: () {
                      _deleteRecurring(item);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addRecurring() async {
    final activeAccounts = _accounts
        .where((account) => account.isActive)
        .toList();

    if (activeAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create an active account before adding a recurring schedule.',
          ),
        ),
      );
      return;
    }

    _RecurringType selectedType = _RecurringType.expense;
    Account selectedAccount = activeAccounts.first;

    List<Category> categoriesForType(_RecurringType type) {
      final categoryType = type == _RecurringType.expense
          ? CategoryType.expense
          : CategoryType.income;

      return _categories
          .where(
            (category) => category.type == categoryType && category.isActive,
          )
          .toList();
    }

    Category? selectedCategory = categoriesForType(selectedType).isEmpty
        ? null
        : categoriesForType(selectedType).first;

    String title = '';
    String amountText = '';
    String frequency = 'Monthly';
    DateTime nextDate = DateTime.now();

    final schedule = await showDialog<RecurringSchedule>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final availableCategories = categoriesForType(selectedType);

            return AlertDialog(
              title: const Text('Add Recurring Schedule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<_RecurringType>(
                      segments: const [
                        ButtonSegment(
                          value: _RecurringType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward_rounded),
                        ),
                        ButtonSegment(
                          value: _RecurringType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward_rounded),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (value) {
                        setDialogState(() {
                          selectedType = value.first;

                          final categories = categoriesForType(selectedType);

                          selectedCategory = categories.isEmpty
                              ? null
                              : categories.first;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextFormField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Netflix',
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: 'RM ',
                      ),
                      onChanged: (value) {
                        amountText = value;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<Account>(
                      value: selectedAccount,
                      decoration: const InputDecoration(labelText: 'Account'),
                      items: activeAccounts
                          .map(
                            (account) => DropdownMenuItem(
                              value: account,
                              child: Text(account.name),
                            ),
                          )
                          .toList(),
                      onChanged: (account) {
                        if (account == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedAccount = account;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: availableCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged: (category) {
                        setDialogState(() {
                          selectedCategory = category;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<String>(
                      value: frequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'Monthly',
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'Yearly',
                          child: Text('Yearly'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          frequency = value;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Next Date'),
                      subtitle: Text(
                        '${nextDate.day}/${nextDate.month}/${nextDate.year}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: nextDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );

                        if (selected == null) {
                          return;
                        }

                        setDialogState(() {
                          nextDate = selected;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final trimmedTitle = title.trim();
                    final amount = MoneyInputParser.parse(amountText);

                    if (trimmedTitle.isEmpty ||
                        amount == null ||
                        amount <= 0 ||
                        selectedCategory == null) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      RecurringSchedule(
                        id: 'recurring_${DateTime.now().microsecondsSinceEpoch}',
                        title: trimmedTitle,
                        accountId: selectedAccount.id,
                        category: selectedCategory!.name,
                        amount: amount,
                        type: selectedType == _RecurringType.expense
                            ? RecurringScheduleType.expense
                            : RecurringScheduleType.income,
                        frequency: frequency,
                        nextDate: nextDate,
                        iconCodePoint: selectedCategory!.iconCodePoint,
                        isActive: true,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (schedule == null) {
      return;
    }

    await recurringScheduleRepository.insertSchedule(schedule);
  }

  Future<void> _deleteRecurring(_RecurringItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Recurring Transaction?'),
          content: Text(
            'Delete "${item.title}" recurring schedule? '
            'Existing transactions will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await recurringScheduleRepository.deleteSchedule(item.id);
  }

  Future<void> _editRecurring(_RecurringItem item) async {
    String editingTitle = item.title;
    String editingAmount = item.amount.toStringAsFixed(2);
    String editingFrequency = item.frequency;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Recurring Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: item.title,
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (value) {
                        editingTitle = value;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextFormField(
                      initialValue: item.amount.toStringAsFixed(2),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: 'RM ',
                      ),
                      onChanged: (value) {
                        editingAmount = value;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<String>(
                      value: editingFrequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'Monthly',
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'Yearly',
                          child: Text('Yearly'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          editingFrequency = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = editingTitle.trim();
                    final amount = double.tryParse(editingAmount.trim());

                    if (title.isEmpty || amount == null || amount <= 0) {
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'title': title,
                      'amount': amount,
                      'frequency': editingFrequency,
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    final index = _schedules.indexWhere((schedule) => schedule.id == item.id);

    if (index == -1) {
      return;
    }

    final existingSchedule = _schedules[index];

    await recurringScheduleRepository.updateSchedule(
      existingSchedule.copyWith(
        title: result['title'] as String,
        amount: result['amount'] as double,
        frequency: result['frequency'] as String,
      ),
    );
  }

  Future<void> _toggleRecurring(_RecurringItem item) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == item.id);

    if (index == -1) {
      return;
    }

    final schedule = _schedules[index];

    await recurringScheduleRepository.updateSchedule(
      schedule.copyWith(isActive: !schedule.isActive),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  final String label;
  final String value;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: AppTextStyles.amountSmall.copyWith(
              color: isNegative ? colors.error : colors.tertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(
          '$label ($count)',
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.item,
    required this.amountLabel,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final _RecurringItem item;
  final String amountLabel;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = item.type == _RecurringType.expense;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: item.isActive ? 1.0 : 0.55,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(item.icon, color: colors.primary),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.account,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}$amountLabel',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: isExpense ? colors.error : colors.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.frequency,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    item.isActive
                        ? Icons.calendar_today_outlined
                        : Icons.pause_circle_outline_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      item.isActive ? 'Next: ${item.nextDate}' : 'Paused',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: item.isActive
                          ? colors.primaryContainer
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      item.isActive ? 'ACTIVE' : 'PAUSED',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: item.isActive
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                TextButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(
                    item.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(item.isActive ? 'Pause' : 'Resume'),
                ),

                const Spacer(),

                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),

                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: colors.error,
                  ),
                  label: Text('Delete', style: TextStyle(color: colors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFromCodePoint(int codePoint) {
  const icons = [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.local_grocery_store_outlined,
    Icons.shopping_bag_outlined,
    Icons.movie_outlined,
    Icons.work_outline_rounded,
    Icons.payments_outlined,
    Icons.receipt_long_outlined,
    Icons.category_outlined,
  ];

  return icons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.category_outlined,
  );
}
