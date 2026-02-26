import 'package:flutter/material.dart';

/// Immutable color palette data for a single theme variant (light or dark).
/// Each AppThemeId provides two of these: one for light mode, one for dark.
class ThemePalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  final Color shadowDark;
  final Color shadowLight;

  final Color accent;
  final Color accentDark;
  final Color accentLight;

  final Color displayBackground;
  final Color displayText;
  final Color displayTextDim;
  final Color displayGlow;

  final Color numberButton;
  final Color functionButton;
  final Color operatorButton;

  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color textOnFunction;

  final Color error;
  final Color success;
  final Color memoryIndicator;

  final Color metalHighlight;
  final Color metalShadow;
  final Color ambientOcclusion;

  const ThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.shadowDark,
    required this.shadowLight,
    required this.accent,
    required this.accentDark,
    required this.accentLight,
    required this.displayBackground,
    required this.displayText,
    required this.displayTextDim,
    required this.displayGlow,
    required this.numberButton,
    required this.functionButton,
    required this.operatorButton,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.textOnFunction,
    required this.error,
    required this.success,
    required this.memoryIndicator,
    required this.metalHighlight,
    required this.metalShadow,
    required this.ambientOcclusion,
  });
}
