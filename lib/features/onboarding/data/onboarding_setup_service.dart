import '../../accounts/data/account_repository.dart';
import '../../accounts/domain/account.dart';
import '../../profile/data/app_settings_repository.dart';
import '../domain/onboarding_data.dart';
import 'onboarding_preferences.dart';

class OnboardingSetupService {
  OnboardingSetupService({
    required AppSettingsRepository appSettingsRepository,
    required AccountRepository accountRepository,
    required OnboardingPreferences onboardingPreferences,
  }) : _appSettingsRepository = appSettingsRepository,
       _accountRepository = accountRepository,
       _onboardingPreferences = onboardingPreferences;

  final AppSettingsRepository _appSettingsRepository;
  final AccountRepository _accountRepository;
  final OnboardingPreferences _onboardingPreferences;

  Future<void> complete(OnboardingData data) async {
    // This only changes display conversion. All V1 financial records stay MYR.
    await _appSettingsRepository.updateBaseCurrency(data.currencyCode);

    // A skipped budget is stored as 0, meaning “not set”.
    await _appSettingsRepository.updateMonthlyBudget(data.monthlyBudget ?? 0);

    final accountName = data.accountName?.trim();

    if (accountName != null && accountName.isNotEmpty) {
      final existingAccounts = await _accountRepository.getAllAccounts();

      if (existingAccounts.isEmpty) {
        await _accountRepository.insertAccount(
          Account(
            id: 'onboarding_${DateTime.now().microsecondsSinceEpoch}',
            name: accountName,
            type: _accountTypeFromOnboarding(data.accountType),
            openingBalance: data.openingBalance ?? 0,
            currencyCode: 'MYR',
            isPrimary: true,
          ),
        );
      }
    }

    await _onboardingPreferences.markCompleted();
  }

  AccountType _accountTypeFromOnboarding(String? value) {
    return switch (value) {
      'Cash' => AccountType.cash,
      'E-Wallet' => AccountType.eWallet,
      _ => AccountType.bank,
    };
  }
}
