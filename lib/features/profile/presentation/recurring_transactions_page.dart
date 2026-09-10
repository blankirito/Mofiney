import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
  });

  final String title;
  final String account;
  final double amount;
  final String frequency;
  final String nextDate;
  final _RecurringType type;
  final IconData icon;
  final bool isActive;
}

class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  _RecurringFilter _filter = _RecurringFilter.all;

  final List<_RecurringItem> _items = [
    _RecurringItem(
      title: 'Spotify Premium',
      account: 'Maybank',
      amount: 24.90,
      frequency: 'Monthly',
      nextDate: '18 Sep 2026',
      type: _RecurringType.expense,
      icon: Icons.graphic_eq_rounded,
      isActive: true,
    ),
    _RecurringItem(
      title: 'Mobile Plan',
      account: 'Maybank',
      amount: 50.00,
      frequency: 'Monthly',
      nextDate: '22 Sep 2026',
      type: _RecurringType.expense,
      icon: Icons.phone_android_rounded,
      isActive: true,
    ),
    _RecurringItem(
      title: 'Salary',
      account: 'CIMB',
      amount: 4000.00,
      frequency: 'Monthly',
      nextDate: '1 Oct 2026',
      type: _RecurringType.income,
      icon: Icons.work_outline_rounded,
      isActive: true,
    ),
  ];

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
                      value: '-RM ${monthlyExpense.toStringAsFixed(2)}',
                      isNegative: true,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Expanded(
                    child: _SummaryTile(
                      label: 'MONTHLY INFLOW',
                      value: '+RM ${monthlyIncome.toStringAsFixed(2)}',
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
                      '${net >= 0 ? '+' : '-'}RM ${net.abs().toStringAsFixed(2)}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: net >= 0
                          ? colors.tertiary
                          : colors.error,
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
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),
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
    _RecurringType selectedType = _RecurringType.expense;
    String title = '';
    String amountText = '';
    String account = 'Maybank';
    String frequency = 'Monthly';
    DateTime nextDate = DateTime(2026, 9, 18);

    final result = await showDialog<_RecurringItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      keyboardType:
                          const TextInputType.numberWithOptions(
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

                    DropdownButtonFormField<String>(
                      value: account,
                      decoration: const InputDecoration(
                        labelText: 'Account',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Maybank',
                          child: Text('Maybank'),
                        ),
                        DropdownMenuItem(
                          value: 'CIMB',
                          child: Text('CIMB'),
                        ),
                        DropdownMenuItem(
                          value: "Touch 'n Go",
                          child: Text("Touch 'n Go"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          account = value;
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<String>(
                      value: frequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                      ),
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
                      leading: const Icon(
                        Icons.calendar_today_outlined,
                      ),
                      title: const Text('Next Date'),
                      subtitle: Text(
                        '${nextDate.day}/${nextDate.month}/${nextDate.year}',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: nextDate,
                          firstDate: DateTime(2026, 1, 1),
                          lastDate: DateTime(2035, 12, 31),
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
                    final amount = double.tryParse(
                      amountText.trim(),
                    );

                    if (trimmedTitle.isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _RecurringItem(
                        title: trimmedTitle,
                        account: account,
                        amount: amount,
                        frequency: frequency,
                        nextDate:
                            '${nextDate.day}/${nextDate.month}/${nextDate.year}',
                        type: selectedType,
                        icon: selectedType ==
                                _RecurringType.expense
                            ? Icons.receipt_long_outlined
                            : Icons.payments_outlined,
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

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _items.add(result);
    });
  }

  Future<void> _deleteRecurring(
    _RecurringItem item,
  ) async {
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

    setState(() {
      _items.remove(item);
    });
  }

  Future<void> _editRecurring(
    _RecurringItem item,
  ) async {
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
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      onChanged: (value) {
                        editingTitle = value;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextFormField(
                      initialValue: item.amount.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(
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
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                      ),
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
                    final amount = double.tryParse(
                      editingAmount.trim(),
                    );

                    if (title.isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      {
                        'title': title,
                        'amount': amount,
                        'frequency': editingFrequency,
                      },
                    );
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

    final index = _items.indexOf(item);

    if (index == -1) {
      return;
    }

    setState(() {
      _items[index] = _RecurringItem(
        title: result['title'] as String,
        account: item.account,
        amount: result['amount'] as double,
        frequency: result['frequency'] as String,
        nextDate: item.nextDate,
        type: item.type,
        icon: item.icon,
        isActive: item.isActive,
      );
    });
  }

  void _toggleRecurring(_RecurringItem item) {
    final index = _items.indexOf(item);

    if (index == -1) {
      return;
    }

    setState(() {
      _items[index] = _RecurringItem(
        title: item.title,
        account: item.account,
        amount: item.amount,
        frequency: item.frequency,
        nextDate: item.nextDate,
        type: item.type,
        icon: item.icon,
        isActive: !item.isActive,
      );
    });
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
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final _RecurringItem item;
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
                      '${isExpense ? '-' : '+'}RM ${item.amount.toStringAsFixed(2)}',
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
