import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    this.showNotification = false,
    this.onNotificationPressed,
  });

  final bool showNotification;
  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(
            'M',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Mofiney',
          style: AppTextStyles.headlineMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (showNotification)
          IconButton(
            onPressed: onNotificationPressed,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
