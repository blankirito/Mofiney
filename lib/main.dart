import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_preferences.dart';
import 'features/welcome/presentation/welcome_page.dart';

import 'features/accounts/data/mock_accounts.dart';
import 'features/transactions/data/mock_transactions.dart';
import 'features/categories/data/default_categories.dart';
import 'features/profile/presentation/app_lock_gate.dart';

import 'core/app_dependencies.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
final themePreferences = ThemePreferences();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  themeModeNotifier.value = await themePreferences.loadThemeMode();

  await accountRepository.seedAccountsIfEmpty(mockAccounts);

  await transactionRepository.seedTransactionsIfEmpty(mockTransactions);

  await appSettingsRepository.ensureSettingsExist();

  await categoryRepository.seedCategoriesIfEmpty(defaultCategories);

  await recurringScheduleRepository.processDueSchedules();

  runApp(const MofineyApp());
}

class MofineyApp extends StatelessWidget {
  const MofineyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mofiney',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: const AppLockGate(child: WelcomePage()),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Center(child: Text('Home')),
    Center(child: Text('Transactions')),
    Center(child: Text('Accounts')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
