/// Basic arithmetic operations
enum CalculatorOperation {
  add,
  subtract,
  multiply,
  divide,
}

extension CalculatorOperationExtension on CalculatorOperation {
  String get symbol {
    switch (this) {
      case CalculatorOperation.add:
        return '+';
      case CalculatorOperation.subtract:
        return '−';
      case CalculatorOperation.multiply:
        return '×';
      case CalculatorOperation.divide:
        return '÷';
    }
  }

  int get precedence {
    switch (this) {
      case CalculatorOperation.add:
      case CalculatorOperation.subtract:
        return 1;
      case CalculatorOperation.multiply:
      case CalculatorOperation.divide:
        return 2;
    }
  }
}
