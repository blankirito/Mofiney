import 'package:flutter/material.dart';

import '../domain/account.dart';
import 'account_detail_page.dart';
import '../domain/account_balance_calculator.dart';
import 'add_account_page.dart';

import '../data/account_repository.dart';

import 'dart:async';

import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/database/app_database.dart';
import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({
    super.key,
    required this.repository,
    required this.transactionRepository,
  });

  final AccountRepository repository;
  final TransactionRepository transactionRepository;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<List<Transaction>>? _transactionsSubscription;

  StreamSubscription<List<Account>>? _accountsSubscription;
  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;
  String _baseCurrency = 'MYR';
  CurrencyConverter _converter = CurrencyConverter('MYR');

  @override
  void initState() {
    super.initState();

    _watchAccounts();
    _watchTransactions();
    _settingsSubscription = appSettingsRepository.watchSettings().listen((
      settings,
    ) {
      if (mounted && settings != null) {
        setState(() => _baseCurrency = settings.baseCurrency);
        _refreshRates();
      }
    });
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _settingsSubscription?.cancel();

    super.dispose();
  }

  void _watchTransactions() {
    _transactionsSubscription?.cancel();

    _transactionsSubscription = widget.transactionRepository
        .watchAllTransactions()
        .listen(
          (transactions) {
            if (!mounted) {
              return;
            }

            setState(() {
              _transactions = transactions;
            });
            _refreshRates();
          },
          onError: (Object error) {
            debugPrint('Failed to watch account transactions: $error');
          },
        );
  }

  void _watchAccounts() {
    _accountsSubscription?.cancel();

    _accountsSubscription = widget.repository.watchAllAccounts().listen(
      (accounts) {
        if (!mounted) {
          return;
        }

        setState(() {
          _accounts = accounts;
          _isLoading = false;
          _errorMessage = null;
        });
        _refreshRates();
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      },
    );
  }

  Future<void> _refreshRates() async {
    final base = _baseCurrency;
    final converter = CurrencyConverter(base);
    await converter.warm(const ['MYR']);
    if (mounted && base == _baseCurrency)
      setState(() => _converter = converter);
  }

  double _convert(double value, Account _) => _converter.convert(value, 'MYR');
  String get _symbol => CurrencyCatalog.find(_baseCurrency).symbol;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accounts')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 40),
                const SizedBox(height: 12),
                const Text('Failed to load accounts'),
                const SizedBox(height: 8),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });

                    _watchAccounts();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activeAccounts = _accounts
        .where((account) => account.isActive)
        .toList();

    final assetAccounts = activeAccounts
        .where((account) => account.type != AccountType.creditCard)
        .toList();

    final creditAccounts = activeAccounts
        .where((account) => account.type == AccountType.creditCard)
        .toList();

    final totalAssets = assetAccounts.fold<double>(
      0,
      (sum, account) =>
          sum +
          _convert(
            AccountBalanceCalculator.calculate(account, _transactions),
            account,
          ),
    );

    final totalLiabilities = creditAccounts.fold<double>(
      0,
      (sum, account) =>
          sum +
          _convert(
            AccountBalanceCalculator.calculate(account, _transactions),
            account,
          ),
    );

    final netWorth = totalAssets - totalLiabilities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            onPressed: () async {
              final newAccount = await Navigator.of(context).push<Account>(
                MaterialPageRoute(builder: (_) => const AddAccountPage()),
              );

              if (newAccount == null) {
                return;
              }

              await widget.repository.insertAccount(newAccount);
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildOverviewCard(
              context,
              totalAssets: totalAssets,
              totalLiabilities: totalLiabilities,
              netWorth: netWorth,
            ),

            const SizedBox(height: 20),

            _buildSectionHeader(
              context,
              title: 'ASSETS',
              count: assetAccounts.length,
            ),

            const SizedBox(height: 10),

            ...assetAccounts.map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAccountCard(context, account: account),
              ),
            ),

            if (creditAccounts.isNotEmpty) ...[
              const SizedBox(height: 12),

              _buildSectionHeader(
                context,
                title: 'CREDIT & LIABILITIES',
                count: creditAccounts.length,
              ),

              const SizedBox(height: 10),

              ...creditAccounts.map(
                (account) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCreditAccountCard(context, account: account),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required double totalAssets,
    required double totalLiabilities,
    required double netWorth,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NET POSITION',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '$_symbol ${netWorth.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  label: 'TOTAL ASSETS',
                  value: '$_symbol ${totalAssets.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                  positive: true,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildMetric(
                  context,
                  label: 'LIABILITIES',
                  value: '$_symbol ${totalLiabilities.toStringAsFixed(2)}',
                  icon: Icons.credit_card_rounded,
                  positive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool positive,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: positive ? colors.tertiary : colors.error,
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context, {required Account account}) {
    final colors = Theme.of(context).colorScheme;

    final currentBalance = AccountBalanceCalculator.calculate(
      account,
      _transactions,
    );

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () async {
          final updatedAccount = await Navigator.of(context).push<Account>(
            MaterialPageRoute(
              builder: (_) => AccountDetailPage(
                account: account,
                transactionRepository: widget.transactionRepository,
              ),
            ),
          );

          if (updatedAccount == null) {
            return;
          }

          await widget.repository.updateAccount(updatedAccount);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAccountIcon(context, account.type),

              const SizedBox(width: 14),

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
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${_accountTypeLabel(account.type)} · Native ${account.currencyCode}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_symbol ${_convert(currentBalance, account).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditAccountCard(
    BuildContext context, {
    required Account account,
  }) {
    final colors = Theme.of(context).colorScheme;

    final currentBalance = AccountBalanceCalculator.calculate(
      account,
      _transactions,
    );

    final creditLimit = account.creditLimit ?? 0;

    final usage = creditLimit <= 0
        ? 0.0
        : (currentBalance / creditLimit).clamp(0.0, 1.0);

    final availableCredit = (creditLimit - currentBalance).clamp(
      0.0,
      double.infinity,
    );

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () async {
          final updatedAccount = await Navigator.of(context).push<Account>(
            MaterialPageRoute(
              builder: (_) => AccountDetailPage(
                account: account,
                transactionRepository: widget.transactionRepository,
              ),
            ),
          );

          if (updatedAccount == null) {
            return;
          }

          await widget.repository.updateAccount(updatedAccount);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAccountIcon(context, account.type),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Credit Card',
                          style: TextStyle(
                            fontSize: 11,
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
                        '$_symbol ${_convert(currentBalance, account).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.error,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Outstanding · Native ${account.currencyCode}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: usage,
                  minHeight: 7,
                  backgroundColor: colors.surfaceContainerHigh,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    '${(usage * 100).toStringAsFixed(1)}% used',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Available $_symbol ${_convert(availableCredit, account).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              if (account.statementCycleDay != null) ...[
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Statement cycle · Day ${account.statementCycleDay}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountIcon(BuildContext context, AccountType type) {
    final colors = Theme.of(context).colorScheme;

    final IconData icon;

    switch (type) {
      case AccountType.bank:
        icon = Icons.account_balance_rounded;
        break;

      case AccountType.eWallet:
        icon = Icons.account_balance_wallet_rounded;
        break;

      case AccountType.cash:
        icon = Icons.payments_rounded;
        break;

      case AccountType.creditCard:
        icon = Icons.credit_card_rounded;
        break;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 22, color: colors.primary),
    );
  }

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';

      case AccountType.eWallet:
        return 'E-Wallet';

      case AccountType.cash:
        return 'Cash Wallet';

      case AccountType.creditCard:
        return 'Credit Card';
    }
  }
}
