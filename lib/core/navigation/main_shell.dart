import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/transactions/presentation/transactions_page.dart';
import '../../features/transactions/presentation/quick_add_sheet.dart';
import '../../features/transactions/presentation/add_expense_page.dart';
import '../../features/transactions/presentation/add_income_page.dart';
import '../../features/transactions/presentation/transfer_page.dart';
import '../../features/transactions/presentation/scan_receipt_page.dart';
import '../../features/accounts/presentation/accounts_page.dart';
import '../../features/profile/presentation/profile_page.dart';

import '../app_dependencies.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TransactionsPage(repository: transactionRepository),
    AccountsPage(
      repository: accountRepository,
      transactionRepository: transactionRepository,
    ),
    ProfilePage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showQuickAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return QuickAddSheet(
          onAddExpense: () {
            Navigator.pop(sheetContext);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AddExpensePage(repository: transactionRepository),
              ),
            );
          },
          onAddIncome: () {
            Navigator.pop(sheetContext);

            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddIncomePage()));
          },
          onTransfer: () {
            Navigator.pop(sheetContext);

            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddTransferPage()));
          },
          onScanReceipt: () {
            Navigator.pop(sheetContext);

            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScanReceiptPage()));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: _currentIndex == 0,
                  onTap: () => _onDestinationSelected(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: 'Transactions',
                  selected: _currentIndex == 1,
                  onTap: () => _onDestinationSelected(1),
                ),
              ),

              Expanded(child: _AddNavItem(onTap: _showQuickAddSheet)),

              Expanded(
                child: _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: 'Accounts',
                  selected: _currentIndex == 2,
                  onTap: () => _onDestinationSelected(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _currentIndex == 3,
                  onTap: () => _onDestinationSelected(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text(title))),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              size: 24,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNavItem extends StatelessWidget {
  const _AddNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -18,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
