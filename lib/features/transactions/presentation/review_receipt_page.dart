import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/receipt_ocr_draft.dart';
import '../../accounts/domain/account.dart';
import '../../categories/domain/category.dart';
import '../../../core/app_dependencies.dart';

import '../data/receipt_storage.dart';
import '../domain/transaction.dart';
import '../../accounts/domain/account_balance_calculator.dart';
import '../../../core/utils/money_input_parser.dart';

/*
class ReceiptItem {
  ReceiptItem({required this.name, required this.price});

  String name;
  double price;
}
*/

class ReviewReceiptPage extends StatefulWidget {
  const ReviewReceiptPage({
    super.key,
    required this.imagePath,
    required this.draft,
  });

  final String imagePath;
  final ReceiptOcrDraft draft;

  @override
  State<ReviewReceiptPage> createState() => _ReviewReceiptPageState();
}

class _ReviewReceiptPageState extends State<ReviewReceiptPage> {
  late final TextEditingController _merchantController;
  late final TextEditingController _dateController;

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;

  List<Category> _categories = [];
  StreamSubscription<List<Category>>? _categoriesSubscription;
  String? _selectedCategory;

  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _isLoadingAccounts = true;

  static const double _moneyTolerance = 0.000001;

  bool _isSaving = false;

  double _roundMoney(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /*final List<ReceiptItem> _items = [
    ReceiptItem(name: 'Milk', price: 9.90),
    ReceiptItem(name: 'Bread', price: 5.50),
    ReceiptItem(name: 'Chicken', price: 22.00),
    ReceiptItem(name: 'Household Items', price: 25.40),
  ];*/

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.draft.date ?? DateTime.now();

    _merchantController = TextEditingController(text: widget.draft.merchant);

    _dateController = TextEditingController(text: _formatDate(_selectedDate));

    _amountController = TextEditingController(
      text: widget.draft.amount?.toStringAsFixed(2) ?? '',
    );

    _noteController = TextEditingController(text: widget.draft.note);

    _watchCategories();
    _loadAccounts();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
      _dateController.text = _formatDate(selectedDate);
    });
  }

  void _showReceiptPreview() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        });
      },
      onError: (Object error) {
        debugPrint('Failed to load expense categories: $error');
      },
    );
  }

  Future<void> _loadAccounts() async {
    final accounts = await accountRepository.getAllAccounts();

    if (!mounted) {
      return;
    }

    setState(() {
      _accounts = accounts.where((account) => account.isActive).toList();
      _isLoadingAccounts = false;
    });
  }

  void _showCategoryPicker() {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active expense categories available.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._categories.map(
                (category) => ListTile(
                  title: Text(category.name),
                  trailing: _selectedCategory == category.name
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
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

  void _showAccountPicker() {
    if (_isLoadingAccounts) {
      return;
    }

    if (_accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active accounts available.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                'Select Account',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._accounts.map(
                (account) => ListTile(
                  title: Text(account.name),
                  subtitle: Text(account.type.name),
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

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _merchantController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  /*double get _total {
    return _items.fold(0, (sum, item) => sum + item.price);
  }*/

  /*void _addItem() {
    setState(() {
      _items.add(ReceiptItem(name: 'New Item', price: 0));
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _editItem(int index) async {
    final item = _items[index];

    final nameController = TextEditingController(text: item.name);

    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(2),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: 'RM ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final price = double.tryParse(priceController.text.trim());

    if (price == null) {
      return;
    }

    setState(() {
      item.name = nameController.text.trim();
      item.price = price;
    });
  }*/

  Future<void> _saveExpense() async {
    if (_isSaving) {
      return;
    }

    final amount = MoneyInputParser.parse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
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

    final selectedCategory = _selectedCategory;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
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

    setState(() {
      _isSaving = true;
    });

    try {
      final existingTransactions = await transactionRepository
          .getAllTransactions();

      if (!mounted) {
        return;
      }

      final currentBalance = _roundMoney(
        AccountBalanceCalculator.calculate(
          selectedAccount,
          existingTransactions,
        ),
      );

      if (selectedAccount.type == AccountType.creditCard) {
        final creditLimit = selectedAccount.creditLimit;

        if (creditLimit == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Set a credit limit before using this credit card.',
              ),
            ),
          );
          return;
        }

        final availableCredit = _roundMoney(creditLimit - currentBalance);

        if (amount - availableCredit > _moneyTolerance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Expense exceeds available credit '
                '(RM ${availableCredit.toStringAsFixed(2)}).',
              ),
            ),
          );
          return;
        }
      } else if (amount - currentBalance > _moneyTolerance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Expense exceeds available balance '
              '(RM ${currentBalance.toStringAsFixed(2)}).',
            ),
          ),
        );
        return;
      }

      final savedReceiptPath = await ReceiptStorage.save(widget.imagePath);

      final transaction = Transaction(
        id: 'txn_${DateTime.now().microsecondsSinceEpoch}',
        title: merchant,
        category: selectedCategory,
        accountId: selectedAccount.id,
        account: selectedAccount.name,
        amount: amount,
        type: TransactionType.expense,
        dateTime: _selectedDate,
        currencyCode: 'MYR',
        accountAmount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        tags: const [],
        receiptPath: savedReceiptPath,
      );

      await transactionRepository.insertTransaction(transaction);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(transaction);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save receipt expense: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Review Receipt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.document_scanner_rounded,
                    color: colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Smart OCR Parsing Complete',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: 'View full receipt image',
                  child: InkWell(
                    onTap: _showReceiptPreview,
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(widget.imagePath),
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _merchantController,
                        decoration: const InputDecoration(
                          labelText: 'Merchant',
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          suffixIcon: Icon(Icons.edit_calendar_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'RM ',
                      hintText: '0.00',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSelectorCard(
                    title: 'CATEGORY',
                    value: _selectedCategory ?? 'Select category',
                    icon: Icons.category_outlined,
                    onTap: _showCategoryPicker,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildSelectorCard(
                    title: 'PAY FROM',
                    value: _selectedAccount?.name ?? 'Select account',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: _showAccountPicker,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Extra details read from the receipt',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Line Items',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),

                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...List.generate(_items.length, (index) {
              final item = _items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shopping_bag_outlined),
                  ),
                  title: Text(item.name),
                  subtitle: Text('RM ${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _editItem(index);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteItem(index);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: colors.tertiary,
                ),
                const SizedBox(width: 6),
                const Expanded(child: Text('Items match receipt total')),
                Text(
                  'RM ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),*/
            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _isSaving ? null : _saveExpense,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Expense'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Rescan Receipt'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, size: 18, color: colors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
