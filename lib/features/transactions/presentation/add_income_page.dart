import 'package:flutter/material.dart';

import 'widgets/transaction_mode_switcher.dart';
import 'add_expense_page.dart';
import 'transfer_page.dart';
import 'scan_receipt_page.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/utils/money_input_parser.dart';
import '../domain/transaction.dart';

import 'dart:async';

import '../../accounts/domain/account.dart';
import '../../categories/domain/category.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _selectedIncomeSource;
  Account? _selectedAccount;

  List<Category> _incomeSources = [];
  StreamSubscription<List<Category>>? _categoriesSubscription;

  List<Category> get _quickIncomeSources => _incomeSources.take(5).toList();

  List<Account> _accounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _watchIncomeCategories();
    _loadAccounts();
  }

  void _watchIncomeCategories() {
    _categoriesSubscription?.cancel();

    _categoriesSubscription = categoryRepository.watchAllCategories().listen(
      (categories) {
        final incomeCategories = categories
            .where(
              (category) =>
                  category.type == CategoryType.income && category.isActive,
            )
            .toList();

        if (!mounted) return;

        setState(() {
          _incomeSources = incomeCategories;

          final selectedStillExists =
              _selectedIncomeSource != null &&
              incomeCategories.any(
                (category) => category.name == _selectedIncomeSource,
              );

          if (!selectedStillExists) {
            _selectedIncomeSource = incomeCategories.isEmpty
                ? null
                : incomeCategories.first.name;
          }
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch income categories: $error');
      },
    );
  }

  Future<void> _loadAccounts() async {
    final accounts = await accountRepository.getAllAccounts();

    final activeAccounts = accounts
        .where((account) => account.isActive)
        .toList();

    if (!mounted) return;

    setState(() {
      _accounts = activeAccounts;

      if (activeAccounts.isNotEmpty) {
        _selectedAccount = activeAccounts.firstWhere(
          (account) => account.isPrimary,
          orElse: () => activeAccounts.first,
        );
      }

      _isLoadingAccounts = false;
    });
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionModeSwitcher(
                selectedMode: TransactionMode.income,
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
                      break;

                    case TransactionMode.transfer:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransferPage(),
                        ),
                      );
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

              _buildAmountSection(context),

              const SizedBox(height: 16),

              _buildIncomeSourceSection(context),

              const SizedBox(height: 16),

              _buildAccountSection(context),

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
        onPressed: _saveIncome,
        icon: const Icon(Icons.check_rounded),
        label: const Text('Save Income'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _saveIncome() async {
    final amountText = _amountController.text.trim();
    final amount = MoneyInputParser.parse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid income amount.')),
      );
      return;
    }

    final selectedAccount = _selectedAccount;
    if (selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account.')),
      );
      return;
    }

    final selectedIncomeSource = _selectedIncomeSource;
    if (selectedIncomeSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an income category.')),
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

    final transaction = Transaction(
      id: 'income_${DateTime.now().microsecondsSinceEpoch}',
      title: selectedIncomeSource,
      category: selectedIncomeSource,
      accountId: selectedAccount.id,
      account: selectedAccount.name,

      amount: amount,
      currencyCode: 'MYR',
      accountAmount: amount,

      type: TransactionType.income,
      dateTime: transactionDateTime,
      note: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await transactionRepository.insertTransaction(transaction);

      if (!mounted) return;

      Navigator.of(context).pop(transaction);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save income: $error')));
    }
  }

  Widget _buildNotesSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTES (OPTIONAL)',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _notesController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add memorandum or details...',
              prefixIcon: const Icon(Icons.edit_note_outlined),
              filled: true,
              fillColor: colors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _pickIncomeDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 19,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE OF INCOME',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _formatIncomeDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.edit_calendar_outlined, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatIncomeDate(DateTime date) {
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

  Future<void> _pickIncomeDate() async {
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

  Widget _buildAmountSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'AMOUNT RECEIVED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
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
                  color: colors.tertiary,
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
                    color: colors.tertiary,
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

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.tertiary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: colors.tertiary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Income inflow',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSourceSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_incomeSources.isEmpty) {
      return const Text('No active income categories available.');
    }

    final selectedSourceData = _incomeSources.firstWhere(
      (source) => source.name == _selectedIncomeSource,
      orElse: () => _incomeSources.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INCOME SOURCE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickIncomeSources.map((source) {
              final label = source.name;
              final selected = _selectedIncomeSource == label;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIncomeSource = label;
                    });
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconFromCodePoint(selectedSourceData.iconCodePoint),
                  size: 20,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECTED SOURCE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      selectedSourceData.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  _showIncomeSourcePicker(context);
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showIncomeSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Income Source',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _incomeSources.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final source = _incomeSources[index];
                      final selected = _selectedIncomeSource == source.name;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            _iconFromCodePoint(source.iconCodePoint),
                            size: 20,
                          ),
                        ),
                        title: Text(source.name),
                        trailing: selected
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedIncomeSource = source.name;
                          });

                          Navigator.pop(sheetContext);
                        },
                      );
                    },
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

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Account',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              ..._accounts.map(
                (account) => ListTile(
                  leading: CircleAvatar(
                    child: Text(_accountInitials(account.name)),
                  ),
                  title: Text(account.name),
                  subtitle: Text(
                    '${account.currencyCode} · transaction uses this currency',
                  ),
                  trailing: _selectedAccount?.id == account.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAccount = account;
                    });

                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    if (_isLoadingAccounts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_accounts.isEmpty) {
      return const Text('No active accounts available.');
    }

    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showAccountPicker(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _accountInitials(_selectedAccount?.name ?? ''),
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
                    'RECEIVE INTO ACCOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _selectedAccount?.name ?? 'Select account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.unfold_more_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  IconData _iconFromCodePoint(int codePoint) {
    const icons = [
      Icons.work_outline_rounded,
      Icons.laptop_mac_rounded,
      Icons.show_chart_rounded,
      Icons.card_giftcard_rounded,
      Icons.replay_rounded,
      Icons.payments_outlined,
      Icons.category_outlined,
    ];

    return icons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.category_outlined,
    );
  }
}
