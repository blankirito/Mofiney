import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class OnboardingStepper extends StatelessWidget {
  const OnboardingStepper({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const List<String> _steps = [
    'Currency',
    'Budget',
    'Account',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stepWidth = constraints.maxWidth / _steps.length;

        return Stack(
          children: [
            // Base connector line
            Positioned(
              top: 15,
              left: stepWidth / 2,
              right: stepWidth / 2,
              child: Container(
                height: 2,
                color: colors.outlineVariant,
              ),
            ),

            // Completed connector line
            if (currentStep > 1)
              Positioned(
                top: 15,
                left: stepWidth / 2,
                width:
                    stepWidth * (currentStep - 1),
                child: Container(
                  height: 2,
                  color: colors.primary,
                ),
              ),

            // Step circles + labels
            Row(
              children: List.generate(
                _steps.length,
                (index) {
                  final stepNumber = index + 1;
                  final isCompleted =
                    stepNumber < currentStep ||
                    currentStep == _steps.length;
                  final isCurrent =
                      stepNumber == currentStep;

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? colors.primary
                                : colors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: isCompleted || isCurrent
                                ? null
                                : Border.all(
                                    color:
                                        colors.outlineVariant,
                                    width: 2,
                                  ),
                          ),
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  color: colors.onPrimary,
                                  size: 17,
                                )
                              : Text(
                                  '$stepNumber',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(
                                    color: isCurrent
                                        ? colors.onPrimary
                                        : colors
                                            .onSurfaceVariant,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          _steps[index].toUpperCase(),
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.labelCaps.copyWith(
                            color: stepNumber <= currentStep
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}