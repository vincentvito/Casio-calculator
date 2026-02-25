import 'package:hive/hive.dart';

part 'calculation_history.g.dart';

/// History entry for calculations
@HiveType(typeId: 3)
class CalculationHistory extends HiveObject {
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String mode; // 'basic', 'scientific', 'unit', 'currency'

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.mode,
  });

  @override
  String toString() => '$expression = $result';
}
