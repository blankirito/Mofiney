import 'package:flutter/material.dart';

import '../../accounts/domain/account.dart';

import 'dart:async';

import '../../../core/app_dependencies.dart';

import '../../accounts/presentation/add_account_page.dart';
import '../../accounts/presentation/edit_account_page.dart';

import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';
import '../../../core/database/app_database.dart';

class ProfileAccountsPage extends StatefulWidget {
  const ProfileAccountsPage({super.key});

  @override
  State<ProfileAccountsPage> createState() => _ProfileAccountsPageState();
}

class _ProfileAccountsPageState extends State<ProfileAccountsPage> {
  List<Account> _accounts = [];

  StreamSubscription<List<Account>>? _accountsSubscription;

  AppSettingsEntry? _settings;

  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;

  CurrencyConverter _converter = CurrencyConverter('MYR');

  @override
  void initState() {
    super.initState();

    _watchAccounts();
    _watchSettings();
  }

  void _watchAccounts() {
    _accountsSubscription?.cancel();

    _accountsSubscription = accountRepository.watchAllAccounts().listen(
      (accounts) {
        if (!mounted) {
          return;
        }

        setState(() {
          _accounts = accounts;
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch accounts: $error');
      },
    );
  }

  void _watchSettings() {
    _settingsSubscription?.cancel();

    _settingsSubscription = appSettingsRepository.watchSettings().listen(
      (settings) {
        if (!mounted) {
          return;
        }

        setState(() {
          _settings = settings;
        });

        _refreshConverter();
      },
      onError: (Object error) {
        debugPrint('Failed to watch account display settings: $error');
      },
    );
  }

  Future<void> _refreshConverter() async {
    final converter = CurrencyConverter(_baseCurrency);

    await converter.warm(const ['MYR']);

    if (!mounted) {
      return;
    }

    setState(() {
      _converter = converter;
    });
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    _settingsSubscription?.cancel();

    super.dispose();
  }

  List<Account> get _activeAccounts {
    return _accounts.where((account) => account.isActive).toList();
  }

  List<Account> get _archivedAccounts {
    return _accounts.where((account) => !account.isActive).toList();
  }

  List<Account> _accountsByType(AccountType type) {
    return _activeAccounts.where((account) => account.type == type).toList();
  }

  double _sumBalance(AccountType type) {
    return _accountsByType(type)
        .fold(0, (total, account) => total + account.openingBalance);
  }

  double get _totalAssets {
    return _activeAccounts
        .where((account) => account.type != AccountType.creditCard)
        .fold(0, (total, account) => total + account.openingBalance);
  }

  double get _totalLiabilities {
    return _accountsByType(AccountType.creditCard)
        .fold(0, (total, account) => total + account.openingBalance);
  }

  String get _baseCurrency {
    return _settings?.baseCurrency ?? 'MYR';
  }

  String get _currencySymbol {
    return CurrencyCatalog.find(_baseCurrency).symbol;
  }

  String _money(double amount) {
    final displayAmount = _converter.convert(amount, 'MYR');

    return '$_currencySymbol ${displayAmount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 16),

              _buildPrivacyNotice(context),

              const SizedBox(height: 16),

              _buildSummaryCard(context),

              const SizedBox(height: 24),

              _buildAccountGroup(
                context,
                title: 'BANK ACCOUNTS',
                icon: Icons.account_balance_rounded,
                type: AccountType.bank,
              ),

              const SizedBox(height: 24),

              _buildAccountGroup(
                context,
                title: 'E-WALLETS',
                icon: Icons.contactless_rounded,
                type: AccountType.eWallet,
              ),

              const SizedBox(height: 24),

              _buildAccountGroup(
                context,
                title: 'CASH HOLDINGS',
                icon: Icons.payments_rounded,
                type: AccountType.cash,
              ),

              const SizedBox(height: 24),

              _buildAccountGroup(
                context,
                title: 'CREDIT CARDS / LIABILITIES',
                icon: Icons.credit_card_rounded,
                type: AccountType.creditCard,
              ),

              if (_archivedAccounts.isNotEmpty) ...[
                const SizedBox(height: 24),

                _buildArchivedAccountsSection(context),
              ],

              const SizedBox(height: 24),

              _buildAddAccountButton(context),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Accounts stored locally for manual ledger tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Accounts',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '${_activeAccounts.length} active tracking vaults',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),

        FilledButton.icon(
          onPressed: () {
            _showAddAccountPlaceholder();
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.verified_user_outlined, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZERO API TIES • OFFLINE PRIVACY',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Mofiney uses a manual ledger. '
                  'Your balances reflect the transactions '
                  'you record and no banking credentials are required.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AGGREGATE MONITORED HOLDINGS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$_baseCurrency Display',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _money(_totalAssets),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),

              Text(
                'Liabilities: ${_money(_totalLiabilities)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountGroup(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AccountType type,
  }) {
    final colors = Theme.of(context).colorScheme;
    final accounts = _accountsByType(type);

    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupAmount = _sumBalance(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: type == AccountType.creditCard
                  ? colors.error
                  : colors.primary,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                '$title (${accounts.length})',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),

            Text(
              type == AccountType.creditCard
                  ? '${_money(groupAmount)} Due'
                  : _money(groupAmount),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: type == AccountType.creditCard
                    ? colors.error
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ...accounts.map(
          (account) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAccountCard(context, account),
          ),
        ),
      ],
    );
  }

  Widget _buildArchivedAccountsSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.archive_outlined,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'ARCHIVED ACCOUNTS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${_archivedAccounts.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ..._archivedAccounts.map(
          (account) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _iconForAccount(account.type),
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Archived · ${account.currencyCode}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _restoreAccount(account),
                    child: const Text('Restore'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    if (account.type == AccountType.creditCard) {
      return _buildCreditCard(context, account);
    }

    return _buildStandardAccountCard(context, account);
  }

  Widget _buildStandardAccountCard(BuildContext context, Account account) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconForAccount(account.type), color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),

                    if (account.isPrimary) ...[
                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Current Balance: ${_money(account.openingBalance)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _editAccount(account);
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),

          IconButton(
            onPressed: () {
              _archiveAccount(account);
            },
            icon: const Icon(Icons.archive_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, Account account) {
    final colors = Theme.of(context).colorScheme;

    final double limit = account.creditLimit ?? 0;
    final double outstanding = account.openingBalance;

    final double available = limit > outstanding ? limit - outstanding : 0;

    final usage = limit <= 0 ? 0.0 : (outstanding / limit).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.credit_card_rounded, color: colors.error),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      account.statementCycleDay == null
                          ? 'Credit card'
                          : 'Statement Cycle: ${account.statementCycleDay}th',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  _editAccount(account);
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),

              IconButton(
                onPressed: () {
                  _archiveAccount(account);
                },
                icon: const Icon(Icons.archive_outlined, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usage,
              minHeight: 8,
              backgroundColor: colors.surfaceContainer,
              color: colors.error,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildCreditMetric(
                  context,
                  title: 'Outstanding',
                  value: _money(outstanding),
                  valueColor: colors.error,
                ),
              ),

              Expanded(
                child: _buildCreditMetric(
                  context,
                  title: 'Credit Limit',
                  value: _money(limit),
                ),
              ),

              Expanded(
                child: _buildCreditMetric(
                  context,
                  title: 'Available',
                  value: _money(available),
                  valueColor: colors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditMetric(
    BuildContext context, {
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAddAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _showAddAccountPlaceholder,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('+ Add New Account'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  IconData _iconForAccount(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;

      case AccountType.eWallet:
        return Icons.contactless_rounded;

      case AccountType.cash:
        return Icons.wallet_rounded;

      case AccountType.creditCard:
        return Icons.credit_card_rounded;
    }
  }

  Future<void> _showAddAccountPlaceholder() async {
    final newAccount = await Navigator.of(
      context,
    ).push<Account>(MaterialPageRoute(builder: (_) => const AddAccountPage()));

    if (newAccount == null) {
      return;
    }

    await accountRepository.insertAccount(newAccount);
  }

  Future<void> _editAccount(Account account) async {
    final updatedAccount = await Navigator.of(context).push<Account>(
      MaterialPageRoute(builder: (_) => EditAccountPage(account: account)),
    );

    if (updatedAccount == null) {
      return;
    }

    await accountRepository.updateAccount(updatedAccount);
  }

  Future<void> _restoreAccount(Account account) async {
    final hasActivePrimary = _activeAccounts.any(
      (candidate) => candidate.isPrimary,
    );

    await accountRepository.updateAccount(
      account.copyWith(isActive: true, isPrimary: !hasActivePrimary),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${account.name} restored.')));
  }

  Future<void> _archiveAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive account?'),
          content: Text(
            'Archive ${account.name}? '
            'Its existing ledger transactions will remain intact.',
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
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await accountRepository.updateAccount(account.copyWith(isActive: false));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${account.name} archived.')));
  }
}
