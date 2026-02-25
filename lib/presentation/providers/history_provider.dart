import 'package:flutter/foundation.dart';

/// Represents a single calculation in history
class CalculationEntry {
  final String expression;
  final String result;
  final DateTime timestamp;
  final bool isScientific;

  CalculationEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isScientific = false,
  });
}

/// Provider for managing calculation history
class HistoryProvider extends ChangeNotifier {
  final List<CalculationEntry> _history = [];
  static const int maxHistoryItems = 50;

  List<CalculationEntry> get history => List.unmodifiable(_history);
  bool get isEmpty => _history.isEmpty;
  int get count => _history.length;

  /// Add a calculation to history
  void addEntry(String expression, String result, {bool isScientific = false}) {
    // Don't add if expression or result is empty or error
    if (expression.isEmpty || result.isEmpty || result == 'Error') {
      return;
    }

    _history.insert(
      0,
      CalculationEntry(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
        isScientific: isScientific,
      ),
    );

    // Limit history size
    if (_history.length > maxHistoryItems) {
      _history.removeLast();
    }

    notifyListeners();
  }

  /// Clear all history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /// Get the last result (for ANS functionality)
  String? get lastResult => _history.isNotEmpty ? _history.first.result : null;
}
