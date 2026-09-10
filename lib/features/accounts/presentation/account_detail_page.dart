import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_formatter.dart';

import '../domain/account.dart';

import '../../transactions/data/mock_transactions.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/account_balance_calculator.dart';
import '../domain/account_monthly_cash_flow.dart';
import '../domain/account_balance_history.dart';
import 'edit_account_page.dart';
import '../../transactions/presentation/transaction_detail_page.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({
    super.key,
    required this.account,
  });

  final Account account;

 @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final accountTransactions = mockTransactions.where((transaction) {
      return transaction.accountId == account.id ||
          transaction.destinationAccountId == account.id;
    }).toList()
      ..sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      );

    final currentBalance = AccountBalanceCalculator.calculate(
      account,
      mockTransactions,
    );

    final monthlyCashFlow = AccountMonthlyCashFlow.calculate(
      accountId: account.id,
      transactions: mockTransactions,
      month: DateTime(2026, 9),
    );

    final balanceHistory = AccountBalanceHistory.calculate(
      account: account,
      transactions: mockTransactions,
    );

    return Scaffold(
      body: SafeArea(
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
              _buildTopBar(context),

              const SizedBox(height: AppSpacing.sm),

              _buildAccountContext(context),

              const SizedBox(height: AppSpacing.md),

              _AccountHeroCard(
                account: account,
                currentBalance: currentBalance,
                latestTransaction: accountTransactions.isEmpty
                    ? null
                    : accountTransactions.first,
              ),

              const SizedBox(height: AppSpacing.md),

              _BalanceTrendCard(
                history: balanceHistory,
              ),

              const SizedBox(height: AppSpacing.md),

              _MonthlyCashFlowCard(
                cashFlow: monthlyCashFlow,
              ),

              const SizedBox(height: AppSpacing.md),

              _AccountInformationCard(
                account: account,
                currentBalance: currentBalance,
              ),

              const SizedBox(height: AppSpacing.md),

              _RecentActivityCard(
                account: account,
                transactions: accountTransactions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: Text(
            'Account Details',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: colors.onSurfaceVariant,
          ),
        ),

        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountContext(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: AppSpacing.xs),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT DETAILS',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 2),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      'Manual Account • ${_accountTypeLabel(account.type)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditAccountPage(
                  account: account,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
          ),
          label: const Text('Edit'),
        ),
      ],
    );
  }

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';

      case AccountType.eWallet:
        return 'E-Wallet';

      case AccountType.cash:
        return 'Cash';

      case AccountType.creditCard:
        return 'Credit Card';
    }
  }
}

class _MonthlyCashFlowCard extends StatelessWidget {
  const _MonthlyCashFlowCard({
    required this.cashFlow,
  });

  final AccountMonthlyCashFlow cashFlow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final netFlow = cashFlow.netCashFlow;
    final isPositive = netFlow >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'MONTHLY CASH FLOW',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'SEP 2026',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _CashFlowMetric(
                  label: 'INCOME',
                  amount: cashFlow.income,
                  icon: Icons.south_west_rounded,
                  color: colors.tertiary,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Expanded(
                child: _CashFlowMetric(
                  label: 'EXPENSES',
                  amount: cashFlow.expenses,
                  icon: Icons.north_east_rounded,
                  color: colors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

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
              children: [
                Expanded(
                  child: Text(
                    'Net Flow',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${isPositive ? '+' : '-'}${MoneyFormatter.format(
                    amount: netFlow.abs(),
                    symbol: 'RM',
                  )}',
                  style: AppTextStyles.amountMedium.copyWith(
                    color: isPositive
                        ? colors.tertiary
                        : colors.error,
                    fontWeight: FontWeight.w700,
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

class _CashFlowMetric extends StatelessWidget {
  const _CashFlowMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            MoneyFormatter.format(
              amount: amount,
              symbol: 'RM',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.amountMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({
    required this.account,
    required this.currentBalance,
    required this.latestTransaction,
  });

  final Account account;
  final double currentBalance;
  final Transaction? latestTransaction;

  String _formatLastEntry(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  _accountIcon(account.type),
                  size: 26,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'Offline Ledger',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (account.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'MYR • PRIMARY',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            account.type == AccountType.creditCard
                ? 'Current Outstanding'
                : 'Current Tracked Balance',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            MoneyFormatter.format(
              amount: currentBalance,
              symbol: 'RM',
            ),
            style: AppTextStyles.amountLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 17,
                  color: colors.tertiary,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    'Last entry recorded',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

                Text(
                  latestTransaction == null
                    ? 'No activity yet'
                    : _formatLastEntry(
                        latestTransaction!.dateTime,
                      ),
                style: AppTextStyles.amountSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _accountIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;

      case AccountType.eWallet:
        return Icons.account_balance_wallet_rounded;

      case AccountType.cash:
        return Icons.payments_outlined;

      case AccountType.creditCard:
        return Icons.credit_card_rounded;
    }
  }
}

class _AccountInformationCard extends StatelessWidget {
  const _AccountInformationCard({
    required this.account,
    required this.currentBalance,
  });

  final Account account;
  final double currentBalance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isCreditCard =
        account.type == AccountType.creditCard;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCreditCard
                ? 'CREDIT OVERVIEW'
                : 'ACCOUNT INFORMATION',
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          if (isCreditCard)
            _buildCreditCardInformation(context)
          else
            _buildStandardAccountInformation(context),
        ],
      ),
    );
  }

  Widget _buildStandardAccountInformation(
    BuildContext context,
  ) {
    return Column(
      children: [
        _InformationRow(
          label: 'Opening Balance',
          value: MoneyFormatter.format(
            amount: account.openingBalance,
            symbol: 'RM',
          ),
        ),

        const _InformationDivider(),

        _InformationRow(
          label: 'Account Type',
          value: _accountTypeLabel(account.type),
        ),

        const _InformationDivider(),

        const _InformationRow(
          label: 'Currency',
          value: 'MYR',
        ),

        const _InformationDivider(),

        _InformationRow(
          label: 'Status',
          value: account.isActive ? 'Active' : 'Archived',
        ),
      ],
    );
  }

  Widget _buildCreditCardInformation(
    BuildContext context,
  ) {
    final creditLimit = account.creditLimit ?? 0;

    final availableCredit =
      (creditLimit - currentBalance)
          .clamp(0.0, double.infinity);

    final utilization = creditLimit <= 0
      ? 0.0
      : (currentBalance / creditLimit)
          .clamp(0.0, 1.0);

    return Column(
      children: [
        _InformationRow(
          label: 'Outstanding',
          value: MoneyFormatter.format(
            amount: currentBalance,
            symbol: 'RM',
          ),
        ),

        const _InformationDivider(),

        _InformationRow(
          label: 'Credit Limit',
          value: MoneyFormatter.format(
            amount: creditLimit,
            symbol: 'RM',
          ),
        ),

        const _InformationDivider(),

        _InformationRow(
          label: 'Available Credit',
          value: MoneyFormatter.format(
            amount: availableCredit,
            symbol: 'RM',
          ),
        ),

        const _InformationDivider(),

        _InformationRow(
          label: 'Utilization',
          value:
              '${(utilization * 100).toStringAsFixed(1)}%',
        ),

        if (account.statementCycleDay != null) ...[
          const _InformationDivider(),

          _InformationRow(
            label: 'Statement Cycle',
            value: 'Day ${account.statementCycleDay}',
          ),
        ],
      ],
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

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationDivider extends StatelessWidget {
  const _InformationDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Divider(
        height: 1,
        color: colors.outlineVariant.withValues(
          alpha: 0.45,
        ),
      ),
    );
  }
}

enum _TransactionFilter {
  all,
  expenses,
  income,
  transfers,
}

class _RecentActivityCard extends StatefulWidget {
  const _RecentActivityCard({
    required this.account,
    required this.transactions,
  });

  final Account account;
  final List<Transaction> transactions;

  @override
  State<_RecentActivityCard> createState() =>
      _RecentActivityCardState();
}

class _RecentActivityCardState
    extends State<_RecentActivityCard> {
  _TransactionFilter _selectedFilter =
      _TransactionFilter.all;

  String _emptyMessage() {
    switch (_selectedFilter) {
      case _TransactionFilter.all:
        return 'No activity recorded yet.';

      case _TransactionFilter.expenses:
        return 'No expense transactions.';

      case _TransactionFilter.income:
        return 'No income transactions.';

      case _TransactionFilter.transfers:
        return 'No transfer transactions.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final sortedTransactions =
      List<Transaction>.from(widget.transactions)
        ..sort(
          (a, b) => b.dateTime.compareTo(a.dateTime),
        );

    final filteredTransactions =
        sortedTransactions.where((transaction) {
      switch (_selectedFilter) {
        case _TransactionFilter.all:
          return true;

        case _TransactionFilter.expenses:
          return transaction.type ==
              TransactionType.expense;

        case _TransactionFilter.income:
          return transaction.type ==
              TransactionType.income;

        case _TransactionFilter.transfers:
          return transaction.type ==
              TransactionType.transfer;
      }
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.account.name} Transactions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${sortedTransactions.length}',
                        style: AppTextStyles.amountSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export coming next'),
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TransactionFilterChip(
                  label: 'All',
                  selected:
                      _selectedFilter == _TransactionFilter.all,
                  onTap: () {
                    setState(() {
                      _selectedFilter = _TransactionFilter.all;
                    });
                  },
                ),

                const SizedBox(width: AppSpacing.xs),

                _TransactionFilterChip(
                  label: 'Expenses',
                  selected:
                      _selectedFilter == _TransactionFilter.expenses,
                  onTap: () {
                    setState(() {
                      _selectedFilter =
                          _TransactionFilter.expenses;
                    });
                  },
                ),

                const SizedBox(width: AppSpacing.xs),

                _TransactionFilterChip(
                  label: 'Income',
                  selected:
                      _selectedFilter == _TransactionFilter.income,
                  onTap: () {
                    setState(() {
                      _selectedFilter = _TransactionFilter.income;
                    });
                  },
                ),

                const SizedBox(width: AppSpacing.xs),

                _TransactionFilterChip(
                  label: 'Transfers',
                  selected:
                      _selectedFilter == _TransactionFilter.transfers,
                  onTap: () {
                    setState(() {
                      _selectedFilter =
                          _TransactionFilter.transfers;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          if (filteredTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              child: Text(
                _emptyMessage(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            ...filteredTransactions.map(
              (transaction) => _RecentActivityRow(
                account: widget.account,
                transaction: transaction,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(
                alpha: 0.45,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual account',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Balance is calculated from your opening balance and recorded transactions.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
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

class _TransactionFilterChip extends StatelessWidget {
  const _TransactionFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primaryContainer
          : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(
        AppRadius.full,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({
    required this.account,
    required this.transaction,
  });

  final Account account;
  final Transaction transaction;

  String? _secondaryInfo() {
    if (transaction.type == TransactionType.transfer) {
      final isIncoming =
          transaction.destinationAccountId == account.id;

      if (isIncoming) {
        return 'From ${transaction.account}';
      }

      if (transaction.destinationAccount != null) {
        return 'To ${transaction.destinationAccount}';
      }

      return null;
    }

    return transaction.paymentMethod;
  }

  String _displayTitle() {
    if (transaction.type != TransactionType.transfer) {
      return transaction.title;
    }

    final isIncoming =
        transaction.destinationAccountId == account.id;

    if (isIncoming) {
      return 'Transfer from ${transaction.account}';
    }

    return 'Transfer to ${transaction.destinationAccount ?? 'Account'}';
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, '
        '$hour:$minute $period';
  }

  String _displaySubtitle() {
    return '${transaction.category} • '
        '${_formatDateTime(transaction.dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final secondaryInfo = _secondaryInfo();

    final isIncomingTransfer =
        transaction.type == TransactionType.transfer &&
        transaction.destinationAccountId == account.id;

    final isIncome =
        transaction.type == TransactionType.income;

    final isPositive =
        isIncomingTransfer || isIncome;

    final sign = isPositive ? '+' : '-';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transaction: transaction,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 10,
        ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: Icon(
              _transactionIcon(transaction.type),
              size: 20,
              color: isPositive
                  ? colors.tertiary
                  : colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _displaySubtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${MoneyFormatter.format(
                  amount: transaction.amount.abs(),
                  symbol: 'RM',
                )}',
                style: AppTextStyles.amountSmall.copyWith(
                  color: isPositive
                      ? colors.tertiary
                      : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (secondaryInfo != null) ...[
                const SizedBox(height: 3),

                Text(
                  secondaryInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    )
    );
  }

  IconData _transactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.shopping_bag_outlined;

      case TransactionType.income:
        return Icons.south_west_rounded;

      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }
}

class _BalanceTrendPainter extends CustomPainter {
  _BalanceTrendPainter({
    required this.history,
    required this.lineColor,
    required this.gridColor,
  });

  final List<AccountBalancePoint> history;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) {
      return;
    }

    final values = history
        .map((point) => point.balance)
        .toList();

    final minValue =
        values.reduce((a, b) => a < b ? a : b);

    final maxValue =
        values.reduce((a, b) => a > b ? a : b);

    final range = maxValue - minValue;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < history.length; i++) {
      final x = history.length == 1
          ? size.width / 2
          : size.width * i / (history.length - 1);

      final normalized = range == 0
          ? 0.5
          : (history[i].balance - minValue) / range;

      final y =
          size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      linePaint,
    );

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < history.length; i++) {
      final x = history.length == 1
          ? size.width / 2
          : size.width * i / (history.length - 1);

      final normalized = range == 0
          ? 0.5
          : (history[i].balance - minValue) / range;

      final y =
          size.height - (normalized * size.height);

      final point = Offset(x, y);

      canvas.drawCircle(
        point,
        i == history.length - 1 ? 5 : 3.5,
        pointPaint,
      );

      if (i == history.length - 1) {
        canvas.drawCircle(
          point,
          5,
          pointBorderPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _BalanceTrendPainter oldDelegate,
  ) {
    return oldDelegate.history != history ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _BalanceTrendCard extends StatelessWidget {
  const _BalanceTrendCard({
    required this.history,
  });

  final List<AccountBalancePoint> history;
  
  String _formatChartDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final startBalance =
        history.isEmpty ? 0.0 : history.first.balance;

    final endBalance =
        history.isEmpty ? 0.0 : history.last.balance;

    final change = endBalance - startBalance;

    final isPositive = change >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BALANCE TREND',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${isPositive ? '+' : '-'}${MoneyFormatter.format(
                  amount: change.abs(),
                  symbol: 'RM',
                )}',
                style: AppTextStyles.amountSmall.copyWith(
                  color: isPositive
                      ? colors.tertiary
                      : colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _BalanceTrendPainter(
                history: history,
                lineColor: colors.primary,
                gridColor: colors.outlineVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (history.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatChartDate(history.first.dateTime),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                if (history.length > 2)
                  Text(
                    _formatChartDate(
                      history[history.length ~/ 2].dateTime,
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                Text(
                  _formatChartDate(history.last.dateTime),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'START',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        MoneyFormatter.format(
                          amount: startBalance,
                          symbol: 'RM',
                        ),
                        style: AppTextStyles.amountSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'CURRENT',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        MoneyFormatter.format(
                          amount: endBalance,
                          symbol: 'RM',
                        ),
                        style: AppTextStyles.amountSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}