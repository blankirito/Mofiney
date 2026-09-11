import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'widgets/onboarding_stepper.dart';
import 'widgets/onboarding_header.dart';
import '../domain/onboarding_data.dart';
import '../../../core/navigation/main_shell.dart';

import '../../../core/app_dependencies.dart';
import '../data/onboarding_preferences.dart';
import '../data/onboarding_setup_service.dart';

class SetupCompletePage extends StatefulWidget {
  const SetupCompletePage({super.key, required this.data});

  final OnboardingData data;

  @override
  State<SetupCompletePage> createState() => _SetupCompletePageState();
}

class _SetupCompletePageState extends State<SetupCompletePage> {
  bool _isCompleting = false;

  OnboardingData get data => widget.data;

  Future<void> _finishSetup() async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final setupService = OnboardingSetupService(
        appSettingsRepository: appSettingsRepository,
        accountRepository: accountRepository,
        onboardingPreferences: OnboardingPreferences(),
      );

      await setupService.complete(data);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete setup. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final dailyTarget = data.monthlyBudget != null
        ? data.monthlyBudget! / 30
        : null;

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
                  children: [
                    const OnboardingHeader(),

                    const SizedBox(height: AppSpacing.lg),

                    const OnboardingStepper(currentStep: 4),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'STEP 4 OF 4',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: colors.onPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      "You're ready to start tracking",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLargeMobile.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Your financial baseline is set. '
                      'Here is a summary of your configuration:',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _SummaryCard(data: data, dailyTarget: dailyTarget),

                    const SizedBox(height: AppSpacing.md),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "What's next: ",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Record daily expenses manually, '
                                        'scan receipts with OCR, or log '
                                        'income anytime from the Home dashboard.',
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
                    ),
                  ],
                ),
              ),
            ),

            _BottomAction(
              onPressed: _isCompleting ? null : _finishSetup,
              isLoading: _isCompleting,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.dailyTarget});

  final OnboardingData data;
  final double? dailyTarget;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.currency_exchange_rounded,
            iconText: data.currencySymbol,
            title: 'DISPLAY CURRENCY',
            value: '${data.currencyName} (${data.currencyCode})',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'Active',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Divider(height: AppSpacing.xl, color: colors.outlineVariant),

          _SummaryRow(
            icon: Icons.bar_chart_rounded,
            title: 'MONTHLY SPENDING TARGET',
            value: data.monthlyBudget == null
                ? 'Not set'
                : 'RM ${data.monthlyBudget!.toStringAsFixed(2)} / mo',
            subtitle: dailyTarget == null
                ? 'You can add a budget anytime'
                : 'RM ${dailyTarget!.toStringAsFixed(2)} daily pace',
          ),

          Divider(height: AppSpacing.xl, color: colors.outlineVariant),

          _SummaryRow(
            icon: Icons.account_balance_outlined,
            title: 'STARTING ACCOUNT',
            value: data.accountName ?? 'No account added',
            subtitle: data.openingBalance == null
                ? 'You can create an account later'
                : 'RM ${data.openingBalance!.toStringAsFixed(2)} initial balance',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
    this.iconText,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;

  final String? iconText;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: iconText != null
              ? Text(
                  iconText!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(icon, color: colors.onPrimaryContainer, size: 20),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (trailing != null) ?trailing,
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

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
              onPressed: onPressed,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Go to Dashboard'),
                        SizedBox(width: AppSpacing.xs),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Encrypted local device storage • '
                    'Zero banking credentials needed',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
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
