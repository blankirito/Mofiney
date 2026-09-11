import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_preferences.dart';
import 'features/welcome/presentation/welcome_page.dart';

import 'features/categories/data/default_categories.dart';
import 'features/profile/presentation/app_lock_gate.dart';

import 'core/navigation/main_shell.dart';
import 'features/onboarding/data/onboarding_preferences.dart';

import 'core/app_dependencies.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
final themePreferences = ThemePreferences();
final onboardingPreferences = OnboardingPreferences();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  themeModeNotifier.value = await themePreferences.loadThemeMode();

  await appSettingsRepository.ensureSettingsExist();

  await categoryRepository.seedCategoriesIfEmpty(defaultCategories);

  await recurringScheduleRepository.processDueSchedules();

  var hasCompletedOnboarding = await onboardingPreferences.isCompleted();

  final hasExistingAccounts =
      (await accountRepository.getAllAccounts()).isNotEmpty;

  if (!hasCompletedOnboarding && hasExistingAccounts) {
    await onboardingPreferences.markCompleted();
    hasCompletedOnboarding = true;
  }

  runApp(MofineyApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class MofineyApp extends StatelessWidget {
  const MofineyApp({super.key, required this.hasCompletedOnboarding});

  final bool hasCompletedOnboarding;

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
          home: AppLockGate(
            child: hasCompletedOnboarding
                ? const MainShell()
                : const WelcomePage(),
          ),
        );
      },
    );
  }
}
