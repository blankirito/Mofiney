import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'account_setup_page.dart';
import 'widgets/onboarding_stepper.dart';
import 'widgets/onboarding_header.dart';
import '../domain/onboarding_data.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key, required this.data});

  final OnboardingData data;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  double selectedBudget = 4000;

  final List<double?> presets = [2500, 3500, 4000, 5000, 6000, null];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnboardingHeader(),
                    const SizedBox(height: AppSpacing.lg),

                    const OnboardingStepper(currentStep: 2),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'STEP 2 OF 4',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Set your monthly budget',
                      style: AppTextStyles.headlineLargeMobile.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Set a spending ceiling to help guide your daily pacing '
                      'and category limits. You can adjust this anytime.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _BudgetSummaryCard(
                      budget: selectedBudget,
                      currencySymbol: 'RM',
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'SELECT TARGET PRESET',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: presets.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.55,
                          ),
                      itemBuilder: (context, index) {
                        final value = presets[index];

                        return _BudgetPresetButton(
                          value: value,
                          selected: value != null && value == selectedBudget,
                          currencySymbol: 'RM',
                          onTap: () {
                            if (value == null) {
                              _showCustomBudgetDialog(context);
                              return;
                            }

                            setState(() {
                              selectedBudget = value;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _BudgetDisclaimer(),
                  ],
                ),
              ),
            ),

            _BudgetBottomActions(
              onSetBudget: () {
                final updatedData = widget.data.copyWith(
                  monthlyBudget: selectedBudget,
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccountSetupPage(data: updatedData),
                  ),
                );
              },
              onSkip: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccountSetupPage(data: widget.data),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomBudgetDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: selectedBudget.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom monthly budget'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'RM ',
              hintText: 'Enter amount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.replaceAll(',', ''),
                );

                if (value != null && value > 0) {
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedBudget = result;
      });
    }
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.budget,
    required this.currencySymbol,
  });

  final double budget;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dailyTarget = budget / 30;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recommended for balanced living',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencySymbol,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                budget.toStringAsFixed(2),
                style: AppTextStyles.amountLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  '≈ $currencySymbol ${dailyTarget.toStringAsFixed(2)} / day target pace',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPresetButton extends StatelessWidget {
  const _BudgetPresetButton({
    required this.value,
    required this.selected,
    required this.currencySymbol,
    required this.onTap,
  });

  final double? value;
  final bool selected;
  final String currencySymbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCustom = value == null;

    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            isCustom
                ? 'Custom'
                : '$currencySymbol ${value!.toStringAsFixed(0)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? colors.primary : colors.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: colors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Budgets in Mofiney are flexible targets. '
              'We never restrict your cards, lock funds, or decline payments.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetBottomActions extends StatelessWidget {
  const _BudgetBottomActions({required this.onSetBudget, required this.onSkip});

  final VoidCallback onSetBudget;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: onSetBudget,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Set Budget'),
                  SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip for now',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
