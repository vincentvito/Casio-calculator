import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom painter for rendering the graph
class GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final Color gridColor;
  final Color axisColor;
  final Color curveColor;
  final Color labelColor;
  final Offset? touchPoint;

  GraphPainter({
    required this.points,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.gridColor,
    required this.axisColor,
    required this.curveColor,
    required this.labelColor,
    this.touchPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawCurve(canvas, size);
    if (touchPoint != null) {
      _drawTouchIndicator(canvas, size, touchPoint!);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Calculate grid spacing
    final xRange = xMax - xMin;
    final yRange = yMax - yMin;

    // Auto-calculate grid step based on range
    final xStep = _calculateGridStep(xRange);
    final yStep = _calculateGridStep(yRange);

    // Draw vertical grid lines
    final xStart = (xMin / xStep).ceil() * xStep;
    for (double x = xStart; x <= xMax; x += xStep) {
      final canvasX = (x - xMin) / xRange * size.width;
      _drawDottedLine(
        canvas,
        Offset(canvasX, 0),
        Offset(canvasX, size.height),
        paint,
      );
    }

    // Draw horizontal grid lines
    final yStart = (yMin / yStep).ceil() * yStep;
    for (double y = yStart; y <= yMax; y += yStep) {
      final canvasY = (yMax - y) / yRange * size.height;
      _drawDottedLine(
        canvas,
        Offset(0, canvasY),
        Offset(size.width, canvasY),
        paint,
      );
    }
  }

  double _calculateGridStep(double range) {
    // Target approximately 5-10 grid lines
    final roughStep = range / 8;
    final magnitude = _magnitude(roughStep);
    final normalized = roughStep / magnitude;

    double step;
    if (normalized < 1.5) {
      step = 1;
    } else if (normalized < 3) {
      step = 2;
    } else if (normalized < 7) {
      step = 5;
    } else {
      step = 10;
    }

    return step * magnitude;
  }

  double _magnitude(double value) {
    if (value == 0) return 1;
    final log = value.abs();
    final exp = log.toString().contains('e')
        ? int.parse(log.toString().split('e')[1])
        : (log >= 1 ? log.toString().split('.')[0].length - 1 : -1);
    return _pow10(exp);
  }

  double _pow10(int exp) {
    double result = 1;
    if (exp >= 0) {
      for (int i = 0; i < exp; i++) {
        result *= 10;
      }
    } else {
      for (int i = 0; i < -exp; i++) {
        result /= 10;
      }
    }
    return result;
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 3.0;
    const gapLength = 3.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (Offset(dx, dy)).distance;

    final unitX = dx / distance;
    final unitY = dy / distance;

    double drawn = 0;
    while (drawn < distance) {
      final startX = start.dx + unitX * drawn;
      final startY = start.dy + unitY * drawn;
      final endDraw = (drawn + dashLength).clamp(0, distance);
      final endX = start.dx + unitX * endDraw;
      final endY = start.dy + unitY * endDraw;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      drawn += dashLength + gapLength;
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final xRange = xMax - xMin;
    final yRange = yMax - yMin;

    // Draw X axis (y = 0)
    if (yMin <= 0 && yMax >= 0) {
      final canvasY = (yMax - 0) / yRange * size.height;
      canvas.drawLine(
        Offset(0, canvasY),
        Offset(size.width, canvasY),
        paint,
      );

      // Draw axis labels
      _drawAxisLabels(canvas, size, isXAxis: true, axisCanvasPos: canvasY);
    }

    // Draw Y axis (x = 0)
    if (xMin <= 0 && xMax >= 0) {
      final canvasX = (0 - xMin) / xRange * size.width;
      canvas.drawLine(
        Offset(canvasX, 0),
        Offset(canvasX, size.height),
        paint,
      );

      // Draw axis labels
      _drawAxisLabels(canvas, size, isXAxis: false, axisCanvasPos: canvasX);
    }
  }

  void _drawAxisLabels(
    Canvas canvas,
    Size size, {
    required bool isXAxis,
    required double axisCanvasPos,
  }) {
    final xRange = xMax - xMin;
    final yRange = yMax - yMin;
    final step = _calculateGridStep(isXAxis ? xRange : yRange);

    // Use a brighter, larger font for better visibility
    final textStyle = ui.TextStyle(
      color: labelColor,
      fontSize: 12,
      fontWeight: ui.FontWeight.w500,
    );

    // Background style for label readability
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    if (isXAxis) {
      // X axis labels
      final xStart = (xMin / step).ceil() * step;
      for (double x = xStart; x <= xMax; x += step) {
        if (x.abs() < step * 0.01) continue; // Skip 0

        final canvasX = (x - xMin) / xRange * size.width;
        final labelText = _formatNumber(x);

        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 12,
        ))
          ..pushStyle(textStyle)
          ..addText(labelText);

        final paragraph = paragraphBuilder.build()
          ..layout(const ui.ParagraphConstraints(width: 50));

        final labelY = (axisCanvasPos + 4).clamp(0.0, size.height - 18);
        final labelX = canvasX - 25;

        // Draw background for readability
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(labelX + 10, labelY, 30, 16),
            const Radius.circular(3),
          ),
          bgPaint,
        );

        canvas.drawParagraph(paragraph, Offset(labelX, labelY));
      }
    } else {
      // Y axis labels
      final yStart = (yMin / step).ceil() * step;
      for (double y = yStart; y <= yMax; y += step) {
        if (y.abs() < step * 0.01) continue; // Skip 0

        final canvasY = (yMax - y) / yRange * size.height;
        final labelText = _formatNumber(y);

        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.right,
          fontSize: 12,
        ))
          ..pushStyle(textStyle)
          ..addText(labelText);

        final paragraph = paragraphBuilder.build()
          ..layout(const ui.ParagraphConstraints(width: 40));

        final labelX = (axisCanvasPos + 4).clamp(0.0, size.width - 45);
        final labelY = canvasY - 8;

        // Draw background for readability
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(labelX, labelY, 40, 16),
            const Radius.circular(3),
          ),
          bgPaint,
        );

        canvas.drawParagraph(paragraph, Offset(labelX, labelY));
      }
    }
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1000 || value.abs() < 0.01) {
      return value.toStringAsExponential(1);
    }
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _drawCurve(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw curve segments, breaking at NaN points (discontinuities)
    final path = Path();
    bool isDrawing = false;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      if (point.dx.isNaN || point.dy.isNaN) {
        // Discontinuity - end current segment
        if (isDrawing) {
          canvas.drawPath(path, paint);
          path.reset();
          isDrawing = false;
        }
        continue;
      }

      // Clip to canvas bounds with some margin for smooth edges
      final isInBounds = point.dy >= -size.height * 0.5 &&
          point.dy <= size.height * 1.5 &&
          point.dx >= -10 &&
          point.dx <= size.width + 10;

      if (!isInBounds) {
        if (isDrawing) {
          // Draw line to edge then stop
          path.lineTo(point.dx.clamp(-10, size.width + 10),
              point.dy.clamp(-size.height * 0.5, size.height * 1.5));
          canvas.drawPath(path, paint);
          path.reset();
          isDrawing = false;
        }
        continue;
      }

      if (!isDrawing) {
        path.moveTo(point.dx, point.dy);
        isDrawing = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Draw remaining path
    if (isDrawing) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawTouchIndicator(Canvas canvas, Size size, Offset touch) {
    // Draw crosshairs
    final crosshairPaint = Paint()
      ..color = curveColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical line
    canvas.drawLine(
      Offset(touch.dx, 0),
      Offset(touch.dx, size.height),
      crosshairPaint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(0, touch.dy),
      Offset(size.width, touch.dy),
      crosshairPaint,
    );

    // Draw touch point circle
    final pointPaint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(touch, 6, pointPaint);

    // Draw white inner circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(touch, 3, innerPaint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.touchPoint != touchPoint ||
        oldDelegate.curveColor != curveColor;
  }
}
