/// Result of a calculation operation
class CalculationResult {
  final String display;
  final String? expression;
  final bool isError;
  final String? errorMessage;

  const CalculationResult({
    required this.display,
    this.expression,
    this.isError = false,
    this.errorMessage,
  });

  factory CalculationResult.success(String display, {String? expression}) {
    return CalculationResult(
      display: display,
      expression: expression,
      isError: false,
    );
  }

  factory CalculationResult.error(String message) {
    return CalculationResult(
      display: 'Error',
      isError: true,
      errorMessage: message,
    );
  }

  @override
  String toString() => isError ? 'Error: $errorMessage' : display;
}

/// Result from the calculator engine
class EngineResult {
  final String display;
  final String? expression;
  final bool isError;
  final String? operation;

  const EngineResult({
    required this.display,
    this.expression,
    this.isError = false,
    this.operation,
  });
}
