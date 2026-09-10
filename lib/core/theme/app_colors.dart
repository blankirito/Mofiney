import 'package:flutter/material.dart';

abstract final class AppColors {
  // ============================================================
  // Brand
  // ============================================================

  static const Color brand = Color(0xFF0D9488);

  // ============================================================
  // Light Theme
  // ============================================================

  static const Color lightBackground = Color(0xFFF8F9FF);

  static const Color lightSurface = Color(0xFFF8F9FF);
  static const Color lightSurfaceDim = Color(0xFFCBDBF5);
  static const Color lightSurfaceBright = Color(0xFFF8F9FF);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFEFF4FF);
  static const Color lightSurfaceContainer = Color(0xFFE5EEFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color lightSurfaceContainerHighest = Color(0xFFD3E4FE);

  static const Color lightPrimary = Color(0xFF00685F);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF008378);
  static const Color lightOnPrimaryContainer = Color(0xFFF4FFFC);

  static const Color lightSecondary = Color(0xFF565E74);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFDAE2FD);
  static const Color lightOnSecondaryContainer = Color(0xFF5C647A);

  static const Color lightTertiary = Color(0xFF006947);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF00855B);
  static const Color lightOnTertiaryContainer = Color(0xFFF5FFF6);

  static const Color lightOnSurface = Color(0xFF0B1C30);
  static const Color lightOnSurfaceVariant = Color(0xFF3D4947);

  static const Color lightOutline = Color(0xFF6D7A77);
  static const Color lightOutlineVariant = Color(0xFFBCC9C6);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);

  // ============================================================
  // Dark Theme
  // ============================================================

  static const Color darkBackground = Color(0xFF0B1117);

  static const Color darkSurface = Color(0xFF111822);
  static const Color darkSurfaceDim = Color(0xFF0E141D);
  static const Color darkSurfaceBright = Color(0xFF1D2634);

  static const Color darkSurfaceContainerLowest = Color(0xFF080D13);
  static const Color darkSurfaceContainerLow = Color(0xFF151E2B);
  static const Color darkSurfaceContainer = Color(0xFF1B2533);
  static const Color darkSurfaceContainerHigh = Color(0xFF232F40);
  static const Color darkSurfaceContainerHighest = Color(0xFF2C3B4E);

  static const Color darkPrimary = Color(0xFF14B8A6);
  static const Color darkOnPrimary = Color(0xFF042F2E);
  static const Color darkPrimaryContainer = Color(0xFF0D3836);
  static const Color darkOnPrimaryContainer = Color(0xFF5EEAD4);

  static const Color darkSecondary = Color(0xFF94A3B8);
  static const Color darkOnSecondary = Color(0xFF0F172A);
  static const Color darkSecondaryContainer = Color(0xFF1E293B);
  static const Color darkOnSecondaryContainer = Color(0xFFE2E8F0);

  static const Color darkTertiary = Color(0xFF34D399);
  static const Color darkOnTertiary = Color(0xFF022C22);
  static const Color darkTertiaryContainer = Color(0xFF064E3B);
  static const Color darkOnTertiaryContainer = Color(0xFFA7F3D0);

  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  static const Color darkOutline = Color(0xFF334155);
  static const Color darkOutlineVariant = Color(0xFF1E293B);

  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF450A0A);
  static const Color darkErrorContainer = Color(0xFF451214);
  static const Color darkOnErrorContainer = Color(0xFFFCA5A5);

  // ============================================================
  // Semantic Financial Colors
  // ============================================================

  // Light
  static const Color lightIncome = Color(0xFF059669);
  static const Color lightIncomeAccent = Color(0xFF10B981);
  static const Color lightExpense = Color(0xFFE11D48);
  static const Color lightExpenseAccent = Color(0xFFEF4444);
  static const Color lightTransfer = Color(0xFF6366F1);

  // Dark
  static const Color darkIncome = Color(0xFF34D399);
  static const Color darkExpense = Color(0xFFF87171);
  static const Color darkTransfer = Color(0xFF818CF8);

  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningContainer = Color(0xFF422006);
  static const Color darkOnWarningContainer = Color(0xFFFDE68A);
}
