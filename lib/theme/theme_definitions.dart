import 'package:flutter/material.dart';
import '../core/enums/app_theme_id.dart';
import 'theme_palette.dart';

/// Metadata and palettes for a single theme.
class ThemeDefinition {
  final AppThemeId id;
  final String displayName;
  final String description;
  final IconData icon;
  final ThemePalette lightPalette;
  final ThemePalette darkPalette;

  /// Whether this theme has CRT-style visual effects (scanlines, phosphor glow).
  final bool hasCrtEffects;

  /// Surface style hint: 'metallic' for brushed aluminum, 'plastic' for matte.
  final String surfaceStyle;

  const ThemeDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.lightPalette,
    required this.darkPalette,
    this.hasCrtEffects = false,
    this.surfaceStyle = 'metallic',
  });
}

/// Central theme registry. All theme definitions live here.
class ThemeRegistry {
  ThemeRegistry._();

  // ──────────────────────────────────────────────────────────
  // Classic — silver aluminum / copper (the original theme)
  // ──────────────────────────────────────────────────────────

  static const classic = ThemeDefinition(
    id: AppThemeId.classic,
    displayName: 'Classic',
    description: 'Silver aluminum with copper accents',
    icon: Icons.calculate_outlined,
    lightPalette: ThemePalette(
      background: Color(0xFFC0BFC5),
      surface: Color(0xFFF2EDE7),
      surfaceVariant: Color(0xFFDCD5CB),
      shadowDark: Color(0xFF8A8890),
      shadowLight: Color(0xFFFFFFFF),
      accent: Color(0xFFD4A574),
      accentDark: Color(0xFFC4956A),
      accentLight: Color(0xFFE4B584),
      displayBackground: Color(0xFF2C3E3A),
      displayText: Color(0xFF7FFFD4),
      displayTextDim: Color(0xFF5FCFAA),
      displayGlow: Color(0x4D7FFFD4),
      numberButton: Color(0xFFEAEAED),
      // Light factory uses textPrimary for function button color
      functionButton: Color(0xFF3A3A3A),
      operatorButton: Color(0xFFD4A574),
      textPrimary: Color(0xFF3A3A3A),
      textSecondary: Color(0xFF6A6A6A),
      textOnAccent: Color(0xFFFFFFFF),
      // Light factory uses numberButton color for textOnFunction
      textOnFunction: Color(0xFFEAEAED),
      error: Color(0xFFD46A6A),
      success: Color(0xFF6AD47A),
      memoryIndicator: Color(0xFF7FFFD4),
      metalHighlight: Color(0x1AFFFFFF),
      metalShadow: Color(0x1A000000),
      ambientOcclusion: Color(0x30000000),
    ),
    darkPalette: ThemePalette(
      background: Color(0xFF2A2A2E),
      surface: Color(0xFF28282E),
      surfaceVariant: Color(0xFF252530),
      shadowDark: Color(0xFF0A0A0C),
      shadowLight: Color(0xFF3A3A42),
      accent: Color(0xFFFFB347),
      accentDark: Color(0xFFCC8A2E),
      accentLight: Color(0xFFFFC367),
      displayBackground: Color(0xFF0D1B14),
      displayText: Color(0xFF00FF7F),
      displayTextDim: Color(0xFF00CF5F),
      displayGlow: Color(0x6600FF7F),
      numberButton: Color(0xFF38383E),
      functionButton: Color(0xFF303036),
      operatorButton: Color(0xFFFFB347),
      textPrimary: Color(0xFFE0E0E0),
      textSecondary: Color(0xFFA0A0A0),
      textOnAccent: Color(0xFF1E1E24),
      textOnFunction: Color(0xFFE0E0E0),
      error: Color(0xFFFF6B6B),
      success: Color(0xFF6BFF7B),
      memoryIndicator: Color(0xFF00FF7F),
      metalHighlight: Color(0x12FFFFFF),
      metalShadow: Color(0x25000000),
      ambientOcclusion: Color(0x40000000),
    ),
  );

  // ──────────────────────────────────────────────────────────
  // Retro CRT — monochrome cyan phosphor terminal
  // ──────────────────────────────────────────────────────────

  static const retroCrt = ThemeDefinition(
    id: AppThemeId.retroCrt,
    displayName: 'Retro CRT',
    description: 'Cyan phosphor on dark terminal',
    icon: Icons.terminal,
    hasCrtEffects: true,
    surfaceStyle: 'plastic',
    lightPalette: ThemePalette(
      background: Color(0xFF3A3A44),
      surface: Color(0xFF424250),
      surfaceVariant: Color(0xFF383846),
      shadowDark: Color(0xFF1A1A20),
      shadowLight: Color(0xFF52525E),
      accent: Color(0xFF00D4AA),
      accentDark: Color(0xFF00B090),
      accentLight: Color(0xFF00F0C0),
      displayBackground: Color(0xFF0A1A18),
      displayText: Color(0xFF00FFCC),
      displayTextDim: Color(0xFF00CC99),
      displayGlow: Color(0x6600FFCC),
      numberButton: Color(0xFF4A4A56),
      functionButton: Color(0xFF3E3E4A),
      operatorButton: Color(0xFF00D4AA),
      textPrimary: Color(0xFFD0D0D8),
      textSecondary: Color(0xFF8A8A96),
      textOnAccent: Color(0xFF0A1A18),
      textOnFunction: Color(0xFFD0D0D8),
      error: Color(0xFFFF5555),
      success: Color(0xFF50FA7B),
      memoryIndicator: Color(0xFF00FFCC),
      metalHighlight: Color(0x12FFFFFF),
      metalShadow: Color(0x25000000),
      ambientOcclusion: Color(0x40000000),
    ),
    darkPalette: ThemePalette(
      background: Color(0xFF1A1A22),
      surface: Color(0xFF222230),
      surfaceVariant: Color(0xFF1E1E2A),
      shadowDark: Color(0xFF08080C),
      shadowLight: Color(0xFF2E2E3A),
      accent: Color(0xFF00FFCC),
      accentDark: Color(0xFF00D4AA),
      accentLight: Color(0xFF33FFD9),
      displayBackground: Color(0xFF050F0C),
      displayText: Color(0xFF00FFCC),
      displayTextDim: Color(0xFF00BB99),
      displayGlow: Color(0x8000FFCC),
      numberButton: Color(0xFF2A2A36),
      functionButton: Color(0xFF222230),
      operatorButton: Color(0xFF00FFCC),
      textPrimary: Color(0xFFBBBBC8),
      textSecondary: Color(0xFF6A6A7A),
      textOnAccent: Color(0xFF050F0C),
      textOnFunction: Color(0xFFBBBBC8),
      error: Color(0xFFFF4444),
      success: Color(0xFF44FF66),
      memoryIndicator: Color(0xFF00FFCC),
      metalHighlight: Color(0x0AFFFFFF),
      metalShadow: Color(0x30000000),
      ambientOcclusion: Color(0x50000000),
    ),
  );

  /// All available themes, in display order.
  static const List<ThemeDefinition> all = [classic, retroCrt];

  /// Look up a theme by its ID.
  static ThemeDefinition getById(AppThemeId id) {
    return all.firstWhere((t) => t.id == id);
  }
}
