import 'package:flutter/material.dart';

/// Paints CRT monitor effects: horizontal scanlines and screen curvature vignette.
class CrtScanlinePainter extends CustomPainter {
  final Color scanlineColor;
  final double scanlineOpacity;
  final double scanlineSpacing;

  CrtScanlinePainter({
    this.scanlineColor = Colors.black,
    this.scanlineOpacity = 0.10,
    this.scanlineSpacing = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scanlines: thin horizontal dark lines across the display
    final scanlinePaint = Paint()
      ..color = scanlineColor.withOpacity(scanlineOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += scanlineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    // Screen curvature vignette: darken edges to simulate curved CRT glass
    final vignetteRect = Offset.zero & size;
    final vignetteGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.15),
        Colors.black.withOpacity(0.35),
      ],
      stops: const [0.5, 0.85, 1.0],
    );
    canvas.drawRect(
      vignetteRect,
      Paint()..shader = vignetteGradient.createShader(vignetteRect),
    );
  }

  @override
  bool shouldRepaint(CrtScanlinePainter oldDelegate) {
    return oldDelegate.scanlineOpacity != scanlineOpacity ||
        oldDelegate.scanlineSpacing != scanlineSpacing;
  }
}
