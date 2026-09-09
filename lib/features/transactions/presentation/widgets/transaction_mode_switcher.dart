import 'package:flutter/material.dart';

enum TransactionMode {
  expense,
  income,
  transfer,
  scan,
}

class TransactionModeSwitcher extends StatelessWidget {
  final TransactionMode selectedMode;
  final ValueChanged<TransactionMode> onModeChanged;

  const TransactionModeSwitcher({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildItem(
            context,
            mode: TransactionMode.expense,
            label: 'Expense',
            icon: Icons.remove_rounded,
          ),
          _buildItem(
            context,
            mode: TransactionMode.income,
            label: 'Income',
            icon: Icons.add_rounded,
          ),
          _buildItem(
            context,
            mode: TransactionMode.transfer,
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
          ),
          _buildItem(
            context,
            mode: TransactionMode.scan,
            label: 'Scan',
            icon: Icons.document_scanner_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required TransactionMode mode,
    required String label,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = selectedMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}