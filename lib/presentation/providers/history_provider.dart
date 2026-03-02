import 'package:flutter/foundation.dart';
import '../../data/datasources/local/hive_boxes.dart';
import '../../data/models/calculation_history.dart';

/// Provider for managing calculation history with persistent storage
class HistoryProvider extends ChangeNotifier {
  static const int maxHistoryItems = 100;
  static const int maxHistoryDays = 30; // Keep history for 30 days

  List<CalculationHistory> _history = [];

  List<CalculationHistory> get history => List.unmodifiable(_history);
  bool get isEmpty => _history.isEmpty;
  int get count => _history.length;

  /// Initialize and load history from Hive
  Future<void> loadHistory() async {
    try {
      final box = HiveBoxes.historyBox;
      _history = box.values.toList();

      // Sort by timestamp (newest first)
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Clean up old entries
      await _cleanupOldEntries();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history = [];
    }
  }

  /// Add a calculation to history
  Future<void> addEntry(
    String expression,
    String result, {
    bool isScientific = false,
  }) async {
    // Don't add if expression or result is empty or error
    if (expression.isEmpty || result.isEmpty || result == 'Error') {
      return;
    }

    try {
      final entry = CalculationHistory(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
        mode: isScientific ? 'scientific' : 'basic',
      );

      // Save to Hive
      final box = HiveBoxes.historyBox;
      await box.add(entry);

      // Update in-memory list
      _history.insert(0, entry);

      // Limit history size
      await _enforceHistoryLimit();

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding history entry: $e');
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      final box = HiveBoxes.historyBox;
      await box.clear();
      _history.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  /// Get the last result (for ANS functionality)
  String? get lastResult => _history.isNotEmpty ? _history.first.result : null;

  /// Remove entries older than maxHistoryDays
  Future<void> _cleanupOldEntries() async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxHistoryDays));
    final oldEntries = _history.where((e) => e.timestamp.isBefore(cutoffDate)).toList();

    if (oldEntries.isNotEmpty) {
      for (final entry in oldEntries) {
        await entry.delete(); // Delete from Hive
        _history.remove(entry);
      }
    }
  }

  /// Enforce maximum history items limit
  Future<void> _enforceHistoryLimit() async {
    while (_history.length > maxHistoryItems) {
      final oldest = _history.removeLast();
      await oldest.delete(); // Delete from Hive
    }
  }

  /// Delete a specific entry
  Future<void> deleteEntry(CalculationHistory entry) async {
    try {
      await entry.delete();
      _history.remove(entry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting history entry: $e');
    }
  }

  /// Get history grouped by date
  Map<String, List<CalculationHistory>> get groupedHistory {
    final grouped = <String, List<CalculationHistory>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final entry in _history) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      String key;
      if (entryDate == today) {
        key = 'Today';
      } else if (entryDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = '${entryDate.day}/${entryDate.month}/${entryDate.year}';
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    return grouped;
  }
}
