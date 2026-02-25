import 'package:flutter/material.dart';
import 'color_palette.dart';

/// Theme data specifically for neumorphic styling
class NeumorphicThemeData {
  // Base colors
  final Color backgroundColor;
  final Color surfaceColor;
  final Color surfaceVariant;
  final Color shadowDark;
  final Color shadowLight;

  // Accent colors
  final Color accentColor;
  final Color accentDark;
  final Color accentLight;

  // Display colors
  final Color displayBackground;
  final Color displayText;
  final Color displayTextDim;
  final Color displayGlow;

  // Button colors
  final Color numberButtonColor;
  final Color functionButtonColor;
  final Color operatorButtonColor;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;

  // Semantic colors
  final Color errorColor;
  final Color successColor;
  final Color memoryIndicator;

  // Shadow configuration
  final double shadowDistance;
  final double shadowBlur;
  final double shadowSpread;
  final double innerShadowDistance;
  final double innerShadowBlur;

  // Button styling
  final double buttonBorderRadius;
  final double buttonPressDepth;
  final Duration buttonAnimationDuration;
  final Curve buttonAnimationCurve;

  // Display styling
  final double displayBorderRadius;
  final double displayPadding;

  const NeumorphicThemeData({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.surfaceVariant,
    required this.shadowDark,
    required this.shadowLight,
    required this.accentColor,
    required this.accentDark,
    required this.accentLight,
    required this.displayBackground,
    required this.displayText,
    required this.displayTextDim,
    required this.displayGlow,
    required this.numberButtonColor,
    required this.functionButtonColor,
    required this.operatorButtonColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.errorColor,
    required this.successColor,
    required this.memoryIndicator,
    this.shadowDistance = 8.0,
    this.shadowBlur = 16.0,
    this.shadowSpread = 0.0,
    this.innerShadowDistance = 4.0,
    this.innerShadowBlur = 8.0,
    this.buttonBorderRadius = 16.0,
    this.buttonPressDepth = 3.0,
    this.buttonAnimationDuration = const Duration(milliseconds: 100),
    this.buttonAnimationCurve = Curves.easeOutCubic,
    this.displayBorderRadius = 12.0,
    this.displayPadding = 16.0,
  });

  /// Light theme - warm cream-based palette
  factory NeumorphicThemeData.light() {
    return const NeumorphicThemeData(
      backgroundColor: LightPalette.background,
      surfaceColor: LightPalette.surface,
      surfaceVariant: LightPalette.surfaceVariant,
      shadowDark: LightPalette.shadowDark,
      shadowLight: LightPalette.shadowLight,
      accentColor: LightPalette.accent,
      accentDark: LightPalette.accentDark,
      accentLight: LightPalette.accentLight,
      displayBackground: LightPalette.displayBackground,
      displayText: LightPalette.displayText,
      displayTextDim: LightPalette.displayTextDim,
      displayGlow: LightPalette.displayGlow,
      numberButtonColor: LightPalette.numberButton,
      functionButtonColor: LightPalette.functionButton,
      operatorButtonColor: LightPalette.operatorButton,
      textPrimary: LightPalette.textPrimary,
      textSecondary: LightPalette.textSecondary,
      textOnAccent: LightPalette.textOnAccent,
      errorColor: LightPalette.error,
      successColor: LightPalette.success,
      memoryIndicator: LightPalette.memoryIndicator,
    );
  }

  /// Dark theme - rich charcoal palette
  factory NeumorphicThemeData.dark() {
    return const NeumorphicThemeData(
      backgroundColor: DarkPalette.background,
      surfaceColor: DarkPalette.surface,
      surfaceVariant: DarkPalette.surfaceVariant,
      shadowDark: DarkPalette.shadowDark,
      shadowLight: DarkPalette.shadowLight,
      accentColor: DarkPalette.accent,
      accentDark: DarkPalette.accentDark,
      accentLight: DarkPalette.accentLight,
      displayBackground: DarkPalette.displayBackground,
      displayText: DarkPalette.displayText,
      displayTextDim: DarkPalette.displayTextDim,
      displayGlow: DarkPalette.displayGlow,
      numberButtonColor: DarkPalette.numberButton,
      functionButtonColor: DarkPalette.functionButton,
      operatorButtonColor: DarkPalette.operatorButton,
      textPrimary: DarkPalette.textPrimary,
      textSecondary: DarkPalette.textSecondary,
      textOnAccent: DarkPalette.textOnAccent,
      errorColor: DarkPalette.error,
      successColor: DarkPalette.success,
      memoryIndicator: DarkPalette.memoryIndicator,
    );
  }

  /// Generate outer shadows for convex (raised) elements
  List<BoxShadow> get convexShadows => [
        BoxShadow(
          color: shadowDark.withAlpha(153), // 0.6 opacity
          offset: Offset(shadowDistance, shadowDistance),
          blurRadius: shadowBlur,
          spreadRadius: shadowSpread,
        ),
        BoxShadow(
          color: shadowLight.withAlpha(204), // 0.8 opacity
          offset: Offset(-shadowDistance * 0.5, -shadowDistance * 0.5),
          blurRadius: shadowBlur * 0.5,
          spreadRadius: shadowSpread,
        ),
      ];

  /// Generate inner shadows for concave (pressed) elements
  List<BoxShadow> get concaveShadows => [
        BoxShadow(
          color: shadowDark.withAlpha(128), // 0.5 opacity
          offset: Offset(-innerShadowDistance, -innerShadowDistance),
          blurRadius: innerShadowBlur,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: shadowLight.withAlpha(128), // 0.5 opacity
          offset: Offset(innerShadowDistance, innerShadowDistance),
          blurRadius: innerShadowBlur,
          spreadRadius: -2,
        ),
      ];

  /// Subtle gradient for 3D convex effect
  LinearGradient get convexGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceColor.lighten(3),
          surfaceColor.darken(3),
        ],
      );

  /// Subtle gradient for 3D concave effect
  LinearGradient get concaveGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceColor.darken(5),
          surfaceColor.lighten(2),
        ],
      );

  /// Copy with modifications
  NeumorphicThemeData copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? surfaceVariant,
    Color? shadowDark,
    Color? shadowLight,
    Color? accentColor,
    Color? accentDark,
    Color? accentLight,
    Color? displayBackground,
    Color? displayText,
    Color? displayTextDim,
    Color? displayGlow,
    Color? numberButtonColor,
    Color? functionButtonColor,
    Color? operatorButtonColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnAccent,
    Color? errorColor,
    Color? successColor,
    Color? memoryIndicator,
    double? shadowDistance,
    double? shadowBlur,
    double? shadowSpread,
    double? innerShadowDistance,
    double? innerShadowBlur,
    double? buttonBorderRadius,
    double? buttonPressDepth,
    Duration? buttonAnimationDuration,
    Curve? buttonAnimationCurve,
    double? displayBorderRadius,
    double? displayPadding,
  }) {
    return NeumorphicThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      accentColor: accentColor ?? this.accentColor,
      accentDark: accentDark ?? this.accentDark,
      accentLight: accentLight ?? this.accentLight,
      displayBackground: displayBackground ?? this.displayBackground,
      displayText: displayText ?? this.displayText,
      displayTextDim: displayTextDim ?? this.displayTextDim,
      displayGlow: displayGlow ?? this.displayGlow,
      numberButtonColor: numberButtonColor ?? this.numberButtonColor,
      functionButtonColor: functionButtonColor ?? this.functionButtonColor,
      operatorButtonColor: operatorButtonColor ?? this.operatorButtonColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      memoryIndicator: memoryIndicator ?? this.memoryIndicator,
      shadowDistance: shadowDistance ?? this.shadowDistance,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowSpread: shadowSpread ?? this.shadowSpread,
      innerShadowDistance: innerShadowDistance ?? this.innerShadowDistance,
      innerShadowBlur: innerShadowBlur ?? this.innerShadowBlur,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonPressDepth: buttonPressDepth ?? this.buttonPressDepth,
      buttonAnimationDuration:
          buttonAnimationDuration ?? this.buttonAnimationDuration,
      buttonAnimationCurve: buttonAnimationCurve ?? this.buttonAnimationCurve,
      displayBorderRadius: displayBorderRadius ?? this.displayBorderRadius,
      displayPadding: displayPadding ?? this.displayPadding,
    );
  }
}
