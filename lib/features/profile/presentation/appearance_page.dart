import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() =>
      _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: SafeArea(
        top: false,
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
              Text(
                'THEME',
                style: AppTextStyles.labelCaps.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              _AppearanceOption(
                icon: Icons.settings_brightness_rounded,
                title: 'System Default',
                subtitle: 'Follow your device appearance',
                selected:
                    themeModeNotifier.value == ThemeMode.system,
                onTap: () {
                  setState(() {
                    themeModeNotifier.value = ThemeMode.system;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              _AppearanceOption(
                icon: Icons.light_mode_outlined,
                title: 'Light',
                subtitle: 'Always use light mode',
                selected:
                    themeModeNotifier.value == ThemeMode.light,
                onTap: () {
                  setState(() {
                    themeModeNotifier.value = ThemeMode.light;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              _AppearanceOption(
                icon: Icons.dark_mode_outlined,
                title: 'Dark',
                subtitle: 'Always use dark mode',
                selected:
                    themeModeNotifier.value == ThemeMode.dark,
                onTap: () {
                  setState(() {
                    themeModeNotifier.value = ThemeMode.dark;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppRadius.xl,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer.withValues(
                  alpha: 0.35,
                )
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(
            AppRadius.xl,
          ),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? colors.primaryContainer
                    : colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
              child: Icon(
                icon,
                color: selected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style:
                        AppTextStyles.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}