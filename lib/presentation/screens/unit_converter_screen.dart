import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/neumorphic_style.dart';
import '../../core/enums/unit_type.dart';
import '../providers/feedback_provider.dart';
import '../../theme/typography.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// Unit converter screen
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  UnitType _selectedType = UnitType.length;
  int _fromUnitIndex = 0;
  int _toUnitIndex = 1;
  String _inputValue = '0';

  List<dynamic> get _currentUnits {
    switch (_selectedType) {
      case UnitType.length:
        return LengthUnit.values;
      case UnitType.weight:
        return WeightUnit.values;
      case UnitType.temperature:
        return TemperatureUnit.values;
      case UnitType.volume:
        return VolumeUnit.values;
      case UnitType.area:
        return AreaUnit.values;
      case UnitType.speed:
        return SpeedUnit.values;
      case UnitType.time:
        return TimeUnit.values;
      case UnitType.data:
        return DataUnit.values;
    }
  }

  String _getUnitSymbol(dynamic unit) {
    if (unit is LengthUnit) return unit.symbol;
    if (unit is WeightUnit) return unit.symbol;
    if (unit is TemperatureUnit) return unit.symbol;
    if (unit is VolumeUnit) return unit.symbol;
    if (unit is AreaUnit) return unit.symbol;
    if (unit is SpeedUnit) return unit.symbol;
    if (unit is TimeUnit) return unit.symbol;
    if (unit is DataUnit) return unit.symbol;
    return '';
  }

  String _getUnitName(dynamic unit) {
    if (unit is LengthUnit) return unit.displayName;
    if (unit is WeightUnit) return unit.displayName;
    if (unit is TemperatureUnit) return unit.displayName;
    if (unit is VolumeUnit) return unit.displayName;
    if (unit is AreaUnit) return unit.displayName;
    if (unit is SpeedUnit) return unit.displayName;
    if (unit is TimeUnit) return unit.displayName;
    if (unit is DataUnit) return unit.displayName;
    return '';
  }

  double _getToBase(dynamic unit) {
    if (unit is LengthUnit) return unit.toBase;
    if (unit is WeightUnit) return unit.toBase;
    if (unit is VolumeUnit) return unit.toBase;
    if (unit is AreaUnit) return unit.toBase;
    if (unit is SpeedUnit) return unit.toBase;
    if (unit is TimeUnit) return unit.toBase;
    if (unit is DataUnit) return unit.toBase;
    return 1.0;
  }

  double get _convertedValue {
    final input = double.tryParse(_inputValue) ?? 0;
    final fromUnit = _currentUnits[_fromUnitIndex];
    final toUnit = _currentUnits[_toUnitIndex];

    // Special handling for temperature
    if (_selectedType == UnitType.temperature) {
      return _convertTemperature(input, fromUnit as TemperatureUnit, toUnit as TemperatureUnit);
    }

    // Standard conversion via base unit
    final fromBase = _getToBase(fromUnit);
    final toBase = _getToBase(toUnit);
    return input * fromBase / toBase;
  }

  double _convertTemperature(double value, TemperatureUnit from, TemperatureUnit to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case TemperatureUnit.celsius:
        celsius = value;
      case TemperatureUnit.fahrenheit:
        celsius = (value - 32) * 5 / 9;
      case TemperatureUnit.kelvin:
        celsius = value - 273.15;
    }

    // Convert from Celsius to target
    switch (to) {
      case TemperatureUnit.celsius:
        return celsius;
      case TemperatureUnit.fahrenheit:
        return celsius * 9 / 5 + 32;
      case TemperatureUnit.kelvin:
        return celsius + 273.15;
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnitIndex;
      _fromUnitIndex = _toUnitIndex;
      _toUnitIndex = temp;
    });
    context.read<FeedbackProvider>().mediumTap();
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_inputValue == '0' && digit != '0') {
        _inputValue = digit;
      } else if (_inputValue != '0') {
        _inputValue += digit;
      }
    });
    context.read<FeedbackProvider>().lightTap();
  }

  void _inputDecimal() {
    if (!_inputValue.contains('.')) {
      setState(() {
        _inputValue += '.';
      });
      context.read<FeedbackProvider>().lightTap();
    }
  }

  void _clear() {
    setState(() {
      _inputValue = '0';
    });
    context.read<FeedbackProvider>().mediumTap();
  }

  void _backspace() {
    setState(() {
      if (_inputValue.length > 1) {
        _inputValue = _inputValue.substring(0, _inputValue.length - 1);
      } else {
        _inputValue = '0';
      }
    });
    context.read<FeedbackProvider>().lightTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Unit type selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: UnitType.values.length,
              itemBuilder: (context, index) {
                final type = UnitType.values[index];
                final isSelected = type == _selectedType;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
                        _fromUnitIndex = 0;
                        _toUnitIndex = 1;
                        _inputValue = '0';
                      });
                      context.read<FeedbackProvider>().selectionClick();
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
                          type.displayName,
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

          const SizedBox(height: 16),

          // Conversion display
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // From unit
                Expanded(
                  child: _UnitCard(
                    unitSymbol: _getUnitSymbol(_currentUnits[_fromUnitIndex]),
                    unitName: _getUnitName(_currentUnits[_fromUnitIndex]),
                    value: _inputValue,
                    isInput: true,
                    onUnitTap: () => _showUnitPicker(true),
                  ),
                ),

                // Swap button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: _swapUnits,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        shape: BoxShape.circle,
                        boxShadow: theme.convexShadows,
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        color: theme.accentColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // To unit
                Expanded(
                  child: _UnitCard(
                    unitSymbol: _getUnitSymbol(_currentUnits[_toUnitIndex]),
                    unitName: _getUnitName(_currentUnits[_toUnitIndex]),
                    value: _formatNumber(_convertedValue),
                    isInput: false,
                    onUnitTap: () => _showUnitPicker(false),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Numeric keypad
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildKeypadRow(['7', '8', '9', 'C']),
                _buildKeypadRow(['4', '5', '6', '⌫']),
                _buildKeypadRow(['1', '2', '3', '']),
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
                buttonType: key == 'C' || key == '⌫'
                    ? ButtonType.function
                    : ButtonType.number,
                onPressed: () {
                  switch (key) {
                    case 'C':
                      _clear();
                    case '⌫':
                      _backspace();
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

  void _showUnitPicker(bool isFrom) {
    final theme = context.read<ThemeProvider>().neumorphicTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Unit',
              style: AppTypography.settingsTitle(theme.textPrimary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _currentUnits.length,
                itemBuilder: (context, index) {
                  final unit = _currentUnits[index];
                  final isSelected = isFrom
                      ? index == _fromUnitIndex
                      : index == _toUnitIndex;

                  return ListTile(
                    title: Text(
                      _getUnitSymbol(unit),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.accentColor : theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _getUnitName(unit),
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.accentColor)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromUnitIndex = index;
                        } else {
                          _toUnitIndex = index;
                        }
                      });
                      Navigator.pop(context);
                      context.read<FeedbackProvider>().selectionClick();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value.abs() < 0.0001 && value != 0) {
      return value.toStringAsExponential(4);
    }
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    if (value.abs() >= 1e6) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _UnitCard extends StatelessWidget {
  final String unitSymbol;
  final String unitName;
  final String value;
  final bool isInput;
  final VoidCallback onUnitTap;

  const _UnitCard({
    required this.unitSymbol,
    required this.unitName,
    required this.value,
    required this.isInput,
    required this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return NeumorphicContainer(
      style: isInput ? NeumorphicStyle.concave : NeumorphicStyle.convex,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Unit selector
          GestureDetector(
            onTap: onUnitTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    unitSymbol,
                    style: AppTypography.buttonMedium(theme.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Value display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: AppTypography.displayMedium(theme.textPrimary),
                  ),
                ),
                Text(
                  unitName,
                  style: AppTypography.label(theme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
