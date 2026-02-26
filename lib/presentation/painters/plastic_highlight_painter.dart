import 'package:flutter/material.dart';

/// Paints plastic surface effects on top of buttons:
/// - Specular highlight spot (glossy light catch)
/// - Edge bevel (bright top, dark bottom border)
class PlasticHighlightPainter extends CustomPainter {
  final double borderRadius;
  final bool isPressed;
  final bool isOperator;

  PlasticHighlightPainter({
    required this.borderRadius,
    required this.isPressed,
    this.isOperator = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    if (!isPressed) {
      _drawEdgeBevel(canvas, size);
    } else {
      _drawPressedSurface(canvas, size);
    }

    canvas.restore();
  }

  void _drawEdgeBevel(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Top edge: thin bright line (light catch)
    final topBevel = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.18),
        Colors.white.withOpacity(0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.02, 0.06],
    );
    canvas.drawRect(rect, Paint()..shader = topBevel.createShader(rect));

    // Bottom edge: thin dark line (shadow)
    final bottomBevel = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.04),
        Colors.black.withOpacity(0.10),
      ],
      stops: const [0.94, 0.98, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = bottomBevel.createShader(rect));
  }

  void _drawPressedSurface(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // When pressed, add subtle darkening at top (inverted light)
    final pressedOverlay = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.06),
        Colors.transparent,
        Colors.white.withOpacity(0.02),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = pressedOverlay.createShader(rect));
  }

  @override
  bool shouldRepaint(PlasticHighlightPainter oldDelegate) {
    return oldDelegate.isPressed != isPressed ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isOperator != isOperator;
  }
}
