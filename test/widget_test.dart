import 'package:flutter_test/flutter_test.dart';
import 'package:skeuo_calc/core/enums/calculator_operation.dart';
import 'package:skeuo_calc/domain/engines/basic_calculator_engine.dart';

void main() {
  group('BasicCalculatorEngine', () {
    late BasicCalculatorEngine engine;

    setUp(() {
      engine = BasicCalculatorEngine();
    });

    test('initial state shows 0', () {
      expect(engine.displayValue, '0');
    });

    test('inputting digits updates display', () {
      engine.inputDigit('1');
      engine.inputDigit('2');
      engine.inputDigit('3');
      expect(engine.displayValue, '123');
    });

    test('basic addition works', () {
      engine.inputDigit('5');
      engine.inputOperation(CalculatorOperation.add);
      engine.inputDigit('3');
      engine.calculate();
      expect(engine.displayValue, '8');
    });

    test('basic subtraction works', () {
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputOperation(CalculatorOperation.subtract);
      engine.inputDigit('3');
      engine.calculate();
      expect(engine.displayValue, '7');
    });

    test('basic multiplication works', () {
      engine.inputDigit('6');
      engine.inputOperation(CalculatorOperation.multiply);
      engine.inputDigit('7');
      engine.calculate();
      expect(engine.displayValue, '42');
    });

    test('basic division works', () {
      engine.inputDigit('1');
      engine.inputDigit('5');
      engine.inputOperation(CalculatorOperation.divide);
      engine.inputDigit('3');
      engine.calculate();
      expect(engine.displayValue, '5');
    });

    test('division by zero shows error', () {
      engine.inputDigit('5');
      engine.inputOperation(CalculatorOperation.divide);
      engine.inputDigit('0');
      engine.calculate();
      expect(engine.isError, true);
    });

    test('clear resets display to 0', () {
      engine.inputDigit('1');
      engine.inputDigit('2');
      engine.inputDigit('3');
      engine.clear();
      expect(engine.displayValue, '0');
    });

    test('all clear resets everything', () {
      engine.inputDigit('5');
      engine.inputOperation(CalculatorOperation.add);
      engine.inputDigit('3');
      engine.allClear();
      expect(engine.displayValue, '0');
      expect(engine.currentOperation, null);
    });
  });
}
