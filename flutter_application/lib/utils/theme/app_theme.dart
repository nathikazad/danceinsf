import 'package:flutter/material.dart';
import 'package:flutter_application/utils/theme/app_color.dart';
import 'package:flutter_application/utils/theme/app_text_styles.dart';

class AppTheme {
  /// light mode
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightOnPrimary,
      colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          primaryContainer: AppColors.lightBackground,
          secondary: AppColors.lightSecondary,
          onSecondary: AppColors.lightOnSecondary,
          tertiary: AppColors.lightTertiary,
          onTertiary: AppColors.lightonTertiary,
          secondaryContainer: AppColors.lightSecondaryVariant,
          surface: AppColors.lightSurface,
          error: AppColors.lightError,
          onPrimary: AppColors.lightOnPrimary,
          onError: AppColors.lightError),
      cardTheme: CardTheme(
          elevation: 0,
          color: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          )),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.lightSurface,
        hourMinuteColor: AppColors.lightSecondaryVariant.withOpacity(0.2),
        hourMinuteTextColor: AppColors.lightOnSecondary,
        dayPeriodColor: AppColors.lightSecondaryVariant.withOpacity(0.2),
        dayPeriodTextColor: AppColors.lightOnSecondary,
        dialHandColor: AppColors.lightPrimary,
        dialBackgroundColor: AppColors.lightSecondaryVariant.withOpacity(0.12),
        dialTextColor: AppColors.lightOnSecondary,
        entryModeIconColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.lightSecondary),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.lightOnSecondary),
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      dividerTheme: DividerThemeData(
          color: AppColors.lightOnSecondaryContainer, thickness: 0.5),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          backgroundColor: AppColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightPrimary, // Light theme icon color
        size: 24,
      ),
    );
  }

  /// dark mode
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkOnPrimary,
      colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          primaryContainer: AppColors.darkBackground,
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.darkOnSecondary,
          secondaryContainer: AppColors.darkSecondaryVariant,
          surface: AppColors.darkSurface,
          error: AppColors.darkError,
          tertiary: AppColors.darkTertiary,
          onTertiary: AppColors.darkonTertiary,
          onPrimary: AppColors.darkOnPrimary,
          onError: AppColors.darkError),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.darkSecondary),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.darkOnSecondary),
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.darkSurface,
        hourMinuteColor: AppColors.darkSecondaryVariant.withOpacity(0.2),
        hourMinuteTextColor: Colors.white,
        dayPeriodColor: AppColors.darkSecondaryVariant.withOpacity(0.2),
        dayPeriodTextColor: Colors.white,
        dialHandColor: AppColors.lightPrimary, // Your orange color
        dialBackgroundColor: AppColors.darkSecondaryVariant.withOpacity(0.12),
        dialTextColor: Colors.white,
        entryModeIconColor: AppColors.darkPrimary, // Your orange color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      cardTheme: CardTheme(
          elevation: 0,
          color: Color.fromRGBO(33, 22, 25, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          )),
      dividerTheme: DividerThemeData(
          color: AppColors.darkOnSecondaryContainer, thickness: 0.5),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          backgroundColor: AppColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkPrimary, // Light theme icon color
        size: 24,
      ),
    );
  }
}
