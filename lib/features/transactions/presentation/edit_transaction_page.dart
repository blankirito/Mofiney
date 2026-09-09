import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../domain/transaction.dart';

class EditTransactionPage extends StatefulWidget {
  const EditTransactionPage({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  State<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState
    extends State<EditTransactionPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _tagsController;

  late String _selectedCategory;
  late String _selectedAccountId;
  late String _selectedAccount;
  String? _selectedPaymentMethod;

  String? _selectedDestinationAccountId;
  String? _selectedDestinationAccount;

  late DateTime _selectedDateTime;

  static const List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Groceries',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Health',
    'Other Expenses',
  ];

  static const List<String> _incomeCategories = [
    'Income',
    'Salary',
    'Bonus',
    'Freelance',
    'Investment',
    'Other Income',
  ];

  static const List<String> _paymentMethods = [
    'Card',
    'Debit Card',
    'Credit Card',
    'E-Wallet',
    'Cash',
    'Bank Transfer',
    'Manual',
  ];

  static const List<({String id, String name})> _accounts = [
    (id: 'maybank', name: 'Maybank'),
    (id: 'cimb', name: 'CIMB'),
    (id: 'tng', name: "Touch 'n Go"),
    (id: 'cash', name: 'Cash'),
    (id: 'cimb-visa', name: 'Credit Card'),
  ];

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.transaction.amount
          .abs()
          .toStringAsFixed(2),
    );

    _titleController = TextEditingController(
      text: widget.transaction.title,
    );

    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );

    _tagsController = TextEditingController(
      text: widget.transaction.tags.join(', '),
    );

    _selectedCategory = widget.transaction.category;

    _selectedAccountId = widget.transaction.accountId;
    _selectedAccount = widget.transaction.account;

    _selectedPaymentMethod =
        widget.transaction.paymentMethod;

    _selectedDestinationAccountId =
        widget.transaction.destinationAccountId;

    _selectedDestinationAccount =
        widget.transaction.destinationAccount;

    _selectedDateTime = widget.transaction.dateTime;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionType(context),

              const SizedBox(height: AppSpacing.lg),

              _buildAmountField(context),

              const SizedBox(height: AppSpacing.md),

              _buildTitleField(context),

              const SizedBox(height: AppSpacing.md),

              _buildEditableDetails(context),

              const SizedBox(height: AppSpacing.md),

              _buildDateTimeField(context),

              const SizedBox(height: AppSpacing.md),

              _buildNotesField(context),

              const SizedBox(height: AppSpacing.md),

              _buildTagsField(context),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                  label: const Text(
                    'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _saveChanges() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    // Title validation
    if (title.isEmpty) {
      _showValidationMessage(
        'Please enter a transaction title.',
      );
      return;
    }

    // Amount validation
    if (amount == null || amount <= 0) {
      _showValidationMessage(
        'Please enter a valid amount greater than 0.',
      );
      return;
    }

    // Transfer validation
    if (widget.transaction.type ==
        TransactionType.transfer) {
      if (_selectedDestinationAccountId == null ||
          _selectedDestinationAccount == null) {
        _showValidationMessage(
          'Please select a destination account.',
        );
        return;
      }

      if (_selectedAccountId ==
          _selectedDestinationAccountId) {
        _showValidationMessage(
          'Source and destination accounts must be different.',
        );
        return;
      }
    }

    final note = _noteController.text.trim();

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    final updatedTransaction = Transaction(
      title: title,
      category: _selectedCategory,
      accountId: _selectedAccountId,
      account: _selectedAccount,
      amount: amount,
      type: widget.transaction.type,
      dateTime: _selectedDateTime,
      paymentMethod:
          widget.transaction.type == TransactionType.transfer
              ? null
              : _selectedPaymentMethod,
      destinationAccount:
          widget.transaction.type == TransactionType.transfer
              ? _selectedDestinationAccount
              : null,
      destinationAccountId:
          widget.transaction.type == TransactionType.transfer
              ? _selectedDestinationAccountId
              : null,
      note: note.isEmpty ? null : note,
      tags: tags,
      receiptPath: widget.transaction.receiptPath,
    );

    Navigator.pop(
      context,
      updatedTransaction,
    );
  }

  String get _formattedSelectedTime {
    final hour = _selectedDateTime.hour == 0
        ? 12
        : _selectedDateTime.hour > 12
            ? _selectedDateTime.hour - 12
            : _selectedDateTime.hour;

    final minute =
        _selectedDateTime.minute.toString().padLeft(2, '0');

    final period =
        _selectedDateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String get _formattedSelectedDate {
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

    return '${_selectedDateTime.day} '
        '${months[_selectedDateTime.month - 1]} '
        '${_selectedDateTime.year}';
  }

  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime,
      ),
    );

    if (pickedTime == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Widget _buildDateTimeField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'DATE & TIME',
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => _pickDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      AppRadius.lg,
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          _formattedSelectedDate,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => _pickTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      AppRadius.lg,
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          _formattedSelectedTime,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildTransferAccountField(
    BuildContext context, {
    required String label,
    required String? selectedId,
    required void Function(String id, String name) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          label,
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedId,
          isExpanded: true,
          decoration: _inputDecoration(
            context,
            hintText: 'Select account',
          ),
          items: _accounts.map(
            (account) {
              return DropdownMenuItem(
                value: account.id,
                child: Text(account.name),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            final account = _accounts.firstWhere(
              (account) => account.id == value,
            );

            onChanged(
              account.id,
              account.name,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransferFields(BuildContext context) {
    return Column(
      children: [
        _buildTransferAccountField(
          context,
          label: 'SOURCE ACCOUNT',
          selectedId: _selectedAccountId,
          onChanged: (id, name) {
            setState(() {
              _selectedAccountId = id;
              _selectedAccount = name;
            });
          },
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: Icon(
            Icons.arrow_downward_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        _buildTransferAccountField(
          context,
          label: 'DESTINATION ACCOUNT',
          selectedId: _selectedDestinationAccountId,
          onChanged: (id, name) {
            setState(() {
              _selectedDestinationAccountId = id;
              _selectedDestinationAccount = name;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodField(BuildContext context) {
    final options = <String>{
      if (_selectedPaymentMethod != null &&
          _selectedPaymentMethod!.trim().isNotEmpty)
        _selectedPaymentMethod!,
      ..._paymentMethods,
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'PAYMENT METHOD',
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: _selectedPaymentMethod,
          isExpanded: true,
          decoration: _inputDecoration(
            context,
            hintText: 'Select payment method',
          ),
          items: options.map(
            (method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountField(BuildContext context) {
    final options = [
      if (!_accounts.any(
        (account) => account.id == _selectedAccountId,
      ))
        (
          id: _selectedAccountId,
          name: _selectedAccount,
        ),
      ..._accounts,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          widget.transaction.type == TransactionType.income
              ? 'RECEIVED INTO'
              : 'ACCOUNT',
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: _selectedAccountId,
          isExpanded: true,
          decoration: _inputDecoration(context),
          items: options.map(
            (account) {
              return DropdownMenuItem(
                value: account.id,
                child: Text(account.name),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            final account = options.firstWhere(
              (account) => account.id == value,
            );

            setState(() {
              _selectedAccountId = account.id;
              _selectedAccount = account.name;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    final categories =
        widget.transaction.type == TransactionType.income
            ? _incomeCategories
            : _expenseCategories;

    // Protect against an existing category that is not
    // inside our temporary option list.
    final options = <String>{
      _selectedCategory,
      ...categories,
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'CATEGORY',
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          isExpanded: true,
          decoration: _inputDecoration(context),
          items: options.map(
            (category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEditableDetails(BuildContext context) {
    if (widget.transaction.type == TransactionType.transfer) {
      return _buildTransferFields(context);
    }

    return Column(
      children: [
        _buildCategoryField(context),

        const SizedBox(height: AppSpacing.md),

        _buildAccountField(context),

        const SizedBox(height: AppSpacing.md),

        _buildPaymentMethodField(context),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    String? hintText,
    String? prefixText,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(
            alpha: 0.35,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String label,
  ) {
    return Text(
      label,
      style: AppTextStyles.labelCaps.copyWith(
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant,
      ),
    );
  }
  
  Widget _buildTagsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'TAGS',
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _tagsController,
          decoration: _inputDecoration(
            context,
            hintText: 'Add tags...',
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Separate tags with commas.',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'NOTES',
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _noteController,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration(
            context,
            hintText: 'Add a note...',
          ),
        ),
      ],
    );
  }

  Widget _detailDivider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Divider(
        height: 1,
        color: colors.outlineVariant.withValues(
          alpha: 0.45,
        ),
      ),
    );
  }

  Widget _buildCurrentValue(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.primary,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDetails(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        children: [
          if (widget.transaction.type !=
              TransactionType.transfer) ...[
            _buildCurrentValue(
              context,
              icon: Icons.category_outlined,
              label: 'Category',
              value: widget.transaction.category,
            ),

            _detailDivider(context),
          ],

          _buildCurrentValue(
            context,
            icon: Icons.account_balance_outlined,
            label: widget.transaction.type ==
                    TransactionType.transfer
                ? 'Source Account'
                : widget.transaction.type ==
                        TransactionType.income
                    ? 'Received Into'
                    : 'Account',
            value: widget.transaction.account,
          ),

          if (widget.transaction.type ==
              TransactionType.transfer) ...[
            _detailDivider(context),

            _buildCurrentValue(
              context,
              icon:
                  Icons.account_balance_wallet_outlined,
              label: 'Destination Account',
              value:
                  widget.transaction.destinationAccount ??
                      'Not set',
            ),
          ],

          if (widget.transaction.type !=
                  TransactionType.transfer &&
              widget.transaction.paymentMethod != null &&
              widget.transaction.paymentMethod!
                  .trim()
                  .isNotEmpty) ...[
            _detailDivider(context),

            _buildCurrentValue(
              context,
              icon: Icons.credit_card_outlined,
              label: 'Payment Method',
              value:
                  widget.transaction.paymentMethod!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    final label = switch (widget.transaction.type) {
      TransactionType.expense => 'MERCHANT / TITLE',
      TransactionType.income => 'SOURCE / TITLE',
      TransactionType.transfer => 'TRANSFER TITLE',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          label,
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _titleController,
          decoration: _inputDecoration(context),
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'AMOUNT',
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: _inputDecoration(
            context,
            prefixText: 'RM ',
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionType(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final IconData icon;
    final String label;

    switch (widget.transaction.type) {
      case TransactionType.expense:
        icon = Icons.arrow_upward_rounded;
        label = 'Expense';
        break;

      case TransactionType.income:
        icon = Icons.arrow_downward_rounded;
        label = 'Income';
        break;

      case TransactionType.transfer:
        icon = Icons.swap_horiz_rounded;
        label = 'Transfer';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          context,
          'TRANSACTION TYPE',
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: colors.primary,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
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
      ],
    );
  }
}   