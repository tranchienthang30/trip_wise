import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class TripwiseTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: TripwiseColors.primary,
        onPrimary: TripwiseColors.onPrimary,
        primaryContainer: TripwiseColors.primaryContainer,
        onPrimaryContainer: TripwiseColors.onPrimaryContainer,
        secondary: TripwiseColors.secondary,
        onSecondary: TripwiseColors.onSecondary,
        secondaryContainer: TripwiseColors.secondaryContainer,
        onSecondaryContainer: TripwiseColors.onSecondaryContainer,
        tertiary: TripwiseColors.tertiary,
        onTertiary: TripwiseColors.onTertiary,
        tertiaryContainer: TripwiseColors.tertiaryContainer,
        onTertiaryContainer: TripwiseColors.onTertiaryContainer,
        error: TripwiseColors.error,
        onError: TripwiseColors.onError,
        errorContainer: TripwiseColors.errorContainer,
        onErrorContainer: TripwiseColors.onErrorContainer,
        surface: TripwiseColors.surface,
        onSurface: TripwiseColors.onSurface,
        surfaceContainerHighest: TripwiseColors.surfaceContainerHighest,
        outline: TripwiseColors.outline,
        outlineVariant: TripwiseColors.outlineVariant,
      ),
      scaffoldBackgroundColor: TripwiseColors.background,
      fontFamily: 'Inter',
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: TripwiseColors.surface,
        foregroundColor: TripwiseColors.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: TripwiseColors.surface,
        selectedItemColor: TripwiseColors.primary,
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: TripwiseColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
          color: TripwiseColors.onSurfaceVariant,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: TripwiseButtonStyles.primaryElevated(
          minimumSize: const Size(0, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: TripwiseButtonStyles.outlined(
          minimumSize: const Size(0, 52),
          borderColor: TripwiseColors.outline,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TripwiseButtonStyles.text(
          minimumSize: const Size(0, 40),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TripwiseColors.primary,
          foregroundColor: TripwiseColors.onPrimary,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TripwiseColors.primary,
        foregroundColor: TripwiseColors.onPrimary,
        elevation: 6,
        highlightElevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TripwiseColors.onPrimary;
          }

          return TripwiseColors.surfaceContainerLowest;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TripwiseColors.primary;
          }

          return TripwiseColors.surfaceContainerHigh;
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TripwiseColors.primary;
          }

          return TripwiseColors.outlineVariant;
        }),
      ),
    );
  }

  static TextTheme _textTheme() {
    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: TripwiseColors.onSurface,
        letterSpacing: -1.5,
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: TripwiseColors.onSurface,
        letterSpacing: -0.5,
      ),
      displaySmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: TripwiseColors.onSurface,
      ),
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: TripwiseColors.onSurface,
        letterSpacing: -1.5,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: TripwiseColors.onSurface,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: TripwiseColors.onSurface,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: TripwiseColors.onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: TripwiseColors.onSurface,
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: TripwiseColors.onSurface,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TripwiseColors.onSurface,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TripwiseColors.onSurface,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TripwiseColors.onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TripwiseColors.onSurface,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: TripwiseColors.onSurface,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: TripwiseColors.onSurface,
      ),
    );
  }
}
