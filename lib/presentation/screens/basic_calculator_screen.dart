import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/enums.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/display/calculator_display.dart';
import '../widgets/buttons/calculator_button.dart';

/// Basic calculator screen with standard operations
class BasicCalculatorScreen extends StatelessWidget {
  const BasicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final calculator = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Display area
          const SizedBox(
            height: 160,
            child: CalculatorDisplay(),
          ),

          const SizedBox(height: 16),

          // Memory row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                CalculatorButton(
                  label: 'MC',
                  buttonType: ButtonType.memory,
                  onPressed: () => calculator.memoryClear(),
                ),
                CalculatorButton(
                  label: 'MR',
                  buttonType: ButtonType.memory,
                  onPressed: () => calculator.memoryRecall(),
                ),
                CalculatorButton(
                  label: 'M+',
                  buttonType: ButtonType.memory,
                  onPressed: () => calculator.memoryAdd(),
                ),
                CalculatorButton(
                  label: 'M−',
                  buttonType: ButtonType.memory,
                  onPressed: () => calculator.memorySubtract(),
                ),
              ],
            ),
          ),

          // Main button grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  // Row 1: AC, ±, %, ÷
                  Expanded(
                    child: Row(
                      children: [
                        CalculatorButton(
                          label: 'AC',
                          buttonType: ButtonType.clear,
                          onPressed: () => calculator.allClear(),
                        ),
                        CalculatorButton(
                          label: '±',
                          buttonType: ButtonType.function,
                          onPressed: () => calculator.toggleSign(),
                        ),
                        CalculatorButton(
                          label: '%',
                          buttonType: ButtonType.function,
                          onPressed: () => calculator.percentage(),
                        ),
                        CalculatorButton(
                          label: '÷',
                          buttonType: ButtonType.operation,
                          onPressed: () =>
                              calculator.inputOperation(CalculatorOperation.divide),
                        ),
                      ],
                    ),
                  ),

                  // Row 2: 7, 8, 9, ×
                  Expanded(
                    child: Row(
                      children: [
                        CalculatorButton(
                          label: '7',
                          onPressed: () => calculator.inputDigit('7'),
                        ),
                        CalculatorButton(
                          label: '8',
                          onPressed: () => calculator.inputDigit('8'),
                        ),
                        CalculatorButton(
                          label: '9',
                          onPressed: () => calculator.inputDigit('9'),
                        ),
                        CalculatorButton(
                          label: '×',
                          buttonType: ButtonType.operation,
                          onPressed: () =>
                              calculator.inputOperation(CalculatorOperation.multiply),
                        ),
                      ],
                    ),
                  ),

                  // Row 3: 4, 5, 6, −
                  Expanded(
                    child: Row(
                      children: [
                        CalculatorButton(
                          label: '4',
                          onPressed: () => calculator.inputDigit('4'),
                        ),
                        CalculatorButton(
                          label: '5',
                          onPressed: () => calculator.inputDigit('5'),
                        ),
                        CalculatorButton(
                          label: '6',
                          onPressed: () => calculator.inputDigit('6'),
                        ),
                        CalculatorButton(
                          label: '−',
                          buttonType: ButtonType.operation,
                          onPressed: () =>
                              calculator.inputOperation(CalculatorOperation.subtract),
                        ),
                      ],
                    ),
                  ),

                  // Row 4: 1, 2, 3, +
                  Expanded(
                    child: Row(
                      children: [
                        CalculatorButton(
                          label: '1',
                          onPressed: () => calculator.inputDigit('1'),
                        ),
                        CalculatorButton(
                          label: '2',
                          onPressed: () => calculator.inputDigit('2'),
                        ),
                        CalculatorButton(
                          label: '3',
                          onPressed: () => calculator.inputDigit('3'),
                        ),
                        CalculatorButton(
                          label: '+',
                          buttonType: ButtonType.operation,
                          onPressed: () =>
                              calculator.inputOperation(CalculatorOperation.add),
                        ),
                      ],
                    ),
                  ),

                  // Row 5: 0 (double), ., =
                  Expanded(
                    child: Row(
                      children: [
                        CalculatorButton(
                          label: '0',
                          flex: 2,
                          onPressed: () => calculator.inputDigit('0'),
                        ),
                        CalculatorButton(
                          label: '.',
                          onPressed: () => calculator.inputDecimal(),
                        ),
                        CalculatorButton(
                          label: '=',
                          buttonType: ButtonType.equals,
                          onPressed: () {
                            calculator.calculate();
                            // Record to history after calculation
                            if (calculator.expressionDisplay.endsWith('=')) {
                              history.addEntry(
                                calculator.expressionDisplay,
                                calculator.displayValue,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
