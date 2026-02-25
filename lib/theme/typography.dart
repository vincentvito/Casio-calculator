import 'package:flutter/material.dart';

/// Calculator typography styles
/// Uses monospace fonts for display alignment and geometric sans for UI
abstract class AppTypography {
  // Font families
  static const String displayFontFamily = 'JetBrains Mono';
  static const String uiFontFamily = 'SF Pro Display';

  // Display styles (for calculator output)
  static TextStyle displayLarge(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 2,
        height: 1.1,
      );

  static TextStyle displayMedium(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 1.5,
        height: 1.2,
      );

  static TextStyle displaySmall(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 1,
        height: 1.2,
      );

  // Expression display (secondary line showing calculation)
  static TextStyle expression(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: color.withAlpha(179), // 0.7 opacity
        letterSpacing: 0.5,
        height: 1.3,
      );

  // Button text styles
  static TextStyle buttonLarge(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle buttonMedium(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle buttonSmall(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Scientific function button text
  static TextStyle functionButton(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.5,
      );

  // Labels and indicators
  static TextStyle label(Color color) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle labelSmall(Color color) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1,
      );

  // Mode indicator
  static TextStyle modeIndicator(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.5,
      );

  // Unit converter labels
  static TextStyle unitLabel(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle unitValue(Color color) => TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1,
      );

  // Settings
  static TextStyle settingsTitle(Color color) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle settingsSubtitle(Color color) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color.withAlpha(179), // 0.7 opacity
      );
}
