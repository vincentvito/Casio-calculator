import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/enums/enums.dart';
import '../providers/scientific_calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/buttons/calculator_button.dart';

/// Scientific calculator screen with expression support
class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  bool _isInverseMode = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScientificCalculatorProvider(),
      child: Consumer<ScientificCalculatorProvider>(
        builder: (context, calc, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Display area
                SizedBox(
                  height: 120,
                  child: _ScientificDisplay(
                    expression: calc.expression,
                    displayValue: calc.displayValue,
                    isError: calc.isError,
                  ),
                ),

                const SizedBox(height: 8),

                // Mode indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _ModeChip(
                        label: calc.isRadianMode ? 'RAD' : 'DEG',
                        isActive: calc.isRadianMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          calc.toggleAngleMode();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: '2nd',
                        isActive: _isInverseMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isInverseMode = !_isInverseMode);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Scientific function buttons
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        // Row 1: Scientific functions
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: _isInverseMode ? 'sin⁻¹' : 'sin',
                                onPressed: () => calc.inputFunction(
                                    _isInverseMode ? 'asin' : 'sin'),
                              ),
                              _ScientificButton(
                                label: _isInverseMode ? 'cos⁻¹' : 'cos',
                                onPressed: () => calc.inputFunction(
                                    _isInverseMode ? 'acos' : 'cos'),
                              ),
                              _ScientificButton(
                                label: _isInverseMode ? 'tan⁻¹' : 'tan',
                                onPressed: () => calc.inputFunction(
                                    _isInverseMode ? 'atan' : 'tan'),
                              ),
                              _ScientificButton(
                                label: 'π',
                                onPressed: () => calc.inputConstant('π'),
                              ),
                              _ScientificButton(
                                label: 'e',
                                onPressed: () => calc.inputConstant('e'),
                              ),
                            ],
                          ),
                        ),

                        // Row 2: More functions
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: _isInverseMode ? 'eˣ' : 'ln',
                                onPressed: () => _isInverseMode
                                    ? calc.inputFunction('exp')
                                    : calc.inputFunction('ln'),
                              ),
                              _ScientificButton(
                                label: _isInverseMode ? '10ˣ' : 'log',
                                onPressed: () {
                                  if (_isInverseMode) {
                                    calc.inputDigit('1');
                                    calc.inputDigit('0');
                                    calc.inputPower();
                                  } else {
                                    calc.inputFunction('log');
                                  }
                                },
                              ),
                              _ScientificButton(
                                label: 'x²',
                                onPressed: () => calc.inputSquare(),
                              ),
                              _ScientificButton(
                                label: _isInverseMode ? '³√' : 'x³',
                                onPressed: () => _isInverseMode
                                    ? calc.inputCbrt()
                                    : calc.inputCube(),
                              ),
                              _ScientificButton(
                                label: _isInverseMode ? 'ⁿ√' : 'xⁿ',
                                onPressed: () {
                                  if (_isInverseMode) {
                                    // For nth root: x^(1/n)
                                    calc.inputOperator('^');
                                    calc.inputLeftParen();
                                    calc.inputDigit('1');
                                    calc.inputOperator('÷');
                                  } else {
                                    calc.inputPower();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Row 3: More functions + Clear
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: '√',
                                onPressed: () => calc.inputSqrt(),
                              ),
                              _ScientificButton(
                                label: '1/x',
                                onPressed: () => calc.inputReciprocal(),
                              ),
                              _ScientificButton(
                                label: 'n!',
                                onPressed: () => calc.inputFactorial(),
                              ),
                              CalculatorButton(
                                label: 'AC',
                                buttonType: ButtonType.clear,
                                onPressed: () => calc.allClear(),
                              ),
                              CalculatorButton(
                                label: '÷',
                                buttonType: ButtonType.operation,
                                onPressed: () => calc.inputOperator('÷'),
                              ),
                            ],
                          ),
                        ),

                        // Row 4: (, 7, 8, 9, ×
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: '(',
                                onPressed: () => calc.inputLeftParen(),
                              ),
                              CalculatorButton(
                                label: '7',
                                onPressed: () => calc.inputDigit('7'),
                              ),
                              CalculatorButton(
                                label: '8',
                                onPressed: () => calc.inputDigit('8'),
                              ),
                              CalculatorButton(
                                label: '9',
                                onPressed: () => calc.inputDigit('9'),
                              ),
                              CalculatorButton(
                                label: '×',
                                buttonType: ButtonType.operation,
                                onPressed: () => calc.inputOperator('×'),
                              ),
                            ],
                          ),
                        ),

                        // Row 5: ), 4, 5, 6, −
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: ')',
                                onPressed: () => calc.inputRightParen(),
                              ),
                              CalculatorButton(
                                label: '4',
                                onPressed: () => calc.inputDigit('4'),
                              ),
                              CalculatorButton(
                                label: '5',
                                onPressed: () => calc.inputDigit('5'),
                              ),
                              CalculatorButton(
                                label: '6',
                                onPressed: () => calc.inputDigit('6'),
                              ),
                              CalculatorButton(
                                label: '−',
                                buttonType: ButtonType.operation,
                                onPressed: () => calc.inputOperator('-'),
                              ),
                            ],
                          ),
                        ),

                        // Row 6: %, 1, 2, 3, +
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: '%',
                                onPressed: () => calc.percentage(),
                              ),
                              CalculatorButton(
                                label: '1',
                                onPressed: () => calc.inputDigit('1'),
                              ),
                              CalculatorButton(
                                label: '2',
                                onPressed: () => calc.inputDigit('2'),
                              ),
                              CalculatorButton(
                                label: '3',
                                onPressed: () => calc.inputDigit('3'),
                              ),
                              CalculatorButton(
                                label: '+',
                                buttonType: ButtonType.operation,
                                onPressed: () => calc.inputOperator('+'),
                              ),
                            ],
                          ),
                        ),

                        // Row 7: ±, 0, ., ⌫, =
                        Expanded(
                          child: Row(
                            children: [
                              _ScientificButton(
                                label: '±',
                                onPressed: () => calc.toggleSign(),
                              ),
                              CalculatorButton(
                                label: '0',
                                onPressed: () => calc.inputDigit('0'),
                              ),
                              CalculatorButton(
                                label: '.',
                                onPressed: () => calc.inputDecimal(),
                              ),
                              CalculatorButton(
                                label: '⌫',
                                buttonType: ButtonType.function,
                                onPressed: () => calc.backspace(),
                              ),
                              CalculatorButton(
                                label: '=',
                                buttonType: ButtonType.equals,
                                onPressed: () {
                                  final expression = calc.displayValue;
                                  calc.evaluate();
                                  // Record to history
                                  if (!calc.isError) {
                                    context.read<HistoryProvider>().addEntry(
                                      expression,
                                      calc.displayValue,
                                      isScientific: true,
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
        },
      ),
    );
  }
}

class _ScientificDisplay extends StatelessWidget {
  final String expression;
  final String displayValue;
  final bool isError;

  const _ScientificDisplay({
    required this.expression,
    required this.displayValue,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return NeumorphicContainer(
      style: NeumorphicStyle.concave,
      borderRadius: 16,
      color: theme.displayBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Expression (scrollable with fixed font size)
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _formatExpression(displayValue),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: isError ? Colors.red[400] : theme.displayText,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  String _formatExpression(String expr) {
    // Make expression more readable
    return expr
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll('sqrt', '√')
        .replaceAll('cbrt', '³√');
  }
}

class _ScientificButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _ScientificButton({
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CalculatorButton(
      label: label,
      buttonType: ButtonType.function,
      onPressed: onPressed,
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.accentColor.withAlpha(50) : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? theme.accentColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? theme.accentColor : theme.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
