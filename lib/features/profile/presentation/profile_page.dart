import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../accounts/presentation/accounts_page.dart';
import 'profile_details_page.dart';
import 'monthly_target_budget_page.dart';
import 'manage_categories_page.dart';
import 'recurring_transactions_page.dart';
import 'appearance_page.dart';
import 'backup_restore_page.dart';
import 'export_financial_data_page.dart';
import 'base_currency_page.dart';
import 'set_app_lock_pin_page.dart';

import '../../../core/app_dependencies.dart';

import 'dart:async';

import '../../accounts/domain/account.dart';
import '../../../core/database/app_database.dart';
import '../../../core/currency/currency_catalog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _appLockEnabled = false;
  bool _isDeviceAuthenticationAvailable = false;
  bool _isDeviceAuthenticationEnabled = false;

  List<Account> _accounts = [];

  StreamSubscription<List<Account>>? _accountsSubscription;

  AppSettingsEntry? _settings;

  StreamSubscription<AppSettingsEntry?>? _settingsSubscription;

  @override
  void initState() {
    super.initState();

    _watchAccounts();
    _watchSettings();
    _loadAppLockStatus();
    _loadDeviceAuthenticationState();
  }

  Future<void> _loadAppLockStatus() async {
    final isEnabled = await appLockService.isLockEnabled();

    if (!mounted) return;

    setState(() {
      _appLockEnabled = isEnabled;
    });
  }

  Future<void> _loadDeviceAuthenticationState() async {
    final isAvailable = await appLockService.canUseDeviceAuthentication();
    final isEnabled = await appLockService.isDeviceAuthenticationEnabled();

    if (!mounted) return;

    setState(() {
      _isDeviceAuthenticationAvailable = isAvailable;
      _isDeviceAuthenticationEnabled = isEnabled;
    });
  }

  Future<void> _handleDeviceAuthenticationChanged(bool enabled) async {
    if (enabled && !_isDeviceAuthenticationAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Device authentication is not available on this device.',
          ),
        ),
      );
      return;
    }

    await appLockService.setDeviceAuthenticationEnabled(enabled);

    if (!mounted) return;

    setState(() {
      _isDeviceAuthenticationEnabled = enabled;
    });
  }

  Future<void> _handleAppLockChanged(bool enabled) async {
    if (enabled) {
      final didEnable = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const SetAppLockPinPage()),
      );

      if (!mounted) return;

      setState(() {
        _appLockEnabled = didEnable == true;
      });

      if (didEnable == true) {
        await _loadDeviceAuthenticationState();
      }

      return;
    }

    final shouldDisable = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Turn off App Lock?'),
          content: const Text(
            'This will remove your saved PIN and device authentication setting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Turn Off'),
            ),
          ],
        );
      },
    );

    if (shouldDisable != true) return;

    await appLockService.disableAndClear();

    if (!mounted) return;

    setState(() {
      _appLockEnabled = false;
      _isDeviceAuthenticationEnabled = false;
    });
  }

  void _watchSettings() {
    _settingsSubscription?.cancel();

    _settingsSubscription = appSettingsRepository.watchSettings().listen(
      (settings) {
        if (!mounted) {
          return;
        }

        setState(() {
          _settings = settings;
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch profile settings: $error');
      },
    );
  }

  void _watchAccounts() {
    _accountsSubscription?.cancel();

    _accountsSubscription = accountRepository.watchAllAccounts().listen(
      (accounts) {
        if (!mounted) {
          return;
        }

        setState(() {
          _accounts = accounts;
        });
      },
      onError: (Object error) {
        debugPrint('Failed to watch profile accounts: $error');
      },
    );
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    _settingsSubscription?.cancel();

    super.dispose();
  }

  int get _activeAccountCount {
    return _accounts.where((account) => account.isActive).length;
  }

  double get _monthlyBudget {
    return _settings?.monthlyBudget ?? 0;
  }

  String get _monthlyBudgetLabel {
    return '$_currencySymbol ${_monthlyBudget.toStringAsFixed(2)}';
  }

  String get _currencySymbol {
    return CurrencyCatalog.find(_baseCurrency).symbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: AppSpacing.md),

              _buildProfileCard(context),

              const SizedBox(height: AppSpacing.lg),

              _buildSection(
                context,
                title: 'FINANCE SETTINGS',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'Base Currency',
                    subtitle: _baseCurrency,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BaseCurrencyPage(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _buildSettingTile(
                    context,
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'Monthly Target Budget',
                    subtitle: _monthlyBudgetLabel,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MonthlyTargetBudgetPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildSection(
                context,
                title: 'MANAGEMENT',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Manage Categories',
                    subtitle: 'Expense & income categories',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageCategoriesPage(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _buildSettingTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Manage Accounts',
                    subtitle: 'Manage your financial accounts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountsPage(
                            repository: accountRepository,
                            transactionRepository: transactionRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _buildSettingTile(
                    context,
                    icon: Icons.update_rounded,
                    title: 'Recurring Transactions',
                    subtitle: 'Scheduled recurring records',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecurringTransactionsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildSection(
                context,
                title: 'PREFERENCES',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'System default',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppearancePage(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _buildSwitchTile(
                    context,
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Reminders & alerts',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildSection(
                context,
                title: 'DATA & STORAGE',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.backup_outlined,
                    title: 'Backup & Restore',
                    subtitle: 'Manage your local data backup',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BackupRestorePage(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _buildSettingTile(
                    context,
                    icon: Icons.file_download_outlined,
                    title: 'Export Financial Data',
                    subtitle: 'CSV & PDF reports',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExportFinancialDataPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildSection(
                context,
                title: 'SECURITY',
                children: [
                  _buildSettingTile(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: '••••••••',
                  ),
                  _divider(context),
                  _buildSwitchTile(
                    context,
                    icon: Icons.fingerprint_rounded,
                    title: 'App Lock',
                    subtitle: 'Biometric / PIN',
                    value: _appLockEnabled,
                    onChanged: _handleAppLockChanged,
                  ),
                  if (_appLockEnabled) ...[
                    _divider(context),
                    _buildSwitchTile(
                      context,
                      icon: Icons.fingerprint_rounded,
                      title: 'Use Device Authentication',
                      subtitle: 'Fingerprint, Face ID, or Windows Hello',
                      value: _isDeviceAuthenticationEnabled,
                      onChanged: _handleDeviceAuthenticationChanged,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Authentication will be connected later.',
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .errorContainer,
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onErrorContainer,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _baseCurrency {
    return _settings?.baseCurrency ?? 'MYR';
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Profile',
          style: AppTextStyles.headlineLargeMobile.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),

        const Spacer(),

        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileDetailsPage()),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'U',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mofiney User',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Local profile',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
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

            const SizedBox(height: AppSpacing.md),

            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _buildProfilePill(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: _activeAccountCount == 1
                      ? '1 Account'
                      : '$_activeAccountCount Accounts',
                ),
                _buildProfilePill(
                  context,
                  icon: Icons.payments_outlined,
                  label: '$_baseCurrency Currency',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTextStyles.labelCaps.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title will be implemented later.')),
            );
          },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
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
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
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
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant
            .withValues(alpha: 0.4),
      ),
    );
  }
}
