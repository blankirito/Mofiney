import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/transaction_mode_switcher.dart';
import 'add_income_page.dart';
import 'transfer_page.dart';
import 'scan_receipt_page.dart';

import '../data/transaction_repository.dart';
import '../data/receipt_storage.dart';
import '../domain/transaction.dart';
import '../../accounts/domain/account.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/utils/money_input_parser.dart';

import 'dart:async';

import '../../categories/domain/category.dart';
import '../../accounts/domain/account_balance_calculator.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, required this.repository});

  final TransactionRepository repository;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  static const double _moneyTolerance = 0.000001;
  double _roundMoney(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _merchantController = TextEditingController();

  final List<String> _frequentMerchants = [
    'GrabFood',
    'Shopee',
    'Jaya Grocer',
    'Petronas',
  ];

  DateTime _selectedDate = DateTime.now();

  final TextEditingController _notesController = TextEditingController();

  String? _selectedCategory;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _receiptImage;

  List<Category> _categories = [];

  StreamSubscription<List<Category>>? _categoriesSubscription;

  List<Category> get _quickCategories => _categories.take(5).toList();

  List<Account> _accounts = [];

  Account? _selectedAccount;

  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();

    _watchCategories();
    _loadAccounts();
  }

  void _watchCategories() {
    _categoriesSubscription?.cancel();

    _categoriesSubscription = categoryRepository.watchAllCategories().listen(
      (categories) {
        final expenseCategories = categories
            .where(
              (category) =>
                  category.type == CategoryType.expense && category.isActive,
            )
            .toList();

        if (!mounted) {
          return;
        }

        setState(() {
          _categories = expenseCategories;

          final selectedCategoryStillExists =
              _selectedCategory != null &&
              expenseCategories.any(
                (category) => category.name == _selectedCategory,
              );

          if (!selectedCategoryStillExists) {
            _selectedCategory = expenseCategories.isEmpty
                ? null
                : expenseCategories.first.name;
          }
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch expense categories: $error');
      },
    );
  }

  Future<void> _loadAccounts() async {
    final accounts = await accountRepository.getAllAccounts();

    final activeAccounts = accounts
        .where((account) => account.isActive)
        .toList();

    if (!mounted) {
      return;
    }

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
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showReceiptSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use camera to capture a receipt'),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(const Duration(milliseconds: 200));

                    await _pickReceipt(ImageSource.camera);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select an existing receipt image'),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(const Duration(milliseconds: 200));

                    await _pickReceipt(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeReceipt() {
    setState(() {
      _receiptImage = null;
    });
  }

  Future<void> _pickReceipt(ImageSource source) async {
    debugPrint('Opening receipt picker: $source');

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      debugPrint('Picker returned: ${image?.path}');

      if (image == null) {
        debugPrint('No image selected.');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptImage = image;
      });

      debugPrint('Receipt selected: ${image.path}');
    } catch (e) {
      debugPrint('Receipt picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionModeSwitcher(
                selectedMode: TransactionMode.expense,
                onModeChanged: (mode) {
                  switch (mode) {
                    case TransactionMode.expense:
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

              _buildCategorySection(context),

              const SizedBox(height: 16),

              _buildAccountSection(context),

              const SizedBox(height: 16),

              _buildMerchantSection(context),

              const SizedBox(height: 16),

              _buildDateSection(context),

              const SizedBox(height: 16),

              _buildNotesSection(context),

              const SizedBox(height: 16),

              _buildReceiptSection(context),

              const SizedBox(height: 20),

              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasReceipt = _receiptImage != null;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECEIPT DOCUMENT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),

              if (hasReceipt)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: colors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '1 Attached',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.tertiary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (!hasReceipt)
            InkWell(
              onTap: _showReceiptSourcePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 26,
                      color: colors.primary,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Add receipt',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Take a photo or choose from gallery',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_receiptImage!.path),
                        width: 80,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _removeReceipt,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    onTap: _showReceiptSourcePicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 24,
                            color: colors.primary,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Replace receipt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'Camera or gallery',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _saveExpense() async {
    final amountText = _amountController.text.trim();

    final amount = MoneyInputParser.parse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense amount.')),
      );
      return;
    }

    final merchant = _merchantController.text.trim();

    if (merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a merchant or payee.')),
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

    final selectedCategory = _selectedCategory;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final existingTransactions = await widget.repository.getAllTransactions();

    if (!mounted) {
      return;
    }

    final currentBalance = _roundMoney(
      AccountBalanceCalculator.calculate(selectedAccount, existingTransactions),
    );

    if (selectedAccount.type == AccountType.creditCard) {
      final creditLimit = selectedAccount.creditLimit;

      if (creditLimit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set a credit limit before using this credit card.'),
          ),
        );

        return;
      }

      final availableCredit = _roundMoney(creditLimit - currentBalance);

      if (amount - availableCredit > _moneyTolerance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Expense exceeds available credit (RM ${availableCredit.toStringAsFixed(2)}).',
            ),
          ),
        );

        return;
      }
    } else if (amount - currentBalance > _moneyTolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expense exceeds available balance (RM ${currentBalance.toStringAsFixed(2)}).',
          ),
        ),
      );

      return;
    }

    String? savedReceiptPath;

    if (_receiptImage != null) {
      try {
        savedReceiptPath = await ReceiptStorage.save(_receiptImage!.path);
      } catch (error) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save receipt image: $error')),
        );

        return;
      }
    }

    if (!mounted) {
      return;
    }

    final transaction = Transaction(
      id: 'txn_${DateTime.now().microsecondsSinceEpoch}',
      title: merchant,
      category: selectedCategory,
      accountId: selectedAccount.id,
      account: selectedAccount.name,

      amount: amount,
      currencyCode: 'MYR',
      accountAmount: amount,

      type: TransactionType.expense,
      dateTime: _selectedDate,
      paymentMethod: null,
      note: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      tags: const [],
      receiptPath: savedReceiptPath,
    );

    try {
      await widget.repository.insertTransaction(transaction);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(transaction);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save expense: $error')));
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _saveExpense,
        icon: const Icon(Icons.check_rounded),
        label: const Text('Save Expense'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Add additional details...',
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

  String _formatExpenseDate(DateTime date) {
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

  Future<void> _pickExpenseDate() async {
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

  Widget _buildDateSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
                  'DATE OF EXPENSE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _formatExpenseDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _pickExpenseDate,
            icon: const Icon(Icons.edit_calendar_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantSection(BuildContext context) {
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
            'MERCHANT / PAYEE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _merchantController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Merchant name...',
              prefixIcon: const Icon(Icons.storefront_outlined),
              filled: true,
              fillColor: colors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Frequent:',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),

              ..._frequentMerchants.map(
                (merchant) => ActionChip(
                  label: Text(merchant),
                  onPressed: () {
                    _merchantController.text = merchant;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
                    'Select Account',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              ..._accounts.map(
                (account) => ListTile(
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

                    Navigator.pop(context);
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
                    'PAY FROM ACCOUNT',
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

  void _showCategoryPicker() {
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
                  'Select Category',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(height: 4);
                    },
                    itemBuilder: (context, index) {
                      final category = _categories[index];

                      final label = category.name;
                      final icon = _iconFromCodePoint(category.iconCodePoint);

                      final selected = label == _selectedCategory;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: CircleAvatar(child: Icon(icon, size: 20)),
                        title: Text(label),
                        trailing: selected
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = label;
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

  Widget _buildCategorySection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedCategoryData = _categories.firstWhere(
      (category) => category.name == _selectedCategory,
      orElse: () => _categories.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK CATEGORY',
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
            children: _quickCategories.map((category) {
              final label = category.name;
              final icon = _iconFromCodePoint(category.iconCodePoint);

              final selected = _selectedCategory == label;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = label;
                    });
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 17,
                          color: selected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),

                        const SizedBox(width: 6),

                        Text(
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
                      ],
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
                  _iconFromCodePoint(selectedCategoryData.iconCodePoint),
                  color: colors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECTED CATEGORY',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      selectedCategoryData.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showCategoryPicker,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Change'),
              ),
            ],
          ),
        ),
      ],
    );
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
            'AMOUNT SPENT',
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
                  color: colors.error,
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
                    color: colors.error,
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
        ],
      ),
    );
  }
}

IconData _iconFromCodePoint(int codePoint) {
  const icons = [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.local_grocery_store_outlined,
    Icons.shopping_bag_outlined,
    Icons.movie_outlined,
    Icons.category_outlined,
  ];

  return icons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.category_outlined,
  );
}
