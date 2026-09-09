import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onTransfer,
    required this.onScanReceipt,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onTransfer;
  final VoidCallback onScanReceipt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(
                    AppRadius.full,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Add',
                        style:
                            AppTextStyles.headlineLargeMobile.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'What would you like to record?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            /// First row
            Row(
              children: [
                Expanded(
                  child: _QuickAddCard(
                    title: 'Add Expense',
                    subtitle: 'Record spending',
                    icon: Icons.arrow_outward_rounded,
                    backgroundColor:
                        colors.errorContainer.withValues(alpha: 0.45),
                    iconColor: colors.error,
                    onTap: onAddExpense,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: _QuickAddCard(
                    title: 'Add Income',
                    subtitle: 'Record money received',
                    icon: Icons.south_west_rounded,
                    backgroundColor:
                        colors.tertiaryContainer.withValues(
                      alpha: 0.45,
                    ),
                    iconColor: colors.tertiary,
                    onTap: onAddIncome,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            /// Second row
            Row(
              children: [
                Expanded(
                  child: _QuickAddCard(
                    title: 'Transfer',
                    subtitle: 'Between accounts',
                    icon: Icons.swap_horiz_rounded,
                    backgroundColor:
                        colors.secondaryContainer.withValues(
                      alpha: 0.55,
                    ),
                    iconColor: colors.primary,
                    onTap: onTransfer,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: _QuickAddCard(
                    title: 'Scan Receipt',
                    subtitle: 'Scan and auto-fill',
                    icon: Icons.document_scanner_outlined,
                    backgroundColor:
                        colors.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    iconColor: colors.primary,
                    onTap: onScanReceipt,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Center(
              child: Text(
                'Tap outside or swipe down to dismiss',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  const _QuickAddCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}