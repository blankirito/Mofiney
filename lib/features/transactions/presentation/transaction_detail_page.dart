import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import 'edit_transaction_page.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/currency/currency_catalog.dart';
import '../../../core/currency/currency_converter.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.repository,
  });

  final Transaction transaction;
  final TransactionRepository repository;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Transaction _transaction;
  String _baseCurrency = 'MYR';
  CurrencyConverter _converter = CurrencyConverter('MYR');
  String _nativeCurrency = 'MYR';

  Transaction get transaction => _transaction;

  @override
  void initState() {
    super.initState();

    _transaction = widget.transaction;
    _loadPresentationCurrency();
  }

  Future<void> _loadPresentationCurrency() async {
    final settings = await appSettingsRepository.getSettings();
    final account = await accountRepository.getAccountById(
      transaction.accountId,
    );
    final base = settings?.baseCurrency ?? 'MYR';
    final native = account?.currencyCode ?? 'MYR';
    final converter = CurrencyConverter(base);
    await converter.warm([native]);
    if (mounted)
      setState(() {
        _baseCurrency = base;
        _nativeCurrency = native;
        _converter = converter;
      });
  }

  String get _symbol => CurrencyCatalog.find(_baseCurrency).symbol;
  double get _displayAmount =>
      _converter.convert(transaction.amount, _nativeCurrency);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
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
              _buildHeroCard(context),

              const SizedBox(height: AppSpacing.md),

              _buildTransactionDetails(context),

              if (_hasAdditionalInformation) ...[
                const SizedBox(height: AppSpacing.md),

                _buildAdditionalInformation(context),
              ],

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final updatedTransaction =
                        await Navigator.push<Transaction>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTransactionPage(transaction: transaction),
                          ),
                        );

                    if (updatedTransaction == null || !mounted) {
                      return;
                    }

                    setState(() {
                      _transaction = updatedTransaction;
                    });
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Transaction'),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete Transaction'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final colors = Theme.of(context).colorScheme;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.delete_outline_rounded, color: colors.error),
          title: const Text('Delete Transaction?'),
          content: Text(
            'Are you sure you want to delete '
            '"${transaction.title}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await widget.repository.deleteTransaction(transaction.id);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $error')),
      );
    }
  }

  Future<void> _showReceiptPreview() async {
    final receiptPath = transaction.receiptPath;

    if (receiptPath == null) {
      return;
    }

    final receiptFile = File(receiptPath);

    if (!await receiptFile.exists()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt image could not be found.')),
      );

      return;
    }

    if (!mounted) {
      return;
    }

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
                  child: Image.file(receiptFile, fit: BoxFit.contain),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final receiptFile = File(transaction.receiptPath!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECEIPT',
          style: AppTextStyles.labelCaps.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 9,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: _showReceiptPreview,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    receiptFile,
                    width: 48,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        width: 48,
                        height: 56,
                        color: colors.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt attached',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Tap to view or zoom',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.open_in_full_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS',
          style: AppTextStyles.labelCaps.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 9,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: transaction.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '#$tag',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.sticky_note_2_outlined,
            size: 20,
            color: colors.primary,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOTES',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                transaction.note!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInformation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasNote =
        transaction.note != null && transaction.note!.trim().isNotEmpty;

    final hasTags = transaction.tags.isNotEmpty;

    final hasReceipt =
        transaction.receiptPath != null &&
        transaction.receiptPath!.trim().isNotEmpty;

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
          Text(
            'ADDITIONAL INFORMATION',
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          if (hasNote) ...[
            const SizedBox(height: AppSpacing.md),

            _buildNoteSection(context),
          ],

          if (hasTags) ...[
            const SizedBox(height: AppSpacing.md),

            _buildTagsSection(context),
          ],

          if (hasReceipt) ...[
            const SizedBox(height: AppSpacing.md),

            _buildReceiptSection(context),
          ],
        ],
      ),
    );
  }

  bool get _hasAdditionalInformation {
    final hasNote =
        transaction.note != null && transaction.note!.trim().isNotEmpty;

    final hasTags = transaction.tags.isNotEmpty;

    final hasReceipt =
        transaction.receiptPath != null &&
        transaction.receiptPath!.trim().isNotEmpty;

    return hasNote || hasTags || hasReceipt;
  }

  Widget _buildDetailDivider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(
        height: 1,
        color: colors.outlineVariant.withValues(alpha: 0.45),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),

        const SizedBox(width: AppSpacing.sm),

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

  Widget _buildTransferDetails(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildDetailRow(
          context,
          icon: Icons.account_balance_outlined,
          label: 'Source Account',
          value: transaction.account,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: colors.primary,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '$_symbol ${_displayAmount.abs().toStringAsFixed(2)} · native $_nativeCurrency',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Divider(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        _buildDetailRow(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Destination Account',
          value: transaction.destinationAccount ?? 'Unknown',
        ),
      ],
    );
  }

  Widget _buildStandardDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          icon: Icons.category_outlined,
          label: 'Category',
          value: transaction.category,
        ),

        _buildDetailDivider(context),

        _buildDetailRow(
          context,
          icon: transaction.type == TransactionType.income
              ? Icons.account_balance_wallet_outlined
              : Icons.account_balance_outlined,
          label: transaction.type == TransactionType.income
              ? 'Received Into'
              : 'Account',
          value: transaction.account,
        ),

        if (transaction.paymentMethod != null &&
            transaction.paymentMethod!.trim().isNotEmpty) ...[
          _buildDetailDivider(context),

          _buildDetailRow(
            context,
            icon: Icons.credit_card_outlined,
            label: 'Payment Method',
            value: transaction.paymentMethod!,
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
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
          Text(
            'TRANSACTION DETAILS',
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          if (transaction.type == TransactionType.transfer)
            _buildTransferDetails(context)
          else
            _buildStandardDetails(context),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final Color accentColor;
    final Color iconBackground;
    final IconData icon;

    switch (transaction.type) {
      case TransactionType.expense:
        accentColor = colors.error;
        iconBackground = colors.errorContainer.withValues(alpha: 0.55);
        icon = Icons.shopping_bag_outlined;
        break;

      case TransactionType.income:
        accentColor = colors.tertiary;
        iconBackground = colors.tertiaryContainer.withValues(alpha: 0.55);
        icon = Icons.payments_outlined;
        break;

      case TransactionType.transfer:
        accentColor = colors.primary;
        iconBackground = colors.primaryContainer;
        icon = Icons.swap_horiz_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: accentColor),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            transaction.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _formattedAmount,
            style: AppTextStyles.displayHeroMobile.copyWith(color: accentColor),
          ),

          const SizedBox(height: AppSpacing.sm),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _typeLabel,
              style: AppTextStyles.labelCaps.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            _formattedDateTime,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String get _formattedAmount {
    final amount = _displayAmount.abs().toStringAsFixed(2);

    switch (transaction.type) {
      case TransactionType.expense:
        return '− $_symbol $amount';

      case TransactionType.income:
        return '+ $_symbol $amount';

      case TransactionType.transfer:
        return '$_symbol $amount';
    }
  }

  String get _typeLabel {
    switch (transaction.type) {
      case TransactionType.expense:
        return 'EXPENSE';

      case TransactionType.income:
        return 'INCOME';

      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  String get _formattedDateTime {
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

    final date = transaction.dateTime;

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year}'
        ' · $hour:$minute $period';
  }
}
