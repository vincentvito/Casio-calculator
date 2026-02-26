import 'package:flutter/material.dart';
import '../../painters/crt_scanline_painter.dart';

/// Overlay widget that adds CRT scanline and phosphor effects.
/// Place on top of display content inside a Stack.
class CrtDisplayOverlay extends StatelessWidget {
  const CrtDisplayOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: CrtScanlinePainter(
              scanlineOpacity: 0.10,
              scanlineSpacing: 3.0,
            ),
            isComplex: true,
            willChange: false,
          ),
        ),
      ),
    );
  }
}
