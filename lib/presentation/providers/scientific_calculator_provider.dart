import 'package:flutter/foundation.dart';
import '../../domain/engines/expression_evaluator.dart';

/// Provider for scientific calculator with expression support
class ScientificCalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _displayValue = '0';
  String _lastResult = '';
  bool _isError = false;
  String _errorMessage = '';
  bool _isRadianMode = false;
  bool _hasJustEvaluated = false;

  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  // Getters
  String get expression => _expression;
  String get displayValue => _displayValue;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
  bool get isRadianMode => _isRadianMode;

  /// Update the display based on current expression
  void _updateDisplay() {
    if (_expression.isEmpty) {
      _displayValue = '0';
    } else {
      _displayValue = _expression;
    }
    notifyListeners();
  }

  /// Input a digit
  void inputDigit(String digit) {
    if (_isError) {
      clear();
    }

    // If we just evaluated and user starts typing a new number, start fresh
    if (_hasJustEvaluated) {
      _expression = digit;
      _hasJustEvaluated = false;
    } else {
      _expression += digit;
    }
    _updateDisplay();
  }

  /// Input a decimal point
  void inputDecimal() {
    if (_isError) {
      clear();
    }

    if (_hasJustEvaluated) {
      _expression = '0.';
      _hasJustEvaluated = false;
    } else {
      // Find the last number in the expression and check if it has a decimal
      final lastNumMatch = RegExp(r'[\d.]+$').firstMatch(_expression);
      if (lastNumMatch == null) {
        _expression += '0.';
      } else if (!lastNumMatch.group(0)!.contains('.')) {
        _expression += '.';
      }
    }
    _updateDisplay();
  }

  /// Input an operator
  void inputOperator(String op) {
    if (_isError) {
      clear();
    }

    _hasJustEvaluated = false;

    if (_expression.isEmpty) {
      // Allow negative at start
      if (op == '-') {
        _expression = '-';
      } else if (_lastResult.isNotEmpty) {
        // Use last result if available
        _expression = _lastResult + op;
      }
    } else {
      // Replace trailing operator if any
      final lastChar = _expression[_expression.length - 1];
      if ('+-×÷*/^'.contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    }
    _updateDisplay();
  }

  /// Input left parenthesis
  void inputLeftParen() {
    if (_isError) {
      clear();
    }

    _hasJustEvaluated = false;

    // Add multiplication if needed (e.g., "5(" should be "5*(")
    if (_expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      if (_isDigit(lastChar) || lastChar == ')' || lastChar == 'π' || lastChar == 'e') {
        _expression += '×';
      }
    }
    _expression += '(';
    _updateDisplay();
  }

  /// Input right parenthesis
  void inputRightParen() {
    if (_isError) {
      clear();
    }

    _hasJustEvaluated = false;

    // Count open vs close parens
    int openCount = _expression.split('(').length - 1;
    int closeCount = _expression.split(')').length - 1;

    if (openCount > closeCount && _expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      // Don't add ) right after ( or after operator
      if (lastChar != '(' && !'+-×÷*/^'.contains(lastChar)) {
        _expression += ')';
      }
    }
    _updateDisplay();
  }

  /// Input a function (sin, cos, tan, ln, log, sqrt, etc.)
  void inputFunction(String func) {
    if (_isError) {
      clear();
    }

    _hasJustEvaluated = false;

    // Add multiplication if needed
    if (_expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      if (_isDigit(lastChar) || lastChar == ')' || lastChar == 'π' || lastChar == 'e') {
        _expression += '×';
      }
    }

    _expression += '$func(';
    _updateDisplay();
  }

  /// Input a constant (π or e)
  void inputConstant(String constant) {
    if (_isError) {
      clear();
    }

    if (_hasJustEvaluated) {
      _expression = constant;
      _hasJustEvaluated = false;
    } else {
      // Add multiplication if needed
      if (_expression.isNotEmpty) {
        final lastChar = _expression[_expression.length - 1];
        if (_isDigit(lastChar) || lastChar == ')' || lastChar == 'π' || lastChar == 'e') {
          _expression += '×';
        }
      }
      _expression += constant;
    }
    _updateDisplay();
  }

  /// Input power (^)
  void inputPower() {
    inputOperator('^');
  }

  /// Square the current expression
  void inputSquare() {
    if (_expression.isNotEmpty && !_isError) {
      _expression = '($_expression)^2';
      _updateDisplay();
    }
  }

  /// Cube the current expression
  void inputCube() {
    if (_expression.isNotEmpty && !_isError) {
      _expression = '($_expression)^3';
      _updateDisplay();
    }
  }

  /// Square root
  void inputSqrt() {
    inputFunction('sqrt');
  }

  /// Cube root
  void inputCbrt() {
    inputFunction('cbrt');
  }

  /// Reciprocal (1/x)
  void inputReciprocal() {
    if (_expression.isNotEmpty && !_isError) {
      _expression = '1/($_expression)';
      _updateDisplay();
    }
  }

  /// Factorial
  void inputFactorial() {
    if (_isError) return;

    // Try to evaluate current expression first
    try {
      _evaluator.isRadianMode = _isRadianMode;
      final value = _evaluator.evaluate(_expression.isEmpty ? '0' : _expression);

      if (value < 0 || value != value.roundToDouble() || value > 170) {
        _setError('Invalid for factorial');
        return;
      }

      int n = value.toInt();
      double result = 1;
      for (int i = 2; i <= n; i++) {
        result *= i;
      }

      _expression = _formatResult(result);
      _lastResult = _expression;
      _hasJustEvaluated = true;
      _updateDisplay();
    } catch (e) {
      _setError('Error');
    }
  }

  /// Evaluate the expression
  void evaluate() {
    if (_expression.isEmpty) return;

    try {
      // Auto-close parentheses
      int openCount = _expression.split('(').length - 1;
      int closeCount = _expression.split(')').length - 1;
      String expr = _expression + ')' * (openCount - closeCount);

      _evaluator.isRadianMode = _isRadianMode;
      final result = _evaluator.evaluate(expr);

      if (result.isNaN || result.isInfinite) {
        _setError('Math error');
        return;
      }

      _lastResult = _formatResult(result);
      _expression = _lastResult;
      _hasJustEvaluated = true;
      _isError = false;
      _updateDisplay();
    } catch (e) {
      _setError(e.toString().replaceAll('FormatException: ', ''));
    }
  }

  /// Backspace - remove last character
  void backspace() {
    if (_isError) {
      clear();
      return;
    }

    if (_hasJustEvaluated) {
      // After evaluation, backspace clears all
      clear();
      return;
    }

    if (_expression.isNotEmpty) {
      // Check if we're deleting a function name
      final funcMatch = RegExp(r'(sin|cos|tan|asin|acos|atan|ln|log|sqrt|cbrt|abs|exp|sinh|cosh|tanh)\($').firstMatch(_expression);
      if (funcMatch != null) {
        _expression = _expression.substring(0, _expression.length - funcMatch.group(0)!.length);
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    }
    _updateDisplay();
  }

  /// Clear current entry
  void clear() {
    _expression = '';
    _displayValue = '0';
    _isError = false;
    _errorMessage = '';
    _hasJustEvaluated = false;
    notifyListeners();
  }

  /// Clear all including last result
  void allClear() {
    clear();
    _lastResult = '';
    notifyListeners();
  }

  /// Toggle between DEG and RAD mode
  void toggleAngleMode() {
    _isRadianMode = !_isRadianMode;
    notifyListeners();
  }

  /// Toggle sign of current number
  void toggleSign() {
    if (_isError) {
      clear();
      return;
    }

    if (_expression.isEmpty) return;

    if (_hasJustEvaluated) {
      // Negate the result
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
    } else {
      // Find the last number and negate it
      final numMatch = RegExp(r'-?[\d.]+$').firstMatch(_expression);
      if (numMatch != null) {
        final num = numMatch.group(0)!;
        final prefix = _expression.substring(0, numMatch.start);
        if (num.startsWith('-')) {
          _expression = prefix + num.substring(1);
        } else {
          _expression = '$prefix-$num';
        }
      }
    }
    _updateDisplay();
  }

  /// Calculate percentage
  void percentage() {
    if (_expression.isEmpty || _isError) return;

    try {
      _evaluator.isRadianMode = _isRadianMode;
      final value = _evaluator.evaluate(_expression);
      final result = value / 100;
      _expression = _formatResult(result);
      _hasJustEvaluated = true;
      _updateDisplay();
    } catch (e) {
      _setError('Error');
    }
  }

  void _setError(String message) {
    _isError = true;
    _errorMessage = message;
    _displayValue = 'Error';
    _hasJustEvaluated = false;
    notifyListeners();
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Handle integers
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }

    // Format with appropriate precision
    String result = value.toStringAsPrecision(10);

    // Remove trailing zeros
    if (result.contains('.') && !result.contains('e')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    // Use scientific notation for very large/small numbers
    if (result.length > 14) {
      result = value.toStringAsExponential(6);
    }

    return result;
  }

  bool _isDigit(String char) => '0123456789'.contains(char);
}
