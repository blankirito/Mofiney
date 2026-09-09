import 'package:flutter/material.dart';

import '../data/mock_accounts.dart';
import '../domain/account.dart';
import 'account_detail_page.dart';
import '../../transactions/data/mock_transactions.dart';
import '../domain/account_balance_calculator.dart';
import 'add_account_page.dart';


class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activeAccounts =
        mockAccounts.where((account) => account.isActive).toList();

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
          AccountBalanceCalculator.calculate(
            account,
            mockTransactions,
          ),
    );

    final totalLiabilities = creditAccounts.fold<double>(
      0,
      (sum, account) =>
          sum +
          AccountBalanceCalculator.calculate(
            account,
            mockTransactions,
          ),
    );

    final netWorth = totalAssets - totalLiabilities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddAccountPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),
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
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: _buildAccountCard(
                  context,
                  account: account,
                ),
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
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _buildCreditAccountCard(
                    context,
                    account: account,
                  ),
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
            'RM ${netWorth.toStringAsFixed(2)}',
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
                  value:
                      'RM ${totalAssets.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                  positive: true,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildMetric(
                  context,
                  label: 'LIABILITIES',
                  value:
                      'RM ${totalLiabilities.toStringAsFixed(2)}',
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
            color: positive
                ? colors.tertiary
                : colors.error,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
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

  Widget _buildAccountCard(
    BuildContext context, {
    required Account account,
  }) {
    final colors = Theme.of(context).colorScheme;

    final currentBalance = AccountBalanceCalculator.calculate(
      account,
      mockTransactions,
    );

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AccountDetailPage(
                account: account,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAccountIcon(
                context,
                account.type,
              ),

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
                              borderRadius:
                                  BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color:
                                    colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _accountTypeLabel(account.type),
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
                    'RM ${currentBalance.toStringAsFixed(2)}',
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
    mockTransactions,
  );

  final creditLimit = account.creditLimit ?? 0;

  final usage = creditLimit <= 0
    ? 0.0
    : (currentBalance / creditLimit)
        .clamp(0.0, 1.0);

  final availableCredit =
      (creditLimit - currentBalance)
          .clamp(0.0, double.infinity);

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AccountDetailPage(
                account: account,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAccountIcon(
                    context,
                    account.type,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
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
                            color:
                                colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        'RM ${currentBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.error,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Outstanding',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              colors.onSurfaceVariant,
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
                  backgroundColor:
                      colors.surfaceContainerHigh,
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
                    'Available RM ${availableCredit.toStringAsFixed(2)}',
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

  Widget _buildAccountIcon(
    BuildContext context,
    AccountType type,
  ) {
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
      child: Icon(
        icon,
        size: 22,
        color: colors.primary,
      ),
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