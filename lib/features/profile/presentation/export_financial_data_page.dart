import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum _ExportFormat {
  csv,
  pdf,
}

enum _DateRange {
  allTime,
  thisMonth,
  thisYear,
}

class ExportFinancialDataPage extends StatefulWidget {
  const ExportFinancialDataPage({super.key});

  @override
  State<ExportFinancialDataPage> createState() =>
      _ExportFinancialDataPageState();
}

class _ExportFinancialDataPageState
    extends State<ExportFinancialDataPage> {
  _ExportFormat _format = _ExportFormat.csv;
  _DateRange _dateRange = _DateRange.allTime;

  bool _includeTransactions = true;
  bool _includeAccounts = true;
  bool _includeCategories = true;
  bool _includeBudgets = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Financial Data'),
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
              Text(
                'EXPORT FORMAT',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: _FormatCard(
                      icon: Icons.table_chart_outlined,
                      title: 'CSV',
                      subtitle: 'Structured raw data',
                      selected: _format == _ExportFormat.csv,
                      onTap: () {
                        setState(() {
                          _format = _ExportFormat.csv;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: _FormatCard(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF',
                      subtitle: 'Readable finance report',
                      selected: _format == _ExportFormat.pdf,
                      onTap: () {
                        setState(() {
                          _format = _ExportFormat.pdf;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'DATE RANGE',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              DropdownButtonFormField<_DateRange>(
                value: _dateRange,
                decoration: const InputDecoration(
                  labelText: 'Export Period',
                ),
                items: const [
                  DropdownMenuItem(
                    value: _DateRange.allTime,
                    child: Text('All Time'),
                  ),
                  DropdownMenuItem(
                    value: _DateRange.thisMonth,
                    child: Text('This Month'),
                  ),
                  DropdownMenuItem(
                    value: _DateRange.thisYear,
                    child: Text('This Year'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _dateRange = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'DATA TO INCLUDE',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Container(
                width: double.infinity,
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
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _includeTransactions,
                      title: const Text('Transactions'),
                      subtitle: const Text(
                        'Expense, income, and transfer records',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _includeTransactions = value ?? false;
                        });
                      },
                    ),

                    const Divider(height: 1),

                    CheckboxListTile(
                      value: _includeAccounts,
                      title: const Text('Accounts'),
                      subtitle: const Text(
                        'Account names, types, and balances',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _includeAccounts = value ?? false;
                        });
                      },
                    ),

                    const Divider(height: 1),

                    CheckboxListTile(
                      value: _includeCategories,
                      title: const Text('Categories'),
                      subtitle: const Text(
                        'Expense and income categories',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _includeCategories = value ?? false;
                        });
                      },
                    ),

                    const Divider(height: 1),

                    CheckboxListTile(
                      value: _includeBudgets,
                      title: const Text('Budgets'),
                      subtitle: const Text(
                        'Monthly and category budgets',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _includeBudgets = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _format == _ExportFormat.csv
                            ? 'CSV is best for spreadsheets, analysis, and importing structured data.'
                            : 'PDF is best for viewing, sharing, and keeping a human-readable finance report.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canExport
                      ? () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_format == _ExportFormat.csv ? 'CSV' : 'PDF'} export will be connected after Local DB.',
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.file_download_outlined,
                  ),
                  label: Text(
                    _format == _ExportFormat.csv
                        ? 'Export CSV'
                        : 'Export PDF',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canExport =>
      _includeTransactions ||
      _includeAccounts ||
      _includeCategories ||
      _includeBudgets;
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppRadius.xl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer.withValues(
                  alpha: 0.35,
                )
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(
            AppRadius.xl,
          ),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}