import 'package:flutter/material.dart';

import '../data/models/color_overrides.dart';
import 'color_palette.dart';
import 'theme_palette.dart';

/// Derives dependent colors when a user overrides a base color.
/// Ensures text remains readable and glow/dim variants stay consistent.
class ColorDerivation {
  ColorDerivation._();

  /// Apply all overrides from a ColorOverrides object to a base palette.
  static ThemePalette applyAll(ThemePalette base, ColorOverrides overrides) {
    var palette = base;
    if (overrides.numberButton != null) {
      palette = _applyNumberOverride(palette, overrides.numberButton!);
    }
    if (overrides.functionButton != null) {
      palette = _applyFunctionOverride(palette, overrides.functionButton!);
    }
    if (overrides.operatorButton != null) {
      palette = _applyOperatorOverride(palette, overrides.operatorButton!);
    }
    if (overrides.displayBackground != null) {
      palette =
          _applyDisplayBackgroundOverride(palette, overrides.displayBackground!);
    }
    if (overrides.displayText != null) {
      palette = _applyDisplayTextOverride(palette, overrides.displayText!);
    }
    return palette;
  }

  /// Operator button also drives accent colors and text-on-accent.
  static ThemePalette _applyOperatorOverride(ThemePalette base, Color color) {
    return base.copyWith(
      operatorButton: color,
      accent: color,
      accentDark: color.darken(10),
      accentLight: color.lighten(10),
      textOnAccent: _contrastText(color),
    );
  }

  /// Function button drives text-on-function.
  static ThemePalette _applyFunctionOverride(ThemePalette base, Color color) {
    return base.copyWith(
      functionButton: color,
      textOnFunction: _contrastText(color),
    );
  }

  /// Number button drives primary text color.
  static ThemePalette _applyNumberOverride(ThemePalette base, Color color) {
    return base.copyWith(
      numberButton: color,
      textPrimary: _contrastText(color),
    );
  }

  /// Display background — keep existing text colors.
  static ThemePalette _applyDisplayBackgroundOverride(
      ThemePalette base, Color color) {
    return base.copyWith(displayBackground: color);
  }

  /// Display text drives dim text, glow, and memory indicator.
  static ThemePalette _applyDisplayTextOverride(
      ThemePalette base, Color color) {
    return base.copyWith(
      displayText: color,
      displayTextDim: color.darken(20),
      displayGlow: color.withOpacityValue(0.35),
      memoryIndicator: color,
    );
  }

  /// Returns white or dark text for best contrast against [background].
  static Color _contrastText(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1E1E24)
        : const Color(0xFFFFFFFF);
  }
}
