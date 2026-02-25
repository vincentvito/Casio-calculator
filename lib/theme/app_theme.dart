import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_palette.dart';
import 'neumorphic_theme.dart';

/// Main app theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme for Flutter MaterialApp
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightPalette.background,
      colorScheme: const ColorScheme.light(
        primary: LightPalette.accent,
        secondary: LightPalette.accentLight,
        surface: LightPalette.surface,
        error: LightPalette.error,
        onPrimary: LightPalette.textOnAccent,
        onSecondary: LightPalette.textPrimary,
        onSurface: LightPalette.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LightPalette.background,
        foregroundColor: LightPalette.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: LightPalette.textPrimary),
        bodyMedium: TextStyle(color: LightPalette.textPrimary),
        bodySmall: TextStyle(color: LightPalette.textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: LightPalette.textPrimary,
      ),
    );
  }

  /// Dark theme for Flutter MaterialApp
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkPalette.background,
      colorScheme: const ColorScheme.dark(
        primary: DarkPalette.accent,
        secondary: DarkPalette.accentLight,
        surface: DarkPalette.surface,
        error: DarkPalette.error,
        onPrimary: DarkPalette.textOnAccent,
        onSecondary: DarkPalette.textPrimary,
        onSurface: DarkPalette.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkPalette.background,
        foregroundColor: DarkPalette.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: DarkPalette.textPrimary),
        bodyMedium: TextStyle(color: DarkPalette.textPrimary),
        bodySmall: TextStyle(color: DarkPalette.textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: DarkPalette.textPrimary,
      ),
    );
  }

  /// Get neumorphic theme based on brightness
  static NeumorphicThemeData getNeumorphicTheme(Brightness brightness) {
    return brightness == Brightness.light
        ? NeumorphicThemeData.light()
        : NeumorphicThemeData.dark();
  }
}
