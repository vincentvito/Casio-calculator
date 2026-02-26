import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/neumorphic_style.dart';
import '../../theme/typography.dart';
import '../providers/feedback_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// Currency converter screen
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _inputValue = '0';

  // Sample exchange rates (in a real app, these would come from an API)
  static const Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 148.50,
    'CHF': 0.88,
    'CAD': 1.35,
    'AUD': 1.53,
    'CNY': 7.24,
    'INR': 83.12,
    'MXN': 17.15,
  };

  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CHF': 'Swiss Franc',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'MXN': 'Mexican Peso',
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CNY': '¥',
    'INR': '₹',
    'MXN': '\$',
  };

  double get _convertedValue {
    final input = double.tryParse(_inputValue) ?? 0;
    final fromRate = _rates[_fromCurrency] ?? 1;
    final toRate = _rates[_toCurrency] ?? 1;
    return input / fromRate * toRate;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
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
          // Conversion display
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // From currency
                Expanded(
                  child: _CurrencyCard(
                    currency: _fromCurrency,
                    currencyName: _currencyNames[_fromCurrency]!,
                    symbol: _currencySymbols[_fromCurrency]!,
                    value: _inputValue,
                    isInput: true,
                    onCurrencyTap: () => _showCurrencyPicker(true),
                  ),
                ),

                // Swap button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: _swapCurrencies,
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

                // To currency
                Expanded(
                  child: _CurrencyCard(
                    currency: _toCurrency,
                    currencyName: _currencyNames[_toCurrency]!,
                    symbol: _currencySymbols[_toCurrency]!,
                    value: _formatNumber(_convertedValue),
                    isInput: false,
                    onCurrencyTap: () => _showCurrencyPicker(false),
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

  void _showCurrencyPicker(bool isFrom) {
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
              'Select Currency',
              style: AppTypography.settingsTitle(theme.textPrimary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _rates.length,
                itemBuilder: (context, index) {
                  final currency = _rates.keys.elementAt(index);
                  final isSelected = isFrom
                      ? currency == _fromCurrency
                      : currency == _toCurrency;

                  return ListTile(
                    title: Text(
                      currency,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.accentColor : theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _currencyNames[currency]!,
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.accentColor)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromCurrency = currency;
                        } else {
                          _toCurrency = currency;
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
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _CurrencyCard extends StatelessWidget {
  final String currency;
  final String currencyName;
  final String symbol;
  final String value;
  final bool isInput;
  final VoidCallback onCurrencyTap;

  const _CurrencyCard({
    required this.currency,
    required this.currencyName,
    required this.symbol,
    required this.value,
    required this.isInput,
    required this.onCurrencyTap,
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
          // Currency selector
          GestureDetector(
            onTap: onCurrencyTap,
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
                    currency,
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
                    '$symbol $value',
                    style: AppTypography.displayMedium(theme.textPrimary),
                  ),
                ),
                Text(
                  currencyName,
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
