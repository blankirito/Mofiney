import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class MonthlyTargetBudgetPage extends StatefulWidget {
  const MonthlyTargetBudgetPage({super.key});

  @override
  State<MonthlyTargetBudgetPage> createState() =>
      _MonthlyTargetBudgetPageState();
}

class _MonthlyTargetBudgetPageState extends State<MonthlyTargetBudgetPage> {
  double _totalBudget = 4000.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const spent = 1842.50;

    final remaining = _totalBudget - spent;
    final usedPercentage = spent / _totalBudget;

    final progressValue = usedPercentage.clamp(0.0, 1.0);

    final isOverBudget = spent > _totalBudget;

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

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'September 2026',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverBudget
                                ? colors.errorContainer
                                : colors.tertiaryContainer.withValues(
                                    alpha: 0.15,
                                  ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            isOverBudget ? 'OVER BUDGET' : 'ON TRACK',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: isOverBudget
                                  ? colors.error
                                  : colors.tertiary,
                              fontSize: 9,
                            ),
                          ),
                        ),

                        const Spacer(),

                        TextButton.icon(
                          onPressed: _editBudgetCap,
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
                      'RM ${_totalBudget.toStringAsFixed(2)}',
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
                            value: 'RM ${spent.toStringAsFixed(2)}',
                          ),
                        ),

                        const SizedBox(width: AppSpacing.xs),

                        Expanded(
                          child: _BudgetSummaryTile(
                            label: isOverBudget ? 'OVER BY' : 'REMAINING',
                            value: 'RM ${remaining.abs().toStringAsFixed(2)}',
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
                        value: progressValue,
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
                          ? 'RM ${remaining.abs().toStringAsFixed(2)} over budget this month'
                          : 'RM ${remaining.toStringAsFixed(2)} remaining this month',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
                    onPressed: _addCategoryBudget,
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),
                    label: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              ..._categoryBudgets.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _CategoryBudgetCard(
                    category: category,
                    onTap: () {
                      _showCategoryBudgetActions(category);
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

  Future<void> _setNewCategoryBudget(
    String name,
    IconData icon,
  ) async {
    String editingValue = '';

    final budget = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Set $name Budget'),
          content: TextFormField(
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Monthly Budget',
              prefixText: 'RM ',
              hintText: '0.00',
            ),
            onChanged: (value) {
              editingValue = value;
            },
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
                final value = double.tryParse(
                  editingValue.trim(),
                );

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },
              child: const Text('Set Budget'),
            ),
          ],
        );
      },
    );

    if (budget == null || !mounted) {
      return;
    }

    setState(() {
      _categoryBudgets.add(
        _CategoryBudget(
          name: name,
          icon: icon,
          spent: 0,
          budget: budget,
        ),
      );
    });
  }

  Future<void> _addCategoryBudget() async {
    const availableCategories = [
      ('Bills & Utilities', Icons.receipt_long_outlined),
      ('Health', Icons.favorite_border_rounded),
      ('Travel', Icons.flight_outlined),
    ];

    final selectedCategory =
        await showModalBottomSheet<(String, IconData)>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
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
                Text(
                  'Set Category Budget',
                  style: AppTextStyles.headlineMedium,
                ),

                const SizedBox(height: 4),

                Text(
                  'Choose a category without a monthly budget.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                ...availableCategories.map(
                  (category) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(category.$2),
                    title: Text(category.$1),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                        category,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCategory == null || !mounted) {
      return;
    }

    await _setNewCategoryBudget(
      selectedCategory.$1,
      selectedCategory.$2,
    );
  }

  Future<void> _showCategoryBudgetActions(_CategoryBudget category) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
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
                Text(category.name, style: AppTextStyles.headlineMedium),

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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
        );
      },
    );
  }

  Future<void> _removeCategoryBudget(
    _CategoryBudget category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Category Budget?'),
          content: Text(
            'Remove the monthly budget limit for ${category.name}? '
            'Your transactions will not be deleted.',
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _categoryBudgets.remove(category);
    });
  }

  Future<void> _editCategoryBudget(
    _CategoryBudget category,
  ) async {
    String editingValue = category.budget.toStringAsFixed(2);

    final newBudget = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${category.name} Budget'),
          content: TextFormField(
            initialValue: editingValue,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Category Budget',
              prefixText: 'RM ',
            ),
            onChanged: (value) {
              editingValue = value;
            },
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
                final value = double.tryParse(
                  editingValue.trim(),
                );

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newBudget == null || !mounted) {
      return;
    }

    final index = _categoryBudgets.indexOf(category);

    if (index == -1) {
      return;
    }

    setState(() {
      _categoryBudgets[index] = _CategoryBudget(
        name: category.name,
        icon: category.icon,
        spent: category.spent,
        budget: newBudget,
      );
    });
  }

  final List<_CategoryBudget> _categoryBudgets = [
    _CategoryBudget(
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      spent: 620.50,
      budget: 800.00,
    ),
    _CategoryBudget(
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      spent: 285.00,
      budget: 500.00,
    ),
    _CategoryBudget(
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      spent: 410.00,
      budget: 350.00,
    ),
    _CategoryBudget(
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      spent: 95.00,
      budget: 150.00,
    ),
  ];

  Future<void> _editBudgetCap() async {
    String editingValue = _totalBudget.toStringAsFixed(2);

    final newBudget = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Monthly Budget'),
          content: TextFormField(
            initialValue: editingValue,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly Budget',
              prefixText: 'RM ',
            ),
            onChanged: (value) {
              editingValue = value;
            },
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
                final value = double.tryParse(editingValue.trim());

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newBudget == null || !mounted) {
      return;
    }

    setState(() {
      _totalBudget = newBudget;
    });
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

class _CategoryBudget {
  const _CategoryBudget({
    required this.name,
    required this.icon,
    required this.spent,
    required this.budget,
  });

  final String name;
  final IconData icon;
  final double spent;
  final double budget;
}

class _CategoryBudgetCard extends StatelessWidget {
  const _CategoryBudgetCard({required this.category, required this.onTap});

  final _CategoryBudget category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final percentage = category.spent / category.budget;
    final progressValue = percentage.clamp(0.0, 1.0);
    final remaining = category.budget - category.spent;
    final isOverBudget = category.spent > category.budget;

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
            color: colors.outlineVariant.withValues(alpha: 0.4),
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
                    category.icon,
                    size: 20,
                    color: colors.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Text(
                    category.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: isOverBudget ? colors.error : colors.primary,
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
                  'RM ${category.spent.toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    '/ RM ${category.budget.toStringAsFixed(2)}',
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
                value: progressValue,
                minHeight: 7,
                backgroundColor: colors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? colors.error : colors.primary,
                ),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              isOverBudget
                  ? 'RM ${remaining.abs().toStringAsFixed(2)} over budget'
                  : 'RM ${remaining.toStringAsFixed(2)} remaining',
              style: AppTextStyles.bodySmall.copyWith(
                color: isOverBudget ? colors.error : colors.onSurfaceVariant,
                fontWeight: isOverBudget ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
