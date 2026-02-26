import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Procedural brushed aluminum texture painter.
/// Draws fine horizontal lines with subtle brightness variation
/// to simulate directional grain, plus an anisotropic highlight band.
class BrushedMetalPainter extends CustomPainter {
  final Color baseColor;
  final double highlightPosition;
  final double highlightIntensity;
  final bool isDark;

  BrushedMetalPainter({
    required this.baseColor,
    this.highlightPosition = 0.28,
    this.highlightIntensity = 0.12,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill base color
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    // 2. Draw horizontal grain lines (brushed metal texture)
    _drawGrainLines(canvas, size);

    // 3. Draw anisotropic highlight band
    _drawAnisotropicHighlight(canvas, size);
  }

  void _drawGrainLines(Canvas canvas, Size size) {
    final lineSpacing = 0.8; // Sub-pixel spacing for dense grain
    final grainOpacityBase = isDark ? 0.06 : 0.04;
    final grainVariation = isDark ? 0.05 : 0.035;

    // Draw groups of grain lines at varying brightness
    for (double y = 0; y < size.height; y += lineSpacing) {
      // Use hash-like function for deterministic but varied brightness
      final seed = (y * 7.3 + 13.7).truncate();
      final variation = _pseudoRandom(seed);

      // Alternate between slightly lighter and darker lines
      final isLight = variation > 0.5;
      final opacity = grainOpacityBase + (variation * grainVariation);

      final color = isLight
          ? Colors.white.withOpacity(opacity)
          : Colors.black.withOpacity(opacity * 0.7);

      final paint = Paint()
        ..color = color
        ..strokeWidth = lineSpacing * 0.6
        ..style = PaintingStyle.stroke;

      // Add micro-variation to line start/end for organic feel
      final xOffset = _pseudoRandom(seed + 100) * 2 - 1;
      canvas.drawLine(
        Offset(xOffset, y),
        Offset(size.width + xOffset, y),
        paint,
      );
    }

    // 3. Add scattered micro-noise for extra texture
    final noisePaint = Paint()..strokeWidth = 0.5;
    for (int i = 0; i < (size.width * size.height * 0.003).round(); i++) {
      final x = _pseudoRandom(i * 3 + 1) * size.width;
      final y = _pseudoRandom(i * 3 + 2) * size.height;
      final brightness = _pseudoRandom(i * 3 + 3);

      noisePaint.color = brightness > 0.5
          ? Colors.white.withOpacity(0.03)
          : Colors.black.withOpacity(0.02);

      canvas.drawPoints(
        ui.PointMode.points,
        [Offset(x, y)],
        noisePaint,
      );
    }
  }

  void _drawAnisotropicHighlight(Canvas canvas, Size size) {
    // Bright horizontal band that simulates overhead environment reflection
    final highlightY = size.height * highlightPosition;
    final bandWidth = size.height * 0.35; // Width of the highlight falloff

    final highlightRect = Rect.fromLTWH(0, highlightY - bandWidth / 2, size.width, bandWidth);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(highlightIntensity * 0.5),
        Colors.white.withOpacity(highlightIntensity),
        Colors.white.withOpacity(highlightIntensity * 0.5),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    canvas.drawRect(
      highlightRect,
      Paint()..shader = gradient.createShader(highlightRect),
    );
  }

  /// Fast deterministic pseudo-random for grain variation (0.0 - 1.0)
  double _pseudoRandom(int seed) {
    var x = seed;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return (x & 0x7FFFFFFF) / 0x7FFFFFFF;
  }

  @override
  bool shouldRepaint(BrushedMetalPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.highlightPosition != highlightPosition ||
        oldDelegate.highlightIntensity != highlightIntensity ||
        oldDelegate.isDark != isDark;
  }
}
