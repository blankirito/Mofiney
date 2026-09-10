import 'package:flutter/material.dart';

import '../domain/account.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key, required this.account});

  final Account account;

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _statementCycleController;
  late bool _isPrimaryAccount;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.account.name);

    _balanceController = TextEditingController(
      text: widget.account.openingBalance.toStringAsFixed(2),
    );

    _creditLimitController = TextEditingController(
      text: widget.account.creditLimit?.toStringAsFixed(2) ?? '',
    );

    _statementCycleController = TextEditingController(
      text: widget.account.statementCycleDay?.toString() ?? '',
    );

    _isPrimaryAccount = widget.account.isPrimary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _statementCycleController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveChanges() {
    final name = _nameController.text.trim();

    final balance = double.tryParse(_balanceController.text.trim());

    if (name.isEmpty) {
      _showError('Please enter an account nickname.');
      return;
    }

    if (balance == null || balance < 0) {
      _showError('Please enter a valid opening balance.');
      return;
    }

    double? creditLimit;
    int? statementCycleDay;

    if (widget.account.type == AccountType.creditCard) {
      creditLimit = double.tryParse(_creditLimitController.text.trim());

      statementCycleDay = int.tryParse(_statementCycleController.text.trim());

      if (creditLimit == null || creditLimit <= 0) {
        _showError('Please enter a valid credit limit.');
        return;
      }

      if (balance > creditLimit) {
        _showError('Outstanding balance cannot exceed the credit limit.');
        return;
      }

      if (statementCycleDay == null ||
          statementCycleDay < 1 ||
          statementCycleDay > 31) {
        _showError('Statement cycle day must be between 1 and 31.');
        return;
      }
    }

    final updatedAccount = widget.account.copyWith(
      name: name,
      openingBalance: balance,
      isPrimary: _isPrimaryAccount,
      creditLimit: creditLimit,
      statementCycleDay: statementCycleDay,
    );

    Navigator.of(context).pop(updatedAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Account')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT TYPE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              _buildLockedAccountType(context),

              const SizedBox(height: 20),

              Text(
                'ACCOUNT NICKNAME',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'BASE CURRENCY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              _buildLockedCurrency(context),

              const SizedBox(height: 20),

              Text(
                widget.account.type == AccountType.creditCard
                    ? 'CURRENT OUTSTANDING BALANCE'
                    : 'OPENING BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: 'RM ',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (widget.account.type == AccountType.creditCard) ...[
                const SizedBox(height: 20),

                Text(
                  'CREDIT LIMIT',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _creditLimitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    prefixText: 'RM ',
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'STATEMENT CYCLE DAY',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _statementCycleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_month_rounded),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ], // ← Credit Card conditional 到这里结束

              const SizedBox(height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPrimaryAccount,
                onChanged: (value) {
                  setState(() {
                    _isPrimaryAccount = value;
                  });
                },
                title: const Text(
                  'Set as Primary Account',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Use this account as the default for new transactions.',
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save Changes'),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Archive Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Hide this account from active balances and transaction selectors while keeping its history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _confirmArchive();
                        },
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('Archive Account'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Account?'),
          content: Text(
            'Archive ${widget.account.name}? '
            'Its transaction history will be kept.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final archivedAccount = widget.account.copyWith(
      isActive: false,
      isPrimary: false,
    );

    Navigator.of(context).pop(archivedAccount);
  }

  Widget _buildLockedCurrency(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'MY',
              style: TextStyle(
                color: colors.onError,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'MYR — Malaysian Ringgit (RM)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),

          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  IconData _accountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.eWallet:
        return Icons.qr_code_scanner_rounded;
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
    }
  }

  String _accountTypeName(AccountType type) {
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

  Widget _buildLockedAccountType(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(_accountTypeIcon(widget.account.type), color: colors.primary),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _accountTypeName(widget.account.type),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
