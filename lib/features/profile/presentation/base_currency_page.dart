import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class _CurrencyOption {
  const _CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.category,
  });

  final String code;
  final String name;
  final String symbol;
  final String category;
}

class BaseCurrencyPage extends StatefulWidget {
  const BaseCurrencyPage({super.key});

  @override
  State<BaseCurrencyPage> createState() =>
      _BaseCurrencyPageState();
}

class _BaseCurrencyPageState
    extends State<BaseCurrencyPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'all';
  String _searchQuery = '';

  String _currentCurrencyCode = 'MYR';
  String _selectedCurrencyCode = 'MYR';

  final List<_CurrencyOption> _currencies = const [
    _CurrencyOption(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      category: 'regional',
    ),
    _CurrencyOption(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      category: 'regional',
    ),
    _CurrencyOption(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      category: 'regional',
    ),
    _CurrencyOption(
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      category: 'major',
    ),
    _CurrencyOption(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      category: 'major',
    ),
    _CurrencyOption(
      code: 'GBP',
      name: 'British Pound Sterling',
      symbol: '£',
      category: 'major',
    ),
    _CurrencyOption(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      category: 'major',
    ),
    _CurrencyOption(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      category: 'major',
    ),
    _CurrencyOption(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      category: 'major',
    ),
  ];

  _CurrencyOption get _currentCurrency {
    return _currencies.firstWhere(
      (currency) =>
          currency.code == _currentCurrencyCode,
    );
  }

  _CurrencyOption get _selectedCurrency {
    return _currencies.firstWhere(
      (currency) =>
          currency.code == _selectedCurrencyCode,
    );
  }

  bool get _hasChanges =>
      _selectedCurrencyCode != _currentCurrencyCode;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentCurrency = _currentCurrency;

    final filteredCurrencies =
        _currencies.where((currency) {
      final matchesFilter =
          _selectedFilter == 'all' ||
          currency.category == _selectedFilter;

      final matchesSearch =
          _searchQuery.isEmpty ||
          currency.code
              .toLowerCase()
              .contains(_searchQuery) ||
          currency.name
              .toLowerCase()
              .contains(_searchQuery);

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Base Currency'),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =====================================================
              // ACTIVE BASE CURRENCY
              // =====================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color:
                      colors.surfaceContainerLowest,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.xl,
                  ),
                  border: Border.all(
                    color: colors.outlineVariant
                        .withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'ACTIVE STANDARD',
                                style: AppTextStyles
                                    .labelCaps
                                    .copyWith(
                                  color:
                                      colors.primary,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                currentCurrency.name,
                                style: AppTextStyles
                                    .headlineMedium
                                    .copyWith(
                                  color: colors
                                      .onSurface,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: colors
                                .primaryContainer,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              AppRadius.full,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .verified_rounded,
                                size: 15,
                                color: colors
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Active Base',
                                style: AppTextStyles
                                    .bodySmall
                                    .copyWith(
                                  color: colors
                                      .onPrimaryContainer,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          currentCurrency.code,
                          style: AppTextStyles
                              .amountLarge
                              .copyWith(
                            color:
                                colors.onSurface,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 3,
                            ),
                            child: Text(
                              '${currentCurrency.symbol} · Base denomination',
                              style: AppTextStyles
                                  .bodySmall
                                  .copyWith(
                                color: colors
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Text(
                      'Your dashboard totals, budgets, and financial summaries are consolidated using this currency.',
                      style: AppTextStyles.bodySmall
                          .copyWith(
                        color:
                            colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.sm,
                      ),
                      decoration:
                          BoxDecoration(
                        color: colors
                            .surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.md,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Icon(
                            Icons
                                .info_outline_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(
                            width: AppSpacing.xs,
                          ),
                          Expanded(
                            child: Text(
                              'Multi-currency records remain stored in their original currency.',
                              style: AppTextStyles
                                  .bodySmall
                                  .copyWith(
                                color: colors
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // SEARCH
              // =====================================================
              const SizedBox(
                height: AppSpacing.lg,
              ),

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search currency or ISO code...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  suffixIcon:
                      _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController
                                    .clear();

                                setState(() {
                                  _searchQuery =
                                      '';
                                });
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                              ),
                            ),
                  filled: true,
                  fillColor:
                      colors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.xl,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.xl,
                    ),
                    borderSide: BorderSide(
                      color: colors
                          .outlineVariant
                          .withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.xl,
                    ),
                    borderSide: BorderSide(
                      color: colors.primary,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value
                        .trim()
                        .toLowerCase();
                  });
                },
              ),

              // =====================================================
              // FILTER
              // =====================================================
              const SizedBox(
                height: AppSpacing.sm,
              ),

              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: Row(
                  children: [
                    _CurrencyFilterChip(
                      label: 'All Supported',
                      selected:
                          _selectedFilter ==
                              'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                              'all';

                          _selectedCurrencyCode =
                              _currentCurrencyCode;
                        });
                      },
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    _CurrencyFilterChip(
                      label:
                          'ASEAN & Regional',
                      selected:
                          _selectedFilter ==
                              'regional',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                              'regional';

                          _selectedCurrencyCode =
                              _currentCurrencyCode;
                        });
                      },
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    _CurrencyFilterChip(
                      label:
                          'Global Reserves',
                      selected:
                          _selectedFilter ==
                              'major',
                      onTap: () {
                        setState(() {
                          _selectedFilter =
                              'major';

                          _selectedCurrencyCode =
                              _currentCurrencyCode;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // =====================================================
              // LIST
              // =====================================================
              const SizedBox(
                height: AppSpacing.lg,
              ),

              Text(
                'AVAILABLE CURRENCIES',
                style: AppTextStyles.labelCaps
                    .copyWith(
                  color:
                      colors.onSurfaceVariant,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              if (filteredCurrencies.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    AppSpacing.lg,
                  ),
                  decoration:
                      BoxDecoration(
                    color: colors
                        .surfaceContainerLowest,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.xl,
                    ),
                    border: Border.all(
                      color: colors
                          .outlineVariant
                          .withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 28,
                        color: colors
                            .onSurfaceVariant,
                      ),
                      const SizedBox(
                        height: AppSpacing.xs,
                      ),
                      Text(
                        'No currency matches found',
                        style: AppTextStyles
                            .bodyMedium
                            .copyWith(
                          color:
                              colors.onSurface,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Try another currency name or ISO code.',
                        textAlign:
                            TextAlign.center,
                        style: AppTextStyles
                            .bodySmall
                            .copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredCurrencies.map(
                  (currency) => Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom:
                          AppSpacing.sm,
                    ),
                    child: _CurrencyCard(
                      currency: currency,
                      isCurrent:
                          currency.code ==
                              _currentCurrencyCode,
                      isSelected:
                          currency.code ==
                              _selectedCurrencyCode,
                      onTap: () {
                        setState(() {
                          _selectedCurrencyCode =
                              currency.code;
                        });
                      },
                    ),
                  ),
                ),

              // =====================================================
              // SAVE / DISCARD
              // =====================================================
              const SizedBox(
                height: AppSpacing.md,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color:
                      colors.surfaceContainerLowest,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.xl,
                  ),
                  border: Border.all(
                    color: colors
                        .outlineVariant
                        .withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasChanges
                          ? 'Change base currency to ${_selectedCurrency.code}?'
                          : '${_currentCurrency.code} is your current base currency.',
                      style: AppTextStyles
                          .bodyMedium
                          .copyWith(
                        color:
                            colors.onSurface,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _hasChanges
                          ? 'Existing records will remain stored in their original currency.'
                          : 'Select another currency above to make a change.',
                      style: AppTextStyles
                          .bodySmall
                          .copyWith(
                        color: colors
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed:
                                _hasChanges
                                    ? () {
                                        setState(
                                          () {
                                            _selectedCurrencyCode =
                                                _currentCurrencyCode;
                                          },
                                        );
                                      }
                                    : null,
                            child:
                                const Text(
                              'Cancel Changes',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        Expanded(
                          child:
                              FilledButton(
                            onPressed:
                                _hasChanges
                                    ? () {
                                        setState(
                                          () {
                                            _currentCurrencyCode =
                                                _selectedCurrencyCode;

                                            _selectedCurrencyCode =
                                                _currentCurrencyCode;
                                          },
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(
                                              'Base currency changed to ${_currentCurrency.code}.',
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                            child:
                                const Text(
                              'Save Changes',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyFilterChip
    extends StatelessWidget {
  const _CurrencyFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppRadius.full,
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : colors
                  .surfaceContainerLowest,
          borderRadius:
              BorderRadius.circular(
            AppRadius.full,
          ),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant
                    .withValues(
                    alpha: 0.4,
                  ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall
              .copyWith(
            color: selected
                ? colors.onPrimary
                : colors
                    .onSurfaceVariant,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CurrencyCard
    extends StatelessWidget {
  const _CurrencyCard({
    required this.currency,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  final _CurrencyOption currency;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        AppRadius.xl,
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer
                  .withValues(
                  alpha: 0.25,
                )
              : colors
                  .surfaceContainerLowest,
          borderRadius:
              BorderRadius.circular(
            AppRadius.xl,
          ),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant
                    .withValues(
                    alpha: 0.4,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors
                        .primaryContainer
                    : colors
                        .surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              alignment:
                  Alignment.center,
              child: Text(
                currency.symbol,
                style: AppTextStyles
                    .amountSmall
                    .copyWith(
                  color: isSelected
                      ? colors
                          .onPrimaryContainer
                      : colors.onSurface,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(
              width: AppSpacing.sm,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Text(
                        currency.code,
                        style:
                            AppTextStyles
                                .bodyMedium
                                .copyWith(
                          color: colors
                              .onSurface,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(
                          width:
                              AppSpacing
                                  .xs,
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration:
                              BoxDecoration(
                            color: colors
                                .primaryContainer,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              AppRadius.full,
                            ),
                          ),
                          child: Text(
                            'Current',
                            style:
                                AppTextStyles
                                    .labelCaps
                                    .copyWith(
                              color: colors
                                  .onPrimaryContainer,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    currency.name,
                    style:
                        AppTextStyles
                            .bodySmall
                            .copyWith(
                      color: colors
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons
                      .radio_button_checked_rounded
                  : Icons
                      .radio_button_unchecked_rounded,
              color: isSelected
                  ? colors.primary
                  : colors
                      .onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}