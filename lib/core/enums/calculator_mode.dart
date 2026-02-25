/// Available calculator modes
enum CalculatorMode {
  basic,
  scientific,
  unitConverter,
  currency,
}

extension CalculatorModeExtension on CalculatorMode {
  String get displayName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.unitConverter:
        return 'Units';
      case CalculatorMode.currency:
        return 'Currency';
    }
  }

  String get shortName {
    switch (this) {
      case CalculatorMode.basic:
        return 'CALC';
      case CalculatorMode.scientific:
        return 'SCI';
      case CalculatorMode.unitConverter:
        return 'UNIT';
      case CalculatorMode.currency:
        return 'FX';
    }
  }
}
