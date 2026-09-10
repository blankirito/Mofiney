import 'package:flutter/material.dart';

import 'widgets/transaction_mode_switcher.dart';
import 'add_expense_page.dart';
import 'add_income_page.dart';
import 'scan_receipt_page.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/utils/money_input_parser.dart';
import '../../accounts/domain/account.dart';
import '../domain/transaction.dart';
import '../../accounts/domain/account_balance_calculator.dart';

class AddTransferPage extends StatefulWidget {
  const AddTransferPage({super.key});

  @override
  State<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends State<AddTransferPage> {
  static const double _moneyTolerance = 0.000001;
  double _roundMoney(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Account> _accounts = [];
  String? _fromAccountId;
  String? _toAccountId;
  bool _isLoadingAccounts = true;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await accountRepository.getAllAccounts();

    if (!mounted) {
      return;
    }

    setState(() {
      _accounts = accounts;

      if (accounts.isNotEmpty) {
        _fromAccountId = accounts.first.id;

        if (accounts.length > 1) {
          _toAccountId = accounts[1].id;
        }
      }

      _isLoadingAccounts = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TransactionModeSwitcher(
                selectedMode: TransactionMode.transfer,
                onModeChanged: (mode) {
                  switch (mode) {
                    case TransactionMode.expense:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddExpensePage(repository: transactionRepository),
                        ),
                      );
                      break;

                    case TransactionMode.income:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddIncomePage(),
                        ),
                      );
                      break;

                    case TransactionMode.transfer:
                      break;

                    case TransactionMode.scan:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanReceiptPage(),
                        ),
                      );
                      break;
                  }
                },
              ),

              const SizedBox(height: 16),

              _buildAccountFlowSection(context),

              const SizedBox(height: 16),

              _buildAmountSection(context),

              const SizedBox(height: 16),

              _buildDateSection(context),

              const SizedBox(height: 16),

              _buildNotesSection(context),

              const SizedBox(height: 20),

              _buildSaveButton(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoadingAccounts || _accounts.length < 2
            ? null
            : _saveTransfer,
        icon: const Icon(Icons.swap_horiz_rounded),
        label: const Text('Transfer Money'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Account? _findAccount(String? accountId) {
    for (final account in _accounts) {
      if (account.id == accountId) {
        return account;
      }
    }

    return null;
  }

  Future<void> _saveTransfer() async {
    final amountText = _amountController.text.trim();
    final amount = MoneyInputParser.parse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transfer amount.')),
      );

      return;
    }

    if (_fromAccountId == null ||
        _toAccountId == null ||
        _fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select two different accounts.')),
      );

      return;
    }

    final now = DateTime.now();

    final transactionDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final sourceAccount = _findAccount(_fromAccountId);
    final destinationAccount = _findAccount(_toAccountId);

    if (sourceAccount == null || destinationAccount == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find the selected accounts.')),
      );

      return;
    }

    final existingTransactions = await transactionRepository
        .getAllTransactions();

    if (!mounted) {
      return;
    }

    final sourceBalance = AccountBalanceCalculator.calculate(
      sourceAccount,
      existingTransactions,
    );

    final destinationBalance = _roundMoney(
      AccountBalanceCalculator.calculate(
        destinationAccount,
        existingTransactions,
      ),
    );
    if (sourceAccount.type == AccountType.creditCard) {
      final creditLimit = sourceAccount.creditLimit;

      if (creditLimit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Set a credit limit before using this card for a transfer.',
            ),
          ),
        );

        return;
      }

      final availableCredit = _roundMoney(creditLimit - sourceBalance);

      if (amount - availableCredit > _moneyTolerance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transfer exceeds available credit (RM ${availableCredit.toStringAsFixed(2)}).',
            ),
          ),
        );

        return;
      }
    } else if (amount - sourceBalance > _moneyTolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer exceeds available balance (RM ${sourceBalance.toStringAsFixed(2)}).',
          ),
        ),
      );

      return;
    }

    if (destinationAccount.type == AccountType.creditCard &&
        amount - destinationBalance > _moneyTolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment exceeds card outstanding (RM ${destinationBalance.toStringAsFixed(2)}).',
          ),
        ),
      );

      return;
    }

    final transaction = Transaction(
      id: 'transfer-${DateTime.now().microsecondsSinceEpoch}',
      title: 'Transfer to ${destinationAccount.name}',
      category: 'Transfer',

      accountId: sourceAccount.id,
      account: sourceAccount.name,

      amount: amount,
      currencyCode: 'MYR',
      accountAmount: amount,

      type: TransactionType.transfer,
      dateTime: transactionDateTime,

      destinationAccount: destinationAccount.name,
      destinationAccountId: destinationAccount.id,
      destinationAccountAmount: amount,

      note: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await transactionRepository.insertTransaction(transaction);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save transfer: $error')),
      );
    }
  }

  Widget _buildNotesSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _notesController,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Notes (Optional)',
          hintText: 'Add a short description...',
          prefixIcon: const Icon(Icons.edit_note_outlined),
          filled: true,
          fillColor: colors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _pickTransferDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: colors.onSurfaceVariant),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE OF TRANSFER',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _formatTransferDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatTransferDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final selected = DateTime(date.year, date.month, date.day);

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

    if (selected == today) {
      return 'Today, ${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickTransferDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Widget _buildQuickAmountChip(double amount) {
    return ActionChip(
      label: Text('+${amount.toStringAsFixed(0)}'),
      onPressed: () {
        final currentAmount =
            MoneyInputParser.parse(_amountController.text) ?? 0;

        final updatedAmount = currentAmount + amount;

        _amountController.text = updatedAmount.toStringAsFixed(2);
      },
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'TRANSFER AMOUNT',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 8),

              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: [
              _buildQuickAmountChip(50),
              _buildQuickAmountChip(100),
              _buildQuickAmountChip(200),
              _buildQuickAmountChip(500),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Transfers are neutral cash flow and do not count as income or expense.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountPicker(
    BuildContext context, {
    required bool selectingFromAccount,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectingFromAccount
                          ? 'Select From Account'
                          : 'Select To Account',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: _accounts.map((account) {
                      final isInvalid = selectingFromAccount
                          ? account.id == _toAccountId
                          : account.id == _fromAccountId;

                      final isSelected = selectingFromAccount
                          ? account.id == _fromAccountId
                          : account.id == _toAccountId;

                      return ListTile(
                        enabled: !isInvalid,
                        leading: CircleAvatar(
                          child: Text(_accountInitials(account.name)),
                        ),
                        title: Text(account.name),
                        subtitle: isInvalid
                            ? const Text('Already selected')
                            : null,
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: isInvalid
                            ? null
                            : () {
                                setState(() {
                                  if (selectingFromAccount) {
                                    _fromAccountId = account.id;
                                  } else {
                                    _toAccountId = account.id;
                                  }
                                });

                                Navigator.pop(context);
                              },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _accountInitials(String account) {
    if (account == "Touch 'n Go") {
      return 'TNG';
    }

    if (account == 'Credit Card') {
      return 'CC';
    }

    if (account == 'Cash') {
      return 'CA';
    }

    if (account.length >= 2) {
      return account.substring(0, 2).toUpperCase();
    }

    return account.toUpperCase();
  }

  String _accountName(String? accountId) {
    return _findAccount(accountId)?.name ?? 'Select account';
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required String label,
    required String account,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _accountInitials(account),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    account,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.expand_more_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _swapAccounts() {
    setState(() {
      final temporaryId = _fromAccountId;
      _fromAccountId = _toAccountId;
      _toAccountId = temporaryId;
    });
  }

  Widget _buildAccountFlowSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildAccountCard(
          context,
          label: 'FROM ACCOUNT',
          account: _accountName(_fromAccountId),
          onTap: () {
            _showAccountPicker(context, selectingFromAccount: true);
          },
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant)),

            const SizedBox(width: 8),

            InkWell(
              onTap: _swapAccounts,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_vert_rounded, color: colors.primary),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(child: Divider(color: colors.outlineVariant)),
          ],
        ),

        const SizedBox(height: 8),

        _buildAccountCard(
          context,
          label: 'TO ACCOUNT',
          account: _accountName(_toAccountId),
          onTap: () {
            _showAccountPicker(context, selectingFromAccount: false);
          },
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              'Internal transfer · No impact on net balance',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}
