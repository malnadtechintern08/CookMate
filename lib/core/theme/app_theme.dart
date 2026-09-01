import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // =========================
  // COOKMATE COLORS
  // =========================
  static const Color primaryOrange = AppColors.primaryOrange;
  static const Color secondaryOrange = AppColors.secondaryOrange;
  static const Color background = AppColors.background;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color white = AppColors.white;
  static const Color gray = AppColors.gray;
  static const Color vegGreen = AppColors.vegGreen;
  static const Color nonVegRed = AppColors.nonVegRed;

  // =========================
  // DARK THEME
  // =========================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryOrange,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryOrange,
      secondary: AppColors.secondaryOrange,
      surface: AppColors.surface,
      error: AppColors.nonVegRed,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      outline: AppColors.border,
    ),
    textTheme: AppTypography.textTheme(
      AppColors.textPrimary,
      AppColors.textSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: AppColors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryOrange,
        side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryOrange,
          width: 1.8,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primaryOrange,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.18),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          );
        }
        return const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryOrange, size: 24);
        }
        return const IconThemeData(color: AppColors.textMuted, size: 24);
      }),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: AppColors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryOrange;
          }
          return Colors.transparent;
        },
      ),
      checkColor: const WidgetStatePropertyAll(
        AppColors.white,
      ),
      side: const BorderSide(color: AppColors.border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryOrange,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryOrange;
          }
          return AppColors.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textSecondary;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    ),
  );

  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primaryOrange,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryOrange,
      secondary: AppColors.secondaryOrange,
      surface: AppColors.lightSurface,
      error: AppColors.nonVegRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      outline: AppColors.lightBorder,
    ),
    textTheme: AppTypography.textTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.lightBorder,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryOrange,
        side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceCard,
      hintStyle: const TextStyle(
        color: AppColors.lightTextMuted,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: AppColors.lightTextSecondary,
      ),
      prefixIconColor: AppColors.lightTextSecondary,
      suffixIconColor: AppColors.lightTextSecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryOrange,
          width: 1.8,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurfaceCard,
      selectedItemColor: AppColors.primaryOrange,
      unselectedItemColor: AppColors.lightTextMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightSurfaceCard,
      indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.18),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          );
        }
        return const TextStyle(
          color: AppColors.lightTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryOrange, size: 24);
        }
        return const IconThemeData(color: AppColors.lightTextMuted, size: 24);
      }),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightTextPrimary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.lightSurfaceCard,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurfaceCard,
      surfaceTintColor: Colors.transparent,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryOrange;
          }
          return AppColors.lightBackground;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.lightTextSecondary;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryOrange;
          }
          return Colors.transparent;
        },
      ),
      checkColor: const WidgetStatePropertyAll(
        Colors.white,
      ),
      side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryOrange,
    ),
  );
}
