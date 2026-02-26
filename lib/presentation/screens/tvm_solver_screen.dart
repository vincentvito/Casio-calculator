import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/enums/neumorphic_style.dart';
import '../../theme/typography.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// TVM (Time Value of Money) Solver
/// Solves for any one of: N, I/Y, PV, PMT, FV given the other four
class TVMSolverScreen extends StatefulWidget {
  const TVMSolverScreen({super.key});

  @override
  State<TVMSolverScreen> createState() => _TVMSolverScreenState();
}

enum TVMVariable { n, iy, pv, pmt, fv }

class _TVMSolverScreenState extends State<TVMSolverScreen> {
  // TVM Variables
  String _nValue = '';
  String _iyValue = '';
  String _pvValue = '';
  String _pmtValue = '';
  String _fvValue = '';

  // Currently selected variable for input
  TVMVariable _selectedVariable = TVMVariable.pv;

  // Which variable to solve for (null = none selected)
  TVMVariable? _solveFor;

  // Error message
  String? _errorMessage;

  String _getValueForVariable(TVMVariable variable) {
    switch (variable) {
      case TVMVariable.n:
        return _nValue;
      case TVMVariable.iy:
        return _iyValue;
      case TVMVariable.pv:
        return _pvValue;
      case TVMVariable.pmt:
        return _pmtValue;
      case TVMVariable.fv:
        return _fvValue;
    }
  }

  void _setValueForVariable(TVMVariable variable, String value) {
    setState(() {
      switch (variable) {
        case TVMVariable.n:
          _nValue = value;
        case TVMVariable.iy:
          _iyValue = value;
        case TVMVariable.pv:
          _pvValue = value;
        case TVMVariable.pmt:
          _pmtValue = value;
        case TVMVariable.fv:
          _fvValue = value;
      }
      _errorMessage = null;
    });
  }

  void _inputDigit(String digit) {
    final current = _getValueForVariable(_selectedVariable);
    String newValue;

    if (current.isEmpty && digit == '0') {
      newValue = '0';
    } else if (current == '0' && digit != '.') {
      newValue = digit;
    } else {
      newValue = current + digit;
    }

    _setValueForVariable(_selectedVariable, newValue);
    HapticFeedback.lightImpact();
  }

  void _inputDecimal() {
    final current = _getValueForVariable(_selectedVariable);
    if (!current.contains('.')) {
      _setValueForVariable(_selectedVariable, current.isEmpty ? '0.' : '$current.');
      HapticFeedback.lightImpact();
    }
  }

  void _toggleSign() {
    final current = _getValueForVariable(_selectedVariable);
    if (current.isEmpty) return;

    if (current.startsWith('-')) {
      _setValueForVariable(_selectedVariable, current.substring(1));
    } else {
      _setValueForVariable(_selectedVariable, '-$current');
    }
    HapticFeedback.lightImpact();
  }

  void _backspace() {
    final current = _getValueForVariable(_selectedVariable);
    if (current.isNotEmpty) {
      _setValueForVariable(_selectedVariable, current.substring(0, current.length - 1));
    }
    HapticFeedback.lightImpact();
  }

  void _clear() {
    _setValueForVariable(_selectedVariable, '');
    HapticFeedback.mediumImpact();
  }

  void _clearAll() {
    setState(() {
      _nValue = '';
      _iyValue = '';
      _pvValue = '';
      _pmtValue = '';
      _fvValue = '';
      _solveFor = null;
      _errorMessage = null;
    });
    HapticFeedback.heavyImpact();
  }

  void _solve() {
    HapticFeedback.mediumImpact();

    // Count how many variables have values
    int filledCount = 0;
    TVMVariable? emptyVariable;

    for (final variable in TVMVariable.values) {
      if (_getValueForVariable(variable).isNotEmpty) {
        filledCount++;
      } else {
        emptyVariable = variable;
      }
    }

    if (filledCount < 4) {
      setState(() {
        _errorMessage = 'Enter 4 values to solve';
      });
      return;
    }

    if (filledCount == 5) {
      setState(() {
        _errorMessage = 'Clear one value to solve';
      });
      return;
    }

    // Parse values
    final n = double.tryParse(_nValue);
    final iy = double.tryParse(_iyValue);
    final pv = double.tryParse(_pvValue);
    final pmt = double.tryParse(_pmtValue);
    final fv = double.tryParse(_fvValue);

    try {
      double? result;

      switch (emptyVariable!) {
        case TVMVariable.n:
          result = _solveForN(iy!, pv!, pmt!, fv!);
          _nValue = _formatResult(result);
        case TVMVariable.iy:
          result = _solveForIY(n!, pv!, pmt!, fv!);
          _iyValue = _formatResult(result);
        case TVMVariable.pv:
          result = _solveForPV(n!, iy!, pmt!, fv!);
          _pvValue = _formatResult(result);
        case TVMVariable.pmt:
          result = _solveForPMT(n!, iy!, pv!, fv!);
          _pmtValue = _formatResult(result);
        case TVMVariable.fv:
          result = _solveForFV(n!, iy!, pv!, pmt!);
          _fvValue = _formatResult(result);
      }

      setState(() {
        _solveFor = emptyVariable;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot solve with these values';
      });
    }
  }

  // TVM Formula: PV + PMT * ((1 - (1 + i)^-n) / i) + FV * (1 + i)^-n = 0
  // Where i = I/Y / 100 (as decimal)

  double _solveForN(double iy, double pv, double pmt, double fv) {
    final i = iy / 100;
    if (i == 0) {
      // Simple case: no interest
      return -(pv + fv) / pmt;
    }
    // n = -ln((pmt - i*fv) / (pmt + i*pv)) / ln(1+i)
    final numerator = pmt - i * fv;
    final denominator = pmt + i * pv;
    return -math.log(numerator / denominator) / math.log(1 + i);
  }

  double _solveForIY(double n, double pv, double pmt, double fv) {
    // Newton-Raphson method to solve for interest rate
    double i = 0.1; // Initial guess: 10%
    const maxIterations = 100;
    const tolerance = 1e-10;

    for (int iteration = 0; iteration < maxIterations; iteration++) {
      final f = _tvmEquation(n, i, pv, pmt, fv);
      final fPrime = _tvmDerivative(n, i, pv, pmt, fv);

      if (fPrime.abs() < tolerance) break;

      final newI = i - f / fPrime;

      if ((newI - i).abs() < tolerance) {
        return newI * 100; // Convert to percentage
      }

      i = newI;
    }

    return i * 100;
  }

  double _tvmEquation(double n, double i, double pv, double pmt, double fv) {
    if (i == 0) {
      return pv + pmt * n + fv;
    }
    final factor = math.pow(1 + i, -n);
    return pv + pmt * (1 - factor) / i + fv * factor;
  }

  double _tvmDerivative(double n, double i, double pv, double pmt, double fv) {
    if (i.abs() < 1e-10) {
      return pmt * n * (n + 1) / 2 - fv * n;
    }
    final factor = math.pow(1 + i, -n);
    final term1 = pmt * (factor * n / (i * (1 + i)) - (1 - factor) / (i * i));
    final term2 = -fv * n * factor / (1 + i);
    return term1 + term2;
  }

  double _solveForPV(double n, double iy, double pmt, double fv) {
    final i = iy / 100;
    if (i == 0) {
      return -pmt * n - fv;
    }
    final factor = math.pow(1 + i, -n);
    return -pmt * (1 - factor) / i - fv * factor;
  }

  double _solveForPMT(double n, double iy, double pv, double fv) {
    final i = iy / 100;
    if (i == 0) {
      return -(pv + fv) / n;
    }
    final factor = math.pow(1 + i, -n);
    return -(pv + fv * factor) * i / (1 - factor);
  }

  double _solveForFV(double n, double iy, double pv, double pmt) {
    final i = iy / 100;
    if (i == 0) {
      return -pv - pmt * n;
    }
    final factor = math.pow(1 + i, n);
    return -pv * factor - pmt * (factor - 1) / i;
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      throw Exception('Invalid result');
    }
    if (value == value.roundToDouble() && value.abs() < 1e10) {
      return value.toInt().toString();
    }
    // Round to 4 decimal places
    final rounded = (value * 10000).round() / 10000;
    String result = rounded.toString();
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // TVM Variables display
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _TVMRow(
                  label: 'N',
                  description: 'Number of periods',
                  value: _nValue,
                  isSelected: _selectedVariable == TVMVariable.n,
                  isSolved: _solveFor == TVMVariable.n,
                  onTap: () => setState(() => _selectedVariable = TVMVariable.n),
                ),
                _TVMRow(
                  label: 'I/Y',
                  description: 'Interest rate (%)',
                  value: _iyValue,
                  isSelected: _selectedVariable == TVMVariable.iy,
                  isSolved: _solveFor == TVMVariable.iy,
                  onTap: () => setState(() => _selectedVariable = TVMVariable.iy),
                ),
                _TVMRow(
                  label: 'PV',
                  description: 'Present Value',
                  value: _pvValue,
                  isSelected: _selectedVariable == TVMVariable.pv,
                  isSolved: _solveFor == TVMVariable.pv,
                  onTap: () => setState(() => _selectedVariable = TVMVariable.pv),
                ),
                _TVMRow(
                  label: 'PMT',
                  description: 'Payment',
                  value: _pmtValue,
                  isSelected: _selectedVariable == TVMVariable.pmt,
                  isSolved: _solveFor == TVMVariable.pmt,
                  onTap: () => setState(() => _selectedVariable = TVMVariable.pmt),
                ),
                _TVMRow(
                  label: 'FV',
                  description: 'Future Value',
                  value: _fvValue,
                  isSelected: _selectedVariable == TVMVariable.fv,
                  isSolved: _solveFor == TVMVariable.fv,
                  onTap: () => setState(() => _selectedVariable = TVMVariable.fv),
                ),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Keypad
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildKeypadRow(['7', '8', '9', 'CLR']),
                _buildKeypadRow(['4', '5', '6', '⌫']),
                _buildKeypadRow(['1', '2', '3', '±']),
                _buildKeypadRow(['0', '.', 'AC', 'SOLVE']),
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
          ButtonType buttonType;
          VoidCallback? onPressed;

          switch (key) {
            case 'SOLVE':
              buttonType = ButtonType.equals;
              onPressed = _solve;
            case 'CLR':
            case 'AC':
              buttonType = ButtonType.clear;
              onPressed = key == 'AC' ? _clearAll : _clear;
            case '⌫':
            case '±':
              buttonType = ButtonType.function;
              onPressed = key == '⌫' ? _backspace : _toggleSign;
            case '.':
              buttonType = ButtonType.number;
              onPressed = _inputDecimal;
            default:
              buttonType = ButtonType.number;
              onPressed = () => _inputDigit(key);
          }

          return Expanded(
            flex: key == 'SOLVE' ? 1 : 1,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: NeumorphicButton(
                label: key,
                buttonType: buttonType,
                onPressed: onPressed,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TVMRow extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final bool isSelected;
  final bool isSolved;
  final VoidCallback onTap;

  const _TVMRow({
    required this.label,
    required this.description,
    required this.value,
    required this.isSelected,
    required this.isSolved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: NeumorphicContainer(
            style: isSelected ? NeumorphicStyle.concave : NeumorphicStyle.flat,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Label
                Container(
                  width: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.accentColor.withAlpha(40)
                        : theme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected
                        ? Border.all(color: theme.accentColor, width: 1)
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? theme.accentColor : theme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(width: 12),

                // Description
                Expanded(
                  flex: 2,
                  child: Text(
                    description,
                    style: AppTypography.label(theme.textSecondary),
                  ),
                ),

                // Value
                Expanded(
                  flex: 3,
                  child: Text(
                    value.isEmpty ? '—' : value,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isSolved
                          ? theme.accentColor
                          : (value.isEmpty ? theme.textSecondary.withAlpha(100) : theme.textPrimary),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
