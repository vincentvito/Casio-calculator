import 'package:flutter/material.dart';

/// Light mode color palette - silver aluminum body with plastic keys
/// Inspired by Braun calculators and premium physical objects
abstract class LightPalette {
  // Base surface colors (aluminum context)
  static const Color background = Color(0xFFC0BFC5); // Silver aluminum fallback
  static const Color surface = Color(0xFFF2EDE7); // Lighter cream (settings panel)
  static const Color surfaceVariant = Color(0xFFDCD5CB); // Slightly darker

  // Shadow colors for neumorphism
  static const Color shadowDark = Color(0xFF8A8890); // Cool gray shadow (metallic)
  static const Color shadowLight = Color(0xFFFFFFFF); // White highlight

  // Accent colors
  static const Color accent = Color(0xFFD4A574); // Warm copper/bronze
  static const Color accentDark = Color(0xFFC4956A); // Darker copper
  static const Color accentLight = Color(0xFFE4B584); // Lighter copper

  // Display colors (LCD-style)
  static const Color displayBackground = Color(0xFF2C3E3A); // Dark teal
  static const Color displayText = Color(0xFF7FFFD4); // Aquamarine LCD
  static const Color displayTextDim = Color(0xFF5FCFAA); // Dimmer LCD text
  static const Color displayGlow = Color(0x4D7FFFD4); // 30% opacity glow

  // Button colors (plastic feel — cool off-white)
  static const Color numberButton = Color(0xFFEAEAED); // Cool off-white plastic
  static const Color functionButton = Color(0xFFD8D8DC); // Slightly darker cool gray
  static const Color operatorButton = Color(0xFFD4A574); // Bronze for operators

  // Text colors
  static const Color textPrimary = Color(0xFF3A3A3A); // Slightly darker for metal contrast
  static const Color textSecondary = Color(0xFF6A6A6A); // Medium gray
  static const Color textOnAccent = Color(0xFFFFFFFF); // White on accent

  // Semantic colors
  static const Color error = Color(0xFFD46A6A); // Soft red
  static const Color success = Color(0xFF6AD47A); // Soft green

  // Memory indicator
  static const Color memoryIndicator = Color(0xFF7FFFD4); // Match display

  // Metallic utility colors
  static const Color metalHighlight = Color(0x1AFFFFFF); // Edge highlights
  static const Color metalShadow = Color(0x1A000000); // Edge shadows
  static const Color ambientOcclusion = Color(0x30000000); // Button-to-body gap
}

/// Dark mode color palette - gunmetal aluminum body with dark plastic keys
/// Inspired by high-end hi-fi equipment and space gray Apple hardware
abstract class DarkPalette {
  // Base surface colors (gunmetal aluminum context)
  static const Color background = Color(0xFF2A2A2E); // Gunmetal fallback
  static const Color surface = Color(0xFF28282E); // Slightly lighter (settings)
  static const Color surfaceVariant = Color(0xFF252530); // Darker variant

  // Shadow colors for neumorphism
  static const Color shadowDark = Color(0xFF0A0A0C); // Deep black
  static const Color shadowLight = Color(0xFF3A3A42); // Lighter edge

  // Accent colors
  static const Color accent = Color(0xFFFFB347); // Warm amber
  static const Color accentDark = Color(0xFFCC8A2E); // Darker amber
  static const Color accentLight = Color(0xFFFFC367); // Lighter amber

  // Display colors (LCD-style)
  static const Color displayBackground = Color(0xFF0D1B14); // Very dark green
  static const Color displayText = Color(0xFF00FF7F); // Spring green LCD
  static const Color displayTextDim = Color(0xFF00CF5F); // Dimmer LCD text
  static const Color displayGlow = Color(0x6600FF7F); // 40% opacity glow

  // Button colors (dark plastic)
  static const Color numberButton = Color(0xFF38383E); // Dark charcoal plastic
  static const Color functionButton = Color(0xFF303036); // Slightly darker
  static const Color operatorButton = Color(0xFFFFB347); // Amber operators

  // Text colors
  static const Color textPrimary = Color(0xFFE0E0E0); // Light gray
  static const Color textSecondary = Color(0xFFA0A0A0); // Medium gray
  static const Color textOnAccent = Color(0xFF1E1E24); // Dark on accent

  // Semantic colors
  static const Color error = Color(0xFFFF6B6B); // Bright red
  static const Color success = Color(0xFF6BFF7B); // Bright green

  // Memory indicator
  static const Color memoryIndicator = Color(0xFF00FF7F); // Match display

  // Metallic utility colors
  static const Color metalHighlight = Color(0x12FFFFFF); // Edge highlights
  static const Color metalShadow = Color(0x25000000); // Edge shadows
  static const Color ambientOcclusion = Color(0x40000000); // Button-to-body gap
}

/// Extension methods for color manipulation
extension ColorExtension on Color {
  /// Lighten a color by a percentage (0-100)
  Color lighten([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final factor = percent / 100;
    final r = (this.r * 255).round();
    final g = (this.g * 255).round();
    final b = (this.b * 255).round();
    final a = (this.a * 255).round();
    return Color.fromARGB(
      a,
      (r + ((255 - r) * factor)).round().clamp(0, 255),
      (g + ((255 - g) * factor)).round().clamp(0, 255),
      (b + ((255 - b) * factor)).round().clamp(0, 255),
    );
  }

  /// Darken a color by a percentage (0-100)
  Color darken([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final factor = 1 - (percent / 100);
    final r = (this.r * 255).round();
    final g = (this.g * 255).round();
    final b = (this.b * 255).round();
    final a = (this.a * 255).round();
    return Color.fromARGB(
      a,
      (r * factor).round().clamp(0, 255),
      (g * factor).round().clamp(0, 255),
      (b * factor).round().clamp(0, 255),
    );
  }

  /// Create a color with modified opacity
  Color withOpacityValue(double opacity) {
    return withAlpha((opacity * 255).round().clamp(0, 255));
  }
}
