import 'package:flutter/material.dart';

import '../domain/account.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  AccountType _selectedType = AccountType.bank;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _balanceController = TextEditingController();

  final TextEditingController _creditLimitController = TextEditingController();

  final TextEditingController _statementCycleController =
      TextEditingController();

  int _selectedColorIndex = 0;
  bool _isPrimaryAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _statementCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a manual ledger account to track balances & daily flows.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              _buildAccountTypeSelector(context),

              const SizedBox(height: 20),

              _buildAccountDetailsCard(context),

              const SizedBox(height: 20),

              _buildAccountPreferencesCard(context),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveAccount,
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                  label: const Text(
                    'Save Account',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _saveAccount() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(
      _balanceController.text.trim(),
    );

    if (name.isEmpty) {
      _showError('Please enter an account nickname.');
      return;
    }

    if (balance == null || balance < 0) {
      _showError('Please enter a valid opening balance.');
      return;
    }

    if (_selectedType == AccountType.creditCard) {
      final creditLimit = double.tryParse(
        _creditLimitController.text.trim(),
      );

      final statementDay = int.tryParse(
        _statementCycleController.text.trim(),
      );

      if (creditLimit == null || creditLimit <= 0) {
        _showError('Please enter a valid credit limit.');
        return;
      }

      if (balance > creditLimit) {
        _showError(
          'Outstanding balance cannot exceed the credit limit.',
        );
        return;
      }

      if (statementDay == null ||
          statementDay < 1 ||
          statementDay > 31) {
        _showError(
          'Statement cycle day must be between 1 and 31.',
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account is valid. Local database will be connected next.',
        ),
      ),
    );
  }

  Widget _buildAccountPreferencesCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final accentColors = <Color>[
      colors.primary,
      const Color(0xFF2F80ED),
      const Color(0xFF27AE60),
      const Color(0xFFF2994A),
      const Color(0xFFEB5757),
      const Color(0xFF9B51E0),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCENT COLOR',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              accentColors.length,
              (index) {
                final selected = _selectedColorIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColors[index],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: colors.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

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
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Use this account as the default for new transactions.',
            ),
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

  Widget _buildAccountDetailsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT NICKNAME',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'e.g. Maybank Savings',
              prefixIcon: Icon(_accountTypeIcon(_selectedType)),
              filled: true,
              fillColor: colors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'A recognizable name to distinguish this account.',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 18),

          Text(
            'BASE CURRENCY',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
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
          ),

          const SizedBox(height: 18),

          Text(
            _selectedType == AccountType.creditCard
                ? 'CURRENT OUTSTANDING BALANCE'
                : 'OPENING BALANCE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'RM ',
              hintText: '0.00',
              filled: true,
              fillColor: colors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _balanceController.clear();
                },
                icon: const Icon(Icons.clear_rounded),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _selectedType == AccountType.creditCard
                ? 'Enter the current amount you owe on this credit card.'
                : 'This will be used as the starting balance for this account.',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),

          if (_selectedType == AccountType.creditCard) ...[
            const SizedBox(height: 18),

            Text(
              'CREDIT LIMIT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
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
                hintText: '0.00',
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Total credit limit approved for this card.',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'STATEMENT CYCLE DAY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _statementCycleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 18',
                prefixIcon: const Icon(
                  Icons.calendar_month_rounded,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Enter a day from 1 to 31.',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountTypeSelector(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SELECT ACCOUNT TYPE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),

            const Spacer(),

            Text(
              _accountTypeLabel(_selectedType),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            _buildAccountTypeCard(
              context,
              type: AccountType.bank,
              title: 'Bank Account',
              subtitle: 'Savings & Current',
              icon: Icons.account_balance_rounded,
            ),

            _buildAccountTypeCard(
              context,
              type: AccountType.eWallet,
              title: 'E-Wallet',
              subtitle: 'TNG, GrabPay',
              icon: Icons.qr_code_scanner_rounded,
            ),

            _buildAccountTypeCard(
              context,
              type: AccountType.cash,
              title: 'Cash Wallet',
              subtitle: 'Physical Cash',
              icon: Icons.payments_rounded,
            ),

            _buildAccountTypeCard(
              context,
              type: AccountType.creditCard,
              title: 'Credit Card',
              subtitle: 'Line & Statement',
              icon: Icons.credit_card_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard(
    BuildContext context, {
    required AccountType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = _selectedType == type;

    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? colors.onPrimaryContainer.withValues(alpha: 0.8)
                            : colors.onSurfaceVariant,
                      ),
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

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account Selected';

      case AccountType.eWallet:
        return 'E-Wallet Selected';

      case AccountType.cash:
        return 'Cash Wallet Selected';

      case AccountType.creditCard:
        return 'Credit Card Selected';
    }
  }
}
