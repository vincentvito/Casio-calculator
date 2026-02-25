import '../../core/enums/calculator_operation.dart';

/// State machine states for the calculator
enum CalculatorState {
  initial,
  enteringOperand1,
  operationEntered,
  enteringOperand2,
  resultDisplayed,
  error,
}

/// Core calculator engine with state machine logic
class BasicCalculatorEngine {
  CalculatorState _state = CalculatorState.initial;
  String _displayBuffer = '0';
  String _expressionDisplay = '';
  double? _operand1;
  double? _operand2;
  CalculatorOperation? _pendingOperation;
  double _memory = 0;
  bool _hasMemory = false;
  bool _isError = false;

  // Maximum display digits
  static const int maxDigits = 12;

  // Getters
  String get displayValue => _displayBuffer;
  String get expressionDisplay => _expressionDisplay;
  bool get isError => _isError;
  bool get hasMemory => _hasMemory;
  CalculatorOperation? get currentOperation => _pendingOperation;
  CalculatorState get state => _state;
  bool get isWaitingForOperand2 => _state == CalculatorState.operationEntered;

  /// Input a digit (0-9)
  void inputDigit(String digit) {
    if (_isError) {
      allClear();
    }

    switch (_state) {
      case CalculatorState.initial:
      case CalculatorState.resultDisplayed:
        _displayBuffer = digit == '0' ? '0' : digit;
        _state = CalculatorState.enteringOperand1;
        _expressionDisplay = '';

      case CalculatorState.enteringOperand1:
        _appendDigit(digit);

      case CalculatorState.operationEntered:
        _displayBuffer = digit == '0' ? '0' : digit;
        _state = CalculatorState.enteringOperand2;

      case CalculatorState.enteringOperand2:
        _appendDigit(digit);

      case CalculatorState.error:
        allClear();
        _displayBuffer = digit == '0' ? '0' : digit;
        _state = CalculatorState.enteringOperand1;
    }
  }

  void _appendDigit(String digit) {
    // Check max length (accounting for decimal point and negative sign)
    final digitsOnly = _displayBuffer.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= maxDigits) return;

    if (_displayBuffer == '0' && digit != '0') {
      _displayBuffer = digit;
    } else if (_displayBuffer != '0' || digit != '0' || _displayBuffer.contains('.')) {
      if (_displayBuffer != '0') {
        _displayBuffer += digit;
      }
    }
  }

  /// Input decimal point
  void inputDecimal() {
    if (_isError) {
      allClear();
    }

    switch (_state) {
      case CalculatorState.initial:
      case CalculatorState.resultDisplayed:
        _displayBuffer = '0.';
        _state = CalculatorState.enteringOperand1;
        _expressionDisplay = '';

      case CalculatorState.enteringOperand1:
      case CalculatorState.enteringOperand2:
        if (!_displayBuffer.contains('.')) {
          _displayBuffer += '.';
        }

      case CalculatorState.operationEntered:
        _displayBuffer = '0.';
        _state = CalculatorState.enteringOperand2;

      case CalculatorState.error:
        allClear();
        _displayBuffer = '0.';
        _state = CalculatorState.enteringOperand1;
    }
  }

  /// Input an operation (+, -, ×, ÷)
  void inputOperation(CalculatorOperation operation) {
    if (_isError) {
      allClear();
      return;
    }

    switch (_state) {
      case CalculatorState.initial:
        _operand1 = 0;
        _pendingOperation = operation;
        _state = CalculatorState.operationEntered;
        _updateExpressionDisplay();

      case CalculatorState.enteringOperand1:
      case CalculatorState.resultDisplayed:
        _operand1 = _parseDisplay();
        _pendingOperation = operation;
        _state = CalculatorState.operationEntered;
        _updateExpressionDisplay();

      case CalculatorState.operationEntered:
        // Just change the operation
        _pendingOperation = operation;
        _updateExpressionDisplay();

      case CalculatorState.enteringOperand2:
        // Chain calculation
        _calculate();
        if (!_isError) {
          _operand1 = _parseDisplay();
          _pendingOperation = operation;
          _state = CalculatorState.operationEntered;
          _updateExpressionDisplay();
        }

      case CalculatorState.error:
        break;
    }
  }

  /// Calculate result
  void calculate() {
    if (_state != CalculatorState.enteringOperand2 &&
        _state != CalculatorState.operationEntered) {
      return;
    }

    _calculate();
    if (!_isError) {
      _state = CalculatorState.resultDisplayed;
    }
  }

  void _calculate() {
    if (_pendingOperation == null) return;

    _operand2 = _parseDisplay();
    if (_operand1 == null || _operand2 == null) return;

    double result;
    switch (_pendingOperation!) {
      case CalculatorOperation.add:
        result = _operand1! + _operand2!;
      case CalculatorOperation.subtract:
        result = _operand1! - _operand2!;
      case CalculatorOperation.multiply:
        result = _operand1! * _operand2!;
      case CalculatorOperation.divide:
        if (_operand2 == 0) {
          _setError('Cannot divide by zero');
          return;
        }
        result = _operand1! / _operand2!;
    }

    // Check for overflow
    if (result.isInfinite || result.isNaN) {
      _setError('Overflow');
      return;
    }

    _expressionDisplay =
        '${_formatNumber(_operand1!)} ${_pendingOperation!.symbol} ${_formatNumber(_operand2!)} =';
    _displayBuffer = _formatResult(result);
    _operand1 = result;
  }

  /// Clear current entry
  void clear() {
    _displayBuffer = '0';
    if (_state == CalculatorState.error) {
      allClear();
    }
  }

  /// Clear all (reset calculator)
  void allClear() {
    _state = CalculatorState.initial;
    _displayBuffer = '0';
    _expressionDisplay = '';
    _operand1 = null;
    _operand2 = null;
    _pendingOperation = null;
    _isError = false;
  }

  /// Toggle sign (+/-)
  void toggleSign() {
    if (_isError || _displayBuffer == '0') return;

    if (_displayBuffer.startsWith('-')) {
      _displayBuffer = _displayBuffer.substring(1);
    } else {
      _displayBuffer = '-$_displayBuffer';
    }
  }

  /// Calculate percentage
  void percentage() {
    if (_isError) return;

    final value = _parseDisplay();
    if (value == null) return;

    double result;
    if (_pendingOperation != null && _operand1 != null) {
      // Calculate as percentage of operand1
      result = _operand1! * value / 100;
    } else {
      // Just divide by 100
      result = value / 100;
    }

    _displayBuffer = _formatResult(result);
  }

  /// Delete last digit (backspace)
  void backspace() {
    if (_isError) {
      allClear();
      return;
    }

    if (_state == CalculatorState.resultDisplayed) {
      return; // Don't allow backspace after result
    }

    if (_displayBuffer.length > 1) {
      _displayBuffer = _displayBuffer.substring(0, _displayBuffer.length - 1);
      // Handle case where we're left with just a minus sign
      if (_displayBuffer == '-') {
        _displayBuffer = '0';
      }
    } else {
      _displayBuffer = '0';
    }
  }

  // Memory operations
  void memoryAdd() {
    final value = _parseDisplay();
    if (value != null) {
      _memory += value;
      _hasMemory = true;
    }
  }

  void memorySubtract() {
    final value = _parseDisplay();
    if (value != null) {
      _memory -= value;
      _hasMemory = true;
    }
  }

  void memoryRecall() {
    if (_hasMemory) {
      _displayBuffer = _formatResult(_memory);
      if (_state == CalculatorState.initial ||
          _state == CalculatorState.resultDisplayed) {
        _state = CalculatorState.enteringOperand1;
      }
    }
  }

  void memoryClear() {
    _memory = 0;
    _hasMemory = false;
  }

  // Helper methods
  double? _parseDisplay() {
    return double.tryParse(_displayBuffer);
  }

  void _setError(String message) {
    _isError = true;
    _state = CalculatorState.error;
    _displayBuffer = 'Error';
    _expressionDisplay = message;
  }

  void _updateExpressionDisplay() {
    if (_operand1 != null && _pendingOperation != null) {
      _expressionDisplay =
          '${_formatNumber(_operand1!)} ${_pendingOperation!.symbol}';
    }
  }

  String _formatNumber(double value) {
    // Remove trailing zeros
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _formatResult(double value) {
    // Handle integers
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }

    // Format with appropriate precision
    String result = value.toStringAsPrecision(10);

    // Remove trailing zeros after decimal point
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    // Check if result is too long and use scientific notation
    if (result.length > maxDigits) {
      result = value.toStringAsExponential(6);
    }

    return result;
  }
}
