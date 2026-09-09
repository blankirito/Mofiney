import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'budget_page.dart';
import 'widgets/onboarding_stepper.dart';
import 'widgets/onboarding_header.dart';
import '../domain/onboarding_data.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  String selectedCurrency = 'MYR';
  String searchQuery = '';

  final List<CurrencyOption> currencies = const [
    CurrencyOption(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      subtitle: 'Malaysian Ringgit (RM)',
    ),
    CurrencyOption(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      subtitle: 'Singapore Dollar',
    ),
    CurrencyOption(
      code: 'USD',
      symbol: '\$',
      name: 'United States Dollar',
      subtitle: 'United States Dollar',
    ),
    CurrencyOption(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      subtitle: 'Euro',
    ),
    CurrencyOption(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      subtitle: 'Indonesian Rupiah',
    ),
    CurrencyOption(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound Sterling',
      subtitle: 'British Pound Sterling',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredCurrencies = currencies.where((currency) {
      final query = searchQuery.toLowerCase();

      return currency.code.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query);
    }).toList();

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
                    const OnboardingStepper(currentStep: 1),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'STEP 1 OF 4',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Choose your currency',
                      style: AppTextStyles.headlineLargeMobile.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Select the primary ledger currency for your balances '
                      'and daily tracking.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search currency or country...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ...filteredCurrencies.map(
                      (currency) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CurrencyCard(
                          currency: currency,
                          selected: selectedCurrency == currency.code,
                          isDefault: currency.code == 'MYR',
                          onTap: () {
                            setState(() {
                              selectedCurrency = currency.code;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _BottomAction(
              label: 'Continue with $selectedCurrency',
              onPressed: () {
                final selectedOption = currencies.firstWhere(
                  (currency) => currency.code == selectedCurrency,
                );

                final data = OnboardingData(
                  currencyCode: selectedOption.code,
                  currencySymbol: selectedOption.symbol,
                  currencyName: selectedOption.name,
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BudgetPage(data: data),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
    required this.subtitle,
  });

  final String code;
  final String symbol;
  final String name;
  final String subtitle;
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.currency,
    required this.selected,
    required this.isDefault,
    required this.onTap,
  });

  final CurrencyOption currency;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  currency.symbol,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currency.code,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'Default',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outline,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: FilledButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}