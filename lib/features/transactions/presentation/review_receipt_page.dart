import 'dart:io';

import 'package:flutter/material.dart';

class ReceiptItem {
  ReceiptItem({
    required this.name,
    required this.price,
  });

  String name;
  double price;
}

class ReviewReceiptPage extends StatefulWidget {
  final String imagePath;

  const ReviewReceiptPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReviewReceiptPage> createState() => _ReviewReceiptPageState();
}

class _ReviewReceiptPageState extends State<ReviewReceiptPage> {
  late final TextEditingController _merchantController;
  late final TextEditingController _dateController;

  String _category = 'Groceries';
  String _account = 'Maybank';

  final List<ReceiptItem> _items = [
    ReceiptItem(name: 'Milk', price: 9.90),
    ReceiptItem(name: 'Bread', price: 5.50),
    ReceiptItem(name: 'Chicken', price: 22.00),
    ReceiptItem(name: 'Household Items', price: 25.40),
  ];

  @override
  void initState() {
    super.initState();

    _merchantController = TextEditingController(
      text: 'Jaya Grocer',
    );

    _dateController = TextEditingController(
      text: '5 Sep 2026',
    );
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  double get _total {
    return _items.fold(
      0,
      (sum, item) => sum + item.price,
    );
  }

  void _changeCategory() {
    const categories = [
      'Groceries',
      'Dining & Cafe',
      'Household',
      'Health & Beauty',
      'Entertainment',
    ];

    final currentIndex = categories.indexOf(_category);

    setState(() {
      _category =
          categories[(currentIndex + 1) % categories.length];
    });
  }

  void _changeAccount() {
    const accounts = [
      'Maybank',
      'CIMB',
      'Credit Card',
      'Touch n Go eWallet',
    ];

    final currentIndex = accounts.indexOf(_account);

    setState(() {
      _account =
          accounts[(currentIndex + 1) % accounts.length];
    });
  }

  void _addItem() {
    setState(() {
      _items.add(
        ReceiptItem(
          name: 'New Item',
          price: 0,
        ),
      );
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _editItem(
    int index,
  ) async {
    final item = _items[index];

    final nameController = TextEditingController(
      text: item.name,
    );

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
                decoration: const InputDecoration(
                  labelText: 'Item name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
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

    final price = double.tryParse(
      priceController.text.trim(),
    );

    if (price == null) {
      return;
    }

    setState(() {
      item.name = nameController.text.trim();
      item.price = price;
    });
  }

  void _saveExpense() {
    debugPrint('----- RECEIPT EXPENSE -----');
    debugPrint(
      'Merchant: ${_merchantController.text}',
    );
    debugPrint(
      'Date: ${_dateController.text}',
    );
    debugPrint('Category: $_category');
    debugPrint('Account: $_account');
    debugPrint(
      'Total: ${_total.toStringAsFixed(2)}',
    );

    for (final item in _items) {
      debugPrint(
        '${item.name}: RM ${item.price.toStringAsFixed(2)}',
      );
    }

    debugPrint('---------------------------');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Receipt expense saved successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Review Receipt'),
      ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(widget.imagePath),
                    width: 80,
                    height: 110,
                    fit: BoxFit.cover,
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
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                          ),
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
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'RM ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
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
                    value: _category,
                    icon: Icons.category_outlined,
                    onTap: _changeCategory,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildSelectorCard(
                    title: 'PAY FROM',
                    value: _account,
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: _changeAccount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Line Items',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),

                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...List.generate(
              _items.length,
              (index) {
                final item = _items[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      'RM ${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _editItem(index);
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteItem(index);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: colors.tertiary,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Items match receipt total',
                  ),
                ),
                Text(
                  'RM ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _saveExpense,
              icon: const Icon(
                Icons.check_rounded,
              ),
              label: Text(
                'Save Expense '
                '(RM ${_total.toStringAsFixed(2)})',
              ),
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(52),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.photo_camera_outlined,
              ),
              label: const Text(
                'Rescan Receipt',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(48),
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
                Icon(
                  icon,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
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