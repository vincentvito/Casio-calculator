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

  ThemePalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? shadowDark,
    Color? shadowLight,
    Color? accent,
    Color? accentDark,
    Color? accentLight,
    Color? displayBackground,
    Color? displayText,
    Color? displayTextDim,
    Color? displayGlow,
    Color? numberButton,
    Color? functionButton,
    Color? operatorButton,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnAccent,
    Color? textOnFunction,
    Color? error,
    Color? success,
    Color? memoryIndicator,
    Color? metalHighlight,
    Color? metalShadow,
    Color? ambientOcclusion,
  }) {
    return ThemePalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      accentLight: accentLight ?? this.accentLight,
      displayBackground: displayBackground ?? this.displayBackground,
      displayText: displayText ?? this.displayText,
      displayTextDim: displayTextDim ?? this.displayTextDim,
      displayGlow: displayGlow ?? this.displayGlow,
      numberButton: numberButton ?? this.numberButton,
      functionButton: functionButton ?? this.functionButton,
      operatorButton: operatorButton ?? this.operatorButton,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textOnFunction: textOnFunction ?? this.textOnFunction,
      error: error ?? this.error,
      success: success ?? this.success,
      memoryIndicator: memoryIndicator ?? this.memoryIndicator,
      metalHighlight: metalHighlight ?? this.metalHighlight,
      metalShadow: metalShadow ?? this.metalShadow,
      ambientOcclusion: ambientOcclusion ?? this.ambientOcclusion,
    );
  }
}
