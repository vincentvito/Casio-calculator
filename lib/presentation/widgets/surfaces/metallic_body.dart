import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/neumorphic_theme.dart';
import '../../painters/brushed_metal_painter.dart';
import '../../providers/theme_provider.dart';

/// Wraps the calculator UI with a realistic body surface.
/// For metallic themes: brushed aluminum with chamfers, vignette, highlights.
/// For plastic themes: flat matte body with subtle vignette.
class MetallicBody extends StatelessWidget {
  final Widget child;

  const MetallicBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final definition = themeProvider.themeDefinition;
    final theme = themeProvider.neumorphicTheme;

    if (definition.surfaceStyle == 'plastic') {
      return _buildPlasticBody(theme, isDark, child);
    }
    return _buildMetallicBody(theme, isDark, child);
  }

  Widget _buildPlasticBody(
      NeumorphicThemeData neumorphicTheme, bool isDark, Widget child) {
    return Stack(
      children: [
        // Flat colored base
        Positioned.fill(
          child: ColoredBox(color: neumorphicTheme.backgroundColor),
        ),

        // Subtle vignette for depth
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(isDark ? 0.12 : 0.08),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Child content
        child,
      ],
    );
  }

  Widget _buildMetallicBody(
      NeumorphicThemeData neumorphicTheme, bool isDark, Widget child) {
    final metalBase = neumorphicTheme.backgroundColor;

    return Stack(
      children: [
        // Layer 1: Brushed aluminum base texture (procedural)
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: BrushedMetalPainter(
                baseColor: metalBase,
                highlightPosition: 0.28,
                highlightIntensity: isDark ? 0.08 : 0.12,
                isDark: isDark,
              ),
              isComplex: true,
              willChange: false,
            ),
          ),
        ),

        // Layer 2: Top/bottom edge chamfer highlights
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.06 : 0.10),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(isDark ? 0.15 : 0.10),
                  ],
                  stops: const [0.0, 0.025, 0.975, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Layer 3: Left/right edge chamfer
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.03 : 0.06),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(isDark ? 0.05 : 0.03),
                  ],
                  stops: const [0.0, 0.02, 0.98, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Layer 4: Radial vignette for curvature illusion
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(isDark ? 0.08 : 0.05),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Layer 5: Subtle horizontal reflection band (secondary, softer)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(isDark ? 0.015 : 0.03),
                    Colors.white.withOpacity(isDark ? 0.025 : 0.05),
                    Colors.white.withOpacity(isDark ? 0.015 : 0.03),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.15, 0.25, 0.35, 0.50, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Layer 6: Child content (the calculator UI)
        child,
      ],
    );
  }
}
