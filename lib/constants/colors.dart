import 'package:flutter/material.dart';

class TripwiseColors {
  // Primary Colors
  static const Color primary = Color(0xFF005f9f);
  static const Color primaryContainer = Color(0xFF0078c7);
  static const Color primaryFixed = Color(0xFFd1e4ff);
  static const Color primaryFixedDim = Color(0xFF9dcaff);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color onPrimaryContainer = Color(0xFFfdfcff);
  static const Color onPrimaryFixed = Color(0xFF001d36);
  static const Color onPrimaryFixedVariant = Color(0xFF00497c);
  static const Color inversePrimary = Color(0xFF9dcaff);

  // Secondary Colors
  static const Color secondary = Color(0xFFab3500);
  static const Color secondaryContainer = Color(0xFFff5e1f);
  static const Color secondaryFixed = Color(0xFFffdbd0);
  static const Color secondaryFixedDim = Color(0xFFffb59d);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color onSecondaryContainer = Color(0xFF551600);
  static const Color onSecondaryFixed = Color(0xFF390c00);
  static const Color onSecondaryFixedVariant = Color(0xFF832600);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF005f9d);
  static const Color tertiaryContainer = Color(0xFF0b79c3);
  static const Color tertiaryFixed = Color(0xFFd0e4ff);
  static const Color tertiaryFixedDim = Color(0xFF9ccaff);
  static const Color onTertiary = Color(0xFFffffff);
  static const Color onTertiaryContainer = Color(0xFFfdfcff);
  static const Color onTertiaryFixed = Color(0xFF001d35);
  static const Color onTertiaryFixedVariant = Color(0xFF00497a);

  // Error Colors
  static const Color error = Color(0xFFba1a1a);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onError = Color(0xFFffffff);
  static const Color onErrorContainer = Color(0xFF93000a);

  // Neutral Colors
  static const Color background = Color(0xFFf8f9ff);
  static const Color surface = Color(0xFFf8f9ff);
  static const Color surfaceDim = Color(0xFFd7dae2);
  static const Color surfaceBright = Color(0xFFf8f9ff);
  static const Color surfaceContainer = Color(0xFFebeef6);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerLow = Color(0xFFf0f4fc);
  static const Color surfaceContainerHigh = Color(0xFFe5e8f0);
  static const Color surfaceContainerHighest = Color(0xFFdfe2eb);
  static const Color surfaceTint = Color(0xFF0061a3);
  static const Color onSurface = Color(0xFF181c22);
  static const Color onSurfaceVariant = Color(0xFF3f4752);
  static const Color surfaceVariant = Color(0xFFdfe2eb);
  static const Color inverseSurface = Color(0xFF2c3137);
  static const Color inverseOnSurface = Color(0xffedf1f9);

  // Outline Colors
  static const Color outline = Color(0xFF707884);
  static const Color outlineVariant = Color(0xFFbfc7d4);

  // On Background
  static const Color onBackground = Color(0xFF181c22);
}

class TripwiseButtonStyles {
  static const EdgeInsets _defaultPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  static ButtonStyle primaryElevated({
    double radius = 16,
    EdgeInsetsGeometry padding = _defaultPadding,
    Size? minimumSize,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
    double elevation = 4,
    Color? shadowColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: TripwiseColors.primary,
      foregroundColor: TripwiseColors.onPrimary,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: shadowColor ?? TripwiseColors.primary.withOpacity(0.24),
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static ButtonStyle accentElevated({
    double radius = 16,
    EdgeInsetsGeometry padding = _defaultPadding,
    Size? minimumSize,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
    double elevation = 4,
    Color? shadowColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: TripwiseColors.secondaryContainer,
      foregroundColor: TripwiseColors.onSecondary,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor:
          shadowColor ?? TripwiseColors.secondaryContainer.withOpacity(0.28),
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static ButtonStyle surfaceElevated({
    double radius = 16,
    EdgeInsetsGeometry padding = _defaultPadding,
    Size? minimumSize,
    Color backgroundColor = TripwiseColors.surfaceContainerLowest,
    Color foregroundColor = TripwiseColors.primary,
    BorderSide? side,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
    double elevation = 2,
    Color? shadowColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor ?? Colors.black.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      side: side,
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static ButtonStyle outlined({
    double radius = 16,
    EdgeInsetsGeometry padding = _defaultPadding,
    Size? minimumSize,
    Color foregroundColor = TripwiseColors.primary,
    Color borderColor = TripwiseColors.outlineVariant,
    Color? backgroundColor,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      side: BorderSide(color: borderColor),
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static ButtonStyle destructiveOutlined({
    double radius = 16,
    EdgeInsetsGeometry padding = _defaultPadding,
    Size? minimumSize,
  }) {
    return outlined(
      radius: radius,
      padding: padding,
      minimumSize: minimumSize,
      foregroundColor: TripwiseColors.error,
      borderColor: TripwiseColors.error,
    );
  }

  static ButtonStyle text({
    double radius = 12,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    Size? minimumSize,
    Color foregroundColor = TripwiseColors.primary,
    Color? backgroundColor,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static ButtonStyle overlayFilled({
    double radius = 999,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 10,
    ),
    Size? minimumSize,
    Color backgroundColor = Colors.white,
    required Color foregroundColor,
    TextStyle? textStyle,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      tapTargetSize: tapTargetSize,
      textStyle: textStyle,
      padding: padding,
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
