import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/enums/neumorphic_style.dart';
import '../../theme/typography.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// Types of percentage calculations
enum PercentageMode {
  whatIsXPercentOfY, // What is X% of Y?
  xIsWhatPercentOfY, // X is what % of Y?
  percentageChange, // % change from X to Y
}

extension PercentageModeExtension on PercentageMode {
  String get displayName {
    switch (this) {
      case PercentageMode.whatIsXPercentOfY:
        return 'X% of Y';
      case PercentageMode.xIsWhatPercentOfY:
        return 'X is ?% of Y';
      case PercentageMode.percentageChange:
        return '% Change';
    }
  }

  String get description {
    switch (this) {
      case PercentageMode.whatIsXPercentOfY:
        return 'What is X% of Y?';
      case PercentageMode.xIsWhatPercentOfY:
        return 'X is what percent of Y?';
      case PercentageMode.percentageChange:
        return 'Percentage change from X to Y';
    }
  }
}

/// Percentage calculator screen with guided input
class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() =>
      _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState
    extends State<PercentageCalculatorScreen> {
  PercentageMode _mode = PercentageMode.whatIsXPercentOfY;
  String _valueX = '0';
  String _valueY = '0';
  bool _editingX = true; // Which field is currently being edited

  double get _result {
    final x = double.tryParse(_valueX) ?? 0;
    final y = double.tryParse(_valueY) ?? 0;

    switch (_mode) {
      case PercentageMode.whatIsXPercentOfY:
        // What is X% of Y?
        return (x / 100) * y;
      case PercentageMode.xIsWhatPercentOfY:
        // X is what % of Y?
        if (y == 0) return 0;
        return (x / y) * 100;
      case PercentageMode.percentageChange:
        // % change from X to Y
        if (x == 0) return 0;
        return ((y - x) / x) * 100;
    }
  }

  String get _resultLabel {
    switch (_mode) {
      case PercentageMode.whatIsXPercentOfY:
        return 'Result';
      case PercentageMode.xIsWhatPercentOfY:
        return 'Percentage';
      case PercentageMode.percentageChange:
        return 'Change';
    }
  }

  String get _resultSuffix {
    switch (_mode) {
      case PercentageMode.whatIsXPercentOfY:
        return '';
      case PercentageMode.xIsWhatPercentOfY:
      case PercentageMode.percentageChange:
        return '%';
    }
  }

  String get _labelX {
    switch (_mode) {
      case PercentageMode.whatIsXPercentOfY:
        return 'Percent (%)';
      case PercentageMode.xIsWhatPercentOfY:
        return 'Value';
      case PercentageMode.percentageChange:
        return 'From';
    }
  }

  String get _labelY {
    switch (_mode) {
      case PercentageMode.whatIsXPercentOfY:
        return 'Of Value';
      case PercentageMode.xIsWhatPercentOfY:
        return 'Of Total';
      case PercentageMode.percentageChange:
        return 'To';
    }
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_editingX) {
        if (_valueX == '0' && digit != '0') {
          _valueX = digit;
        } else if (_valueX != '0') {
          _valueX += digit;
        }
      } else {
        if (_valueY == '0' && digit != '0') {
          _valueY = digit;
        } else if (_valueY != '0') {
          _valueY += digit;
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _inputDecimal() {
    setState(() {
      if (_editingX) {
        if (!_valueX.contains('.')) {
          _valueX += '.';
        }
      } else {
        if (!_valueY.contains('.')) {
          _valueY += '.';
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _clearAll() {
    setState(() {
      _valueX = '0';
      _valueY = '0';
    });
    HapticFeedback.mediumImpact();
  }

  void _backspace() {
    setState(() {
      if (_editingX) {
        if (_valueX.length > 1) {
          _valueX = _valueX.substring(0, _valueX.length - 1);
        } else {
          _valueX = '0';
        }
      } else {
        if (_valueY.length > 1) {
          _valueY = _valueY.substring(0, _valueY.length - 1);
        } else {
          _valueY = '0';
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _toggleSign() {
    setState(() {
      if (_editingX) {
        if (_valueX.startsWith('-')) {
          _valueX = _valueX.substring(1);
        } else if (_valueX != '0') {
          _valueX = '-$_valueX';
        }
      } else {
        if (_valueY.startsWith('-')) {
          _valueY = _valueY.substring(1);
        } else if (_valueY != '0') {
          _valueY = '-$_valueY';
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Mode selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: PercentageMode.values.length,
              itemBuilder: (context, index) {
                final mode = PercentageMode.values[index];
                final isSelected = mode == _mode;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mode = mode;
                        _valueX = '0';
                        _valueY = '0';
                        _editingX = true;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.accentColor.withAlpha(30)
                            : theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.accentColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mode.displayName,
                          style: AppTypography.label(
                            isSelected ? theme.accentColor : theme.textSecondary,
                          ).copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Question display
          Text(
            _mode.description,
            style: AppTypography.label(theme.textSecondary),
          ),

          const SizedBox(height: 12),

          // Input fields and result
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Value X input
                Expanded(
                  child: _ValueCard(
                    label: _labelX,
                    value: _valueX,
                    suffix: _mode == PercentageMode.whatIsXPercentOfY ? '%' : '',
                    isActive: _editingX,
                    onTap: () {
                      setState(() => _editingX = true);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Value Y input
                Expanded(
                  child: _ValueCard(
                    label: _labelY,
                    value: _valueY,
                    suffix: '',
                    isActive: !_editingX,
                    onTap: () {
                      setState(() => _editingX = false);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Result display
                Expanded(
                  child: _ResultCard(
                    label: _resultLabel,
                    value: _formatNumber(_result),
                    suffix: _resultSuffix,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Numeric keypad
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildKeypadRow(['7', '8', '9', 'AC']),
                _buildKeypadRow(['4', '5', '6', '⌫']),
                _buildKeypadRow(['1', '2', '3', '±']),
                _buildKeypadRow(['0', '.', '', '']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          if (key.isEmpty) {
            return const Expanded(child: SizedBox());
          }
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: NeumorphicButton(
                label: key,
                buttonType: key == 'AC' || key == '⌫' || key == '±'
                    ? ButtonType.function
                    : ButtonType.number,
                onPressed: () {
                  switch (key) {
                    case 'AC':
                      _clearAll();
                    case '⌫':
                      _backspace();
                    case '±':
                      _toggleSign();
                    case '.':
                      _inputDecimal();
                    default:
                      _inputDigit(key);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return '—';
    }
    if (value.abs() < 0.0001 && value != 0) {
      return value.toStringAsExponential(4);
    }
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    if (value.abs() >= 1e6) {
      return value.toStringAsExponential(4);
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class _ValueCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final bool isActive;
  final VoidCallback onTap;

  const _ValueCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        style: isActive ? NeumorphicStyle.concave : NeumorphicStyle.flat,
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.accentColor.withAlpha(30)
                    : theme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? theme.accentColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: AppTypography.label(
                  isActive ? theme.accentColor : theme.textSecondary,
                ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Value display
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: AppTypography.displayMedium(
                          isActive ? theme.textPrimary : theme.textSecondary,
                        ),
                      ),
                      if (suffix.isNotEmpty)
                        Text(
                          suffix,
                          style: AppTypography.label(
                            isActive
                                ? theme.textPrimary.withAlpha(180)
                                : theme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Active indicator
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return NeumorphicContainer(
      style: NeumorphicStyle.convex,
      borderRadius: 16,
      color: theme.displayBackground,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.displayBackground.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: AppTypography.label(theme.displayTextDim),
            ),
          ),

          const SizedBox(width: 12),

          // Result value
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: theme.displayText,
                        letterSpacing: 1,
                      ),
                    ),
                    if (suffix.isNotEmpty)
                      Text(
                        suffix,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.displayText.withAlpha(180),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
