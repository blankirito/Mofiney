import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';
import '../../accounts/domain/account.dart';
import '../../categories/domain/category.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/category_budget.dart';

class MonthlyTargetBudgetPage extends StatefulWidget {
  const MonthlyTargetBudgetPage({super.key});

  @override
  State<MonthlyTargetBudgetPage> createState() =>
      _MonthlyTargetBudgetPageState();
}

class _MonthlyTargetBudgetPageState extends State<MonthlyTargetBudgetPage> {
  double _totalBudget = 0;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<CategoryBudget> _categoryBudgets = [];
  List<Account> _accounts = [];
  String _baseCurrency = 'MYR';
  CurrencyConverter _converter = CurrencyConverter('MYR');

  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;
  StreamSubscription<List<Transaction>>? _transactionsSubscription;
  StreamSubscription<List<Category>>? _categoriesSubscription;
  StreamSubscription<List<CategoryBudget>>? _categoryBudgetsSubscription;
  StreamSubscription<List<Account>>? _accountsSubscription;

  @override
  void initState() {
    super.initState();
    _settingsSubscription = appSettingsRepository.watchSettings().listen(
      (settings) {
        if (mounted && settings != null) {
          setState(() {
            _totalBudget = settings.monthlyBudget ?? 0;
            _baseCurrency = settings.baseCurrency;
          });
          _refreshConversion();
        }
      },
      onError: (Object error) =>
          debugPrint('Failed to watch app settings: $error'),
    );
    _transactionsSubscription = transactionRepository
        .watchAllTransactions()
        .listen(
          (transactions) {
            if (mounted) setState(() => _transactions = transactions);
          },
          onError: (Object error) =>
              debugPrint('Failed to watch budget transactions: $error'),
        );
    _categoriesSubscription = categoryRepository.watchAllCategories().listen(
      (categories) {
        if (mounted) setState(() => _categories = categories);
      },
      onError: (Object error) =>
          debugPrint('Failed to watch categories: $error'),
    );
    _categoryBudgetsSubscription = categoryBudgetRepository
        .watchAllCategoryBudgets()
        .listen(
          (budgets) {
            if (mounted) setState(() => _categoryBudgets = budgets);
          },
          onError: (Object error) =>
              debugPrint('Failed to watch category budgets: $error'),
        );
    _accountsSubscription = accountRepository.watchAllAccounts().listen((
      accounts,
    ) {
      if (mounted) {
        setState(() => _accounts = accounts);
        _refreshConversion();
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _categoryBudgetsSubscription?.cancel();
    _accountsSubscription?.cancel();
    super.dispose();
  }

  bool _isCurrentMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  double get _monthlySpent => _transactions
      .where(
        (transaction) =>
            transaction.type == TransactionType.expense &&
            _isCurrentMonth(transaction.dateTime),
      )
      .fold<double>(
        0,
        (sum, transaction) => sum + _convertTransaction(transaction),
      );

  Future<void> _refreshConversion() async {
    final base = _baseCurrency;
    final converter = CurrencyConverter(base);
    await converter.warm(_accounts.map((account) => account.currencyCode));
    if (mounted && base == _baseCurrency)
      setState(() => _converter = converter);
  }

  double _convertTransaction(Transaction transaction) {
    final account = _accounts.where((a) => a.id == transaction.accountId);
    final code = account.isEmpty ? 'MYR' : account.first.currencyCode;
    return _converter.convert(transaction.amount, code);
  }

  String get _currencySymbol => CurrencyCatalog.find(_baseCurrency).symbol;

  List<_CategoryBudgetViewData> get _budgetCards {
    final categoriesById = {
      for (final category in _categories) category.id: category,
    };
    return _categoryBudgets
        .map((budget) {
          final category = categoriesById[budget.categoryId];
          if (category == null) return null;
          final spent = _transactions
              .where(
                (transaction) =>
                    transaction.type == TransactionType.expense &&
                    _isCurrentMonth(transaction.dateTime) &&
                    transaction.category == category.name,
              )
              .fold<double>(
                0,
                (sum, transaction) => sum + _convertTransaction(transaction),
              );
          return _CategoryBudgetViewData(
            category: category,
            budget: budget.monthlyBudget,
            spent: spent,
          );
        })
        .whereType<_CategoryBudgetViewData>()
        .toList()
      ..sort((a, b) => a.category.name.compareTo(b.category.name));
  }

  List<Category> get _availableExpenseCategories {
    final budgetedIds = _categoryBudgets
        .map((budget) => budget.categoryId)
        .toSet();
    return _categories
        .where(
          (category) =>
              category.type == CategoryType.expense &&
              category.isActive &&
              !budgetedIds.contains(category.id),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String get _currentMonthLabel {
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
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spent = _monthlySpent;
    final remaining = _totalBudget - spent;
    final usedPercentage = _totalBudget <= 0 ? 0.0 : spent / _totalBudget;
    final isOverBudget = spent > _totalBudget;
    final cards = _budgetCards;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Target Budget')),
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
                  Text(
                    'Monthly Budget',
                    style: AppTextStyles.headlineLargeMobile.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _MonthChip(label: _currentMonthLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _TotalBudgetCard(
                totalBudget: _totalBudget,
                spent: spent,
                remaining: remaining,
                currencySymbol: _currencySymbol,
                usedPercentage: usedPercentage,
                isOverBudget: isOverBudget,
                onEdit: _editBudgetCap,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Text(
                    'CATEGORY BUDGETS',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _availableExpenseCategories.isEmpty
                        ? null
                        : _addCategoryBudget,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (cards.isEmpty)
                _EmptyCategoryBudgets(
                  onAdd: _availableExpenseCategories.isEmpty
                      ? null
                      : _addCategoryBudget,
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CategoryBudgetCard(
                      category: card,
                      currencySymbol: _currencySymbol,
                      onTap: () => _showCategoryBudgetActions(card),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<double?> _showBudgetEditor({
    required String title,
    required String label,
    double? initialValue,
  }) async {
    var editingValue = initialValue?.toStringAsFixed(2) ?? '';
    return showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: editingValue.isEmpty ? null : editingValue,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            prefixText: '$_currencySymbol ',
            hintText: '0.00',
          ),
          onChanged: (value) => editingValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(editingValue.trim());
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategoryBudget() async {
    final categories = _availableExpenseCategories;
    final category = await showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Category Budget', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Choose an expense category without a monthly budget.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...categories.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFromCodePoint(item.iconCodePoint)),
                  title: Text(item.name),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(sheetContext, item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (category == null || !mounted) return;
    final value = await _showBudgetEditor(
      title: 'Set ${category.name} Budget',
      label: 'Monthly Budget',
    );
    if (value != null) {
      await categoryBudgetRepository.saveCategoryBudget(
        CategoryBudget(categoryId: category.id, monthlyBudget: value),
      );
    }
  }

  Future<void> _showCategoryBudgetActions(
    _CategoryBudgetViewData category,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.category.name, style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Budget'),
                subtitle: const Text('Adjust the monthly category limit'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editCategoryBudget(category);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Remove Category Budget',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: const Text(
                  'Keep transactions, remove only the budget limit',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeCategoryBudget(category);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCategoryBudget(_CategoryBudgetViewData category) async {
    final value = await _showBudgetEditor(
      title: 'Edit ${category.category.name} Budget',
      label: 'Category Budget',
      initialValue: category.budget,
    );
    if (value != null) {
      await categoryBudgetRepository.saveCategoryBudget(
        CategoryBudget(categoryId: category.category.id, monthlyBudget: value),
      );
    }
  }

  Future<void> _removeCategoryBudget(_CategoryBudgetViewData category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Category Budget?'),
        content: Text(
          'Remove the monthly budget limit for ${category.category.name}? Your transactions will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await categoryBudgetRepository.deleteCategoryBudget(category.category.id);
    }
  }

  Future<void> _editBudgetCap() async {
    final value = await _showBudgetEditor(
      title: 'Edit Monthly Budget',
      label: 'Monthly Budget',
      initialValue: _totalBudget,
    );
    if (value != null) await appSettingsRepository.updateMonthlyBudget(value);
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBudgetCard extends StatelessWidget {
  const _TotalBudgetCard({
    required this.totalBudget,
    required this.spent,
    required this.remaining,
    required this.currencySymbol,
    required this.usedPercentage,
    required this.isOverBudget,
    required this.onEdit,
  });
  final double totalBudget;
  final double spent;
  final double remaining;
  final String currencySymbol;
  final double usedPercentage;
  final bool isOverBudget;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = usedPercentage.clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? colors.errorContainer
                      : colors.tertiaryContainer.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isOverBudget ? 'OVER BUDGET' : 'ON TRACK',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: isOverBudget ? colors.error : colors.tertiary,
                    fontSize: 9,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.tune_rounded, size: 17),
                label: const Text('Edit Cap'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'TOTAL BUDGET',
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currencySymbol ${totalBudget.toStringAsFixed(2)}',
            style: AppTextStyles.amountLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _BudgetSummaryTile(
                  label: 'SPENT',
                  value: '$currencySymbol ${spent.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _BudgetSummaryTile(
                  label: isOverBudget ? 'OVER BY' : 'REMAINING',
                  value:
                      '$currencySymbol ${remaining.abs().toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Budget Used',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(usedPercentage * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.amountSmall.copyWith(
                  color: isOverBudget ? colors.error : colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? colors.error : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isOverBudget
                ? '$currencySymbol ${remaining.abs().toStringAsFixed(2)} over budget this month'
                : '$currencySymbol ${remaining.toStringAsFixed(2)} remaining this month',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetSummaryTile extends StatelessWidget {
  const _BudgetSummaryTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
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
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategoryBudgets extends StatelessWidget {
  const _EmptyCategoryBudgets({this.onAdd});
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            color: colors.primary,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No category budgets yet',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set a limit for an expense category to track its monthly spending.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onAdd,
            child: const Text('Add Category Budget'),
          ),
        ],
      ),
    );
  }
}

class _CategoryBudgetViewData {
  const _CategoryBudgetViewData({
    required this.category,
    required this.budget,
    required this.spent,
  });
  final Category category;
  final double budget;
  final double spent;
}

class _CategoryBudgetCard extends StatelessWidget {
  const _CategoryBudgetCard({
    required this.category,
    required this.onTap,
    required this.currencySymbol,
  });
  final _CategoryBudgetViewData category;
  final VoidCallback onTap;
  final String currencySymbol;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percentage = category.spent / category.budget;
    final progress = percentage.clamp(0.0, 1.0);
    final remaining = category.budget - category.spent;
    final over = category.spent > category.budget;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _iconFromCodePoint(category.category.iconCodePoint),
                    size: 20,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    category.category.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: over ? colors.error : colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currencySymbol ${category.spent.toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '/ $currencySymbol ${category.budget.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: colors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  over ? colors.error : colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              over
                  ? '$currencySymbol ${remaining.abs().toStringAsFixed(2)} over budget'
                  : '$currencySymbol ${remaining.toStringAsFixed(2)} remaining',
              style: AppTextStyles.bodySmall.copyWith(
                color: over ? colors.error : colors.onSurfaceVariant,
                fontWeight: over ? FontWeight.w600 : FontWeight.normal,
              ),
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
    Icons.receipt_long_outlined,
    Icons.favorite_border_rounded,
    Icons.flight_outlined,
    Icons.category_outlined,
  ];
  return icons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.category_outlined,
  );
}
