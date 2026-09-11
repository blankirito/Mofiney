import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'setup_complete_page.dart';
import 'widgets/onboarding_stepper.dart';
import 'widgets/onboarding_header.dart';
import '../domain/onboarding_data.dart';

class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key, required this.data});

  final OnboardingData data;

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  AccountType selectedType = AccountType.bank;

  final accountNameController = TextEditingController();

  final balanceController = TextEditingController(text: '0.00');

  @override
  void dispose() {
    accountNameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

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

                    const OnboardingStepper(currentStep: 3),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'STEP 3 OF 4',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Add your first account',
                      style: AppTextStyles.headlineLargeMobile.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Create a baseline account to track your daily cash '
                      'flow and balances. Mofiney is manual and never '
                      'connects to banking APIs.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'ACCOUNT TYPE',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: AccountType.values.map((type) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: type != AccountType.values.last ? 8 : 0,
                            ),
                            child: _AccountTypeCard(
                              type: type,
                              selected: selectedType == type,
                              onTap: () {
                                setState(() {
                                  selectedType = type;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'ACCOUNT NAME',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    TextField(
                      controller: accountNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Maybank, Cash Wallet',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'OPENING BALANCE',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixText: 'RM ',
                        hintText: '0.00',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Starting baseline for your income and expense tracking.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              size: 17,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Privacy First: ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Mofiney never connects to banking '
                                        'APIs or requests credentials. Your '
                                        'records stay private on your device.',
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

            _AccountBottomActions(onContinue: _continue, onSkip: _skip),
          ],
        ),
      ),
    );
  }

  void _continue() {
    final accountName = accountNameController.text.trim();
    final openingBalance = double.tryParse(
      balanceController.text.replaceAll(',', ''),
    );

    if (accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name.')),
      );
      return;
    }

    if (openingBalance == null || openingBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid opening balance.')),
      );
      return;
    }

    final updatedData = widget.data.copyWith(
      accountName: accountName,
      accountType: selectedType.label,
      openingBalance: openingBalance,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SetupCompletePage(data: updatedData)),
    );
  }

  void _skip() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SetupCompletePage(data: widget.data)),
    );
  }
}

enum AccountType { bank, cash, eWallet }

extension AccountTypeDetails on AccountType {
  String get label {
    switch (this) {
      case AccountType.bank:
        return 'Bank';
      case AccountType.cash:
        return 'Cash';
      case AccountType.eWallet:
        return 'E-Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.eWallet:
        return Icons.phone_android_outlined;
    }
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                size: 21,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountBottomActions extends StatelessWidget {
  const _AccountBottomActions({required this.onContinue, required this.onSkip});

  final VoidCallback onContinue;
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
              onPressed: onContinue,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create Account & Continue'),
                  SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip for Now',
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
