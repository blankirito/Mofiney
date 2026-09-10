import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() =>
      _ManageCategoriesPageState();
}

class _ManageCategoriesPageState
    extends State<ManageCategoriesPage> {
  bool _showIncome = false;

  final List<_CategoryItem> _expenseCategories = [
    _CategoryItem(
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
    ),
    _CategoryItem(
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
    ),
    _CategoryItem(
      name: 'Groceries',
      icon: Icons.local_grocery_store_outlined,
    ),
    _CategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
    ),
    _CategoryItem(
      name: 'Entertainment',
      icon: Icons.movie_outlined,
    ),
  ];

  final List<_CategoryItem> _incomeCategories = [
    _CategoryItem(
      name: 'Salary',
      icon: Icons.work_outline_rounded,
    ),
    _CategoryItem(
      name: 'Bonus',
      icon: Icons.card_giftcard_rounded,
    ),
    _CategoryItem(
      name: 'Freelance',
      icon: Icons.laptop_mac_rounded,
    ),
    _CategoryItem(
      name: 'Other Income',
      icon: Icons.payments_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final categories =
        _showIncome ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryTab(
                        label: 'Expenses',
                        selected: !_showIncome,
                        onTap: () {
                          setState(() {
                            _showIncome = false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _CategoryTab(
                        label: 'Income',
                        selected: _showIncome,
                        onTap: () {
                          setState(() {
                            _showIncome = true;
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
                    _showIncome
                        ? 'INCOME CATEGORIES'
                        : 'EXPENSE CATEGORIES',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),

                  TextButton.icon(
                    onPressed: _addCategory,
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),
                    label: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: _CategoryCard(
                    category: category,
                    onTap: () {
                      _showCategoryActions(category);
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

  Future<void> _editCategory(
    _CategoryItem category,
  ) async {
    String editingName = category.name;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextFormField(
            initialValue: category.name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
            onChanged: (value) {
              editingName = value;
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
                final trimmed = editingName.trim();

                if (trimmed.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  trimmed,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName == null || !mounted) {
      return;
    }

    final list =
        _showIncome ? _incomeCategories : _expenseCategories;

    final index = list.indexOf(category);

    if (index == -1) {
      return;
    }

    setState(() {
      list[index] = _CategoryItem(
        name: newName,
        icon: category.icon,
      );
    });
  }

  Future<void> _showCategoryActions(
    _CategoryItem category,
  ) async {
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
                Text(
                  category.name,
                  style: AppTextStyles.headlineMedium,
                ),

                const SizedBox(height: AppSpacing.sm),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Category'),
                  subtitle: const Text(
                    'Change category name',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editCategory(category);
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete Category',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Delete this custom category',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteCategory(category);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteCategory(
    _CategoryItem category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'Delete "${category.name}"? '
            'This will remove the category from your list.',
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

    final list =
        _showIncome ? _incomeCategories : _expenseCategories;

    setState(() {
      list.remove(category);
    });
  }

  Future<void> _addCategory() async {
    String categoryName = '';

    final newCategory = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _showIncome
                ? 'Add Income Category'
                : 'Add Expense Category',
          ),
          content: TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
            onChanged: (value) {
              categoryName = value;
            },
            onFieldSubmitted: (value) {
              final trimmed = value.trim();

              if (trimmed.isNotEmpty) {
                Navigator.pop(
                  dialogContext,
                  trimmed,
                );
              }
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
                final trimmed = categoryName.trim();

                if (trimmed.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  trimmed,
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newCategory == null || !mounted) {
      return;
    }

    setState(() {
      final category = _CategoryItem(
        name: newCategory,
        icon: _showIncome
            ? Icons.payments_outlined
            : Icons.category_outlined,
      );

      if (_showIncome) {
        _incomeCategories.add(category);
      } else {
        _expenseCategories.add(category);
      }
    });
  }

}

class _CategoryItem {
  const _CategoryItem({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected
                ? colors.primary
                : colors.onSurfaceVariant,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final _CategoryItem category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
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

          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.more_vert_rounded,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}