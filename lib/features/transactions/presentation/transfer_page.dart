import 'package:flutter/material.dart';

import 'widgets/transaction_mode_switcher.dart';
import 'add_expense_page.dart';
import 'add_income_page.dart';
import 'scan_receipt_page.dart';

class AddTransferPage extends StatefulWidget {
  const AddTransferPage({super.key});

  @override
  State<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends State<AddTransferPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _fromAccount = 'CIMB';
  String _toAccount = 'Maybank';

  DateTime _selectedDate = DateTime.now();

  final List<String> _accounts = [
    'Maybank',
    'CIMB',
    "Touch 'n Go",
    'Credit Card',
    'Cash',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
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
                          builder: (_) => const AddExpensePage(),
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
        onPressed: _saveTransfer,
        icon: const Icon(
          Icons.swap_horiz_rounded,
        ),
        label: const Text(
          'Transfer Money',
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _saveTransfer() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid transfer amount.',
          ),
        ),
      );

      return;
    }

    if (_fromAccount == _toAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'From account and To account cannot be the same.',
          ),
        ),
      );

      return;
    }

    debugPrint('----- TRANSFER -----');
    debugPrint('Amount: $amount');
    debugPrint('From: $_fromAccount');
    debugPrint('To: $_toAccount');
    debugPrint('Date: $_selectedDate');
    debugPrint('Notes: ${_notesController.text.trim()}');
    debugPrint('--------------------');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transfer is ready to save.',
        ),
      ),
    );
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
          prefixIcon: const Icon(
            Icons.edit_note_outlined,
          ),
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
            Icon(
              Icons.calendar_today_outlined,
              color: colors.onSurfaceVariant,
            ),

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

            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTransferDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
    );

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
      label: Text(
        '+${amount.toStringAsFixed(0)}',
      ),
      onPressed: () {
        final currentAmount =
            double.tryParse(_amountController.text.trim()) ?? 0;

        final updatedAmount = currentAmount + amount;

        _amountController.text =
            updatedAmount.toStringAsFixed(2);
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),

              ..._accounts.map((account) {
                final isInvalid = selectingFromAccount
                    ? account == _toAccount
                    : account == _fromAccount;

                final isSelected = selectingFromAccount
                    ? account == _fromAccount
                    : account == _toAccount;

                return ListTile(
                  enabled: !isInvalid,
                  leading: CircleAvatar(
                    child: Text(
                      _accountInitials(account),
                    ),
                  ),
                  title: Text(account),
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
                              _fromAccount = account;
                            } else {
                              _toAccount = account;
                            }
                          });

                          Navigator.pop(context);
                        },
                );
              }),
            ],
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

            Icon(
              Icons.expand_more_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
    });
  }

  Widget _buildAccountFlowSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildAccountCard(
          context,
          label: 'FROM ACCOUNT',
          account: _fromAccount,
          onTap: () {
            _showAccountPicker(
              context,
              selectingFromAccount: true,
            );
          },
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Divider(
                color: colors.outlineVariant,
              ),
            ),

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
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: colors.primary,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Divider(
                color: colors.outlineVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _buildAccountCard(
          context,
          label: 'TO ACCOUNT',
          account: _toAccount,
          onTap: () {
            _showAccountPicker(
              context,
              selectingFromAccount: false,
            );
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
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}