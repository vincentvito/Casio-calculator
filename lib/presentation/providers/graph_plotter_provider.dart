import 'dart:ui';

import 'package:flutter/foundation.dart';
import '../../domain/engines/expression_evaluator.dart';

/// Provider for managing graph plotter state
class GraphPlotterProvider extends ChangeNotifier {
  final ExpressionEvaluator _evaluator = ExpressionEvaluator(isRadianMode: true);

  // Expression state
  String _expression = 'x^2';
  String get expression => _expression;

  // View window
  double _xMin = -10;
  double _xMax = 10;
  double _yMin = -10;
  double _yMax = 10;

  double get xMin => _xMin;
  double get xMax => _xMax;
  double get yMin => _yMin;
  double get yMax => _yMax;

  // Computed points
  List<Offset> _points = [];
  List<Offset> get points => _points;

  // Error state
  bool _isError = false;
  String _errorMessage = '';
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  // Touch point for displaying coordinates
  Offset? _touchPoint;
  Offset? get touchPoint => _touchPoint;

  /// Update the expression and recalculate points
  void updateExpression(String expr) {
    _expression = expr;
    _isError = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Set touch point for coordinate display
  void setTouchPoint(Offset? point) {
    _touchPoint = point;
    notifyListeners();
  }

  /// Zoom in by reducing the view window
  void zoomIn() {
    final xCenter = (_xMin + _xMax) / 2;
    final yCenter = (_yMin + _yMax) / 2;
    final xRange = (_xMax - _xMin) * 0.4; // 80% of current
    final yRange = (_yMax - _yMin) * 0.4;

    _xMin = xCenter - xRange;
    _xMax = xCenter + xRange;
    _yMin = yCenter - yRange;
    _yMax = yCenter + yRange;
    notifyListeners();
  }

  /// Zoom out by expanding the view window
  void zoomOut() {
    final xCenter = (_xMin + _xMax) / 2;
    final yCenter = (_yMin + _yMax) / 2;
    final xRange = (_xMax - _xMin) * 0.625; // 125% of current
    final yRange = (_yMax - _yMin) * 0.625;

    _xMin = xCenter - xRange;
    _xMax = xCenter + xRange;
    _yMin = yCenter - yRange;
    _yMax = yCenter + yRange;
    notifyListeners();
  }

  /// Pan the view window
  void pan(double dxMath, double dyMath) {
    _xMin -= dxMath;
    _xMax -= dxMath;
    _yMin -= dyMath;
    _yMax -= dyMath;
    notifyListeners();
  }

  /// Handle pinch zoom
  void pinchZoom(double scaleFactor) {
    final xCenter = (_xMin + _xMax) / 2;
    final yCenter = (_yMin + _yMax) / 2;
    final xRange = (_xMax - _xMin) / (2 * scaleFactor);
    final yRange = (_yMax - _yMin) / (2 * scaleFactor);

    _xMin = xCenter - xRange;
    _xMax = xCenter + xRange;
    _yMin = yCenter - yRange;
    _yMax = yCenter + yRange;
    notifyListeners();
  }

  /// Reset to default view
  void resetView() {
    _xMin = -10;
    _xMax = 10;
    _yMin = -10;
    _yMax = 10;
    _touchPoint = null;
    notifyListeners();
  }

  /// Recalculate points for the current expression and canvas size
  void recalculatePoints(Size canvasSize) {
    if (_expression.isEmpty) {
      _points = [];
      notifyListeners();
      return;
    }

    _isError = false;
    _errorMessage = '';

    final newPoints = <Offset>[];
    final numSamples = 400; // More samples for smoother curves
    final xStep = (_xMax - _xMin) / numSamples;

    for (int i = 0; i <= numSamples; i++) {
      final x = _xMin + i * xStep;
      try {
        // Substitute x into the expression
        final exprWithX = _substituteX(_expression, x);
        final y = _evaluator.evaluate(exprWithX);

        // Skip NaN and Infinity values
        if (y.isNaN || y.isInfinite) {
          // Add a null marker for discontinuity
          newPoints.add(const Offset(double.nan, double.nan));
          continue;
        }

        // Convert math coordinates to canvas coordinates
        final canvasX = (x - _xMin) / (_xMax - _xMin) * canvasSize.width;
        final canvasY = (_yMax - y) / (_yMax - _yMin) * canvasSize.height;

        newPoints.add(Offset(canvasX, canvasY));
      } catch (e) {
        // For domain errors or parse errors, mark as discontinuity
        newPoints.add(const Offset(double.nan, double.nan));
      }
    }

    _points = newPoints;
    notifyListeners();
  }

  /// Try to validate the expression without calculating all points
  bool validateExpression() {
    if (_expression.isEmpty) {
      _isError = true;
      _errorMessage = 'Enter an expression';
      notifyListeners();
      return false;
    }

    try {
      // Test evaluate at x=0
      final testExpr = _substituteX(_expression, 0);
      _evaluator.evaluate(testExpr);
      _isError = false;
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      // Try at x=1 in case x=0 causes domain error
      try {
        final testExpr = _substituteX(_expression, 1);
        _evaluator.evaluate(testExpr);
        _isError = false;
        _errorMessage = '';
        notifyListeners();
        return true;
      } catch (e2) {
        _isError = true;
        _errorMessage = 'Invalid expression';
        notifyListeners();
        return false;
      }
    }
  }

  /// Substitute x variable with a value in the expression
  String _substituteX(String expr, double x) {
    // Handle negative x values by wrapping in parentheses
    final xStr = x < 0 ? '($x)' : '$x';

    final result = StringBuffer();
    final normalized = expr.toLowerCase();

    for (int i = 0; i < normalized.length; i++) {
      if (normalized[i] == 'x') {
        // Check if it's a standalone 'x' (not part of 'exp', 'max', etc.)
        final prevChar = i > 0 ? normalized[i - 1] : ' ';
        final nextChar = i < normalized.length - 1 ? normalized[i + 1] : ' ';

        final prevIsLetter = _isLetter(prevChar);
        final nextIsLetter = _isLetter(nextChar);

        if (!prevIsLetter && !nextIsLetter) {
          // Handle implicit multiplication: 2x -> 2*x, x2 -> x*2 (rare but handle)
          if (i > 0 && (_isDigit(prevChar) || prevChar == ')')) {
            result.write('*');
          }
          result.write(xStr);
          if (i < normalized.length - 1 &&
              (_isDigit(nextChar) || nextChar == '(' || _isLetter(nextChar))) {
            // Don't add * if next is already an operator
            if (nextChar != '+' &&
                nextChar != '-' &&
                nextChar != '*' &&
                nextChar != '/' &&
                nextChar != '^') {
              result.write('*');
            }
          }
        } else {
          result.write(expr[i]);
        }
      } else {
        result.write(expr[i]);
      }
    }

    return result.toString();
  }

  bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  /// Convert canvas coordinates to math coordinates
  Offset canvasToMath(Offset canvasPoint, Size canvasSize) {
    final x = _xMin + (canvasPoint.dx / canvasSize.width) * (_xMax - _xMin);
    final y = _yMax - (canvasPoint.dy / canvasSize.height) * (_yMax - _yMin);
    return Offset(x, y);
  }

  /// Convert math coordinates to canvas coordinates
  Offset mathToCanvas(Offset mathPoint, Size canvasSize) {
    final canvasX =
        (mathPoint.dx - _xMin) / (_xMax - _xMin) * canvasSize.width;
    final canvasY =
        (_yMax - mathPoint.dy) / (_yMax - _yMin) * canvasSize.height;
    return Offset(canvasX, canvasY);
  }
}
