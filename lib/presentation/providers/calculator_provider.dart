import 'package:flutter/foundation.dart';
import '../../core/enums/enums.dart';
import '../../domain/engines/basic_calculator_engine.dart';

/// Provider for managing calculator state
class CalculatorProvider extends ChangeNotifier {
  final BasicCalculatorEngine _engine = BasicCalculatorEngine();

  // Display state
  String get displayValue => _engine.displayValue;
  String get expressionDisplay => _engine.expressionDisplay;
  bool get isError => _engine.isError;
  bool get hasMemory => _engine.hasMemory;
  CalculatorOperation? get currentOperation => _engine.currentOperation;
  bool get isWaitingForOperand2 => _engine.isWaitingForOperand2;

  /// Input a digit (0-9)
  void inputDigit(String digit) {
    _engine.inputDigit(digit);
    notifyListeners();
  }

  /// Input decimal point
  void inputDecimal() {
    _engine.inputDecimal();
    notifyListeners();
  }

  /// Input an operation (+, -, ×, ÷)
  void inputOperation(CalculatorOperation operation) {
    _engine.inputOperation(operation);
    notifyListeners();
  }

  /// Calculate result
  void calculate() {
    _engine.calculate();
    notifyListeners();
  }

  /// Clear current entry
  void clear() {
    _engine.clear();
    notifyListeners();
  }

  /// Clear all (reset calculator)
  void allClear() {
    _engine.allClear();
    notifyListeners();
  }

  /// Toggle sign (+/-)
  void toggleSign() {
    _engine.toggleSign();
    notifyListeners();
  }

  /// Calculate percentage
  void percentage() {
    _engine.percentage();
    notifyListeners();
  }

  /// Delete last digit (backspace)
  void backspace() {
    _engine.backspace();
    notifyListeners();
  }

  // Memory operations
  void memoryAdd() {
    _engine.memoryAdd();
    notifyListeners();
  }

  void memorySubtract() {
    _engine.memorySubtract();
    notifyListeners();
  }

  void memoryRecall() {
    _engine.memoryRecall();
    notifyListeners();
  }

  void memoryClear() {
    _engine.memoryClear();
    notifyListeners();
  }
}
