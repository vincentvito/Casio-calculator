import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/neumorphic_style.dart';
import '../../domain/services/currency_service.dart';
import '../../theme/typography.dart';
import '../providers/feedback_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// Currency converter screen with live exchange rates
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _inputValue = '0';

  Map<String, double> _rates = {};
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final rates = await _currencyService.getRates(_fromCurrency);
      setState(() {
        _rates = rates;
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  double get _convertedValue {
    final input = double.tryParse(_inputValue) ?? 0;
    if (_fromCurrency == _toCurrency) return input;

    final rate = _rates[_toCurrency];
    if (rate != null) {
      return input * rate;
    }
    return 0;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    context.read<FeedbackProvider>().mediumTap();
    _fetchRates(); // Refresh rates for new base currency
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
          // Status bar (loading/error/last updated)
          SizedBox(
            height: 24,
            child: _buildStatusBar(theme),
          ),

          const SizedBox(height: 8),

          // Conversion display
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // From currency
                Expanded(
                  child: _CurrencyCard(
                    currency: _fromCurrency,
                    currencyName: CurrencyService.currencyNames[_fromCurrency] ?? '',
                    symbol: CurrencyService.currencySymbols[_fromCurrency] ?? '',
                    value: _formatInputWithCommas(_inputValue),
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
                    currencyName: CurrencyService.currencyNames[_toCurrency] ?? '',
                    symbol: CurrencyService.currencySymbols[_toCurrency] ?? '',
                    value: _isLoading ? '...' : _formatNumber(_convertedValue, _toCurrency),
                    isInput: false,
                    onCurrencyTap: () => _showCurrencyPicker(false),
                    rate: _rates[_toCurrency],
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

  Widget _buildStatusBar(dynamic theme) {
    if (_isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Fetching live rates...',
            style: TextStyle(
              fontSize: 11,
              color: theme.textSecondary,
            ),
          ),
        ],
      );
    }

    if (_hasError) {
      return GestureDetector(
        onTap: _fetchRates,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 14, color: Colors.orange[400]),
            const SizedBox(width: 4),
            Text(
              'Using offline rates. Tap to retry.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange[400],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _fetchRates,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green[400]),
          const SizedBox(width: 4),
          Text(
            'Live rates • Tap to refresh',
            style: TextStyle(
              fontSize: 11,
              color: theme.textSecondary,
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
                itemCount: CurrencyService.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = CurrencyService.supportedCurrencies[index];
                  final isSelected = isFrom
                      ? currency == _fromCurrency
                      : currency == _toCurrency;

                  return ListTile(
                    leading: Text(
                      CurrencyService.currencySymbols[currency] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.textSecondary,
                      ),
                    ),
                    title: Text(
                      currency,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.accentColor : theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      CurrencyService.currencyNames[currency] ?? '',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.accentColor)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromCurrency = currency;
                          _fetchRates(); // Refresh rates for new base
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

  String _formatInputWithCommas(String input) {
    if (input == '0' || input.isEmpty) return input;
    return _addCommas(input, _fromCurrency);
  }

  String _formatNumber(double value, String currency) {
    // Show 2 decimal places, more for small values
    if (value.abs() < 0.01 && value != 0) {
      return value.toStringAsFixed(6);
    }

    String numStr;
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      numStr = value.toInt().toString();
    } else {
      numStr = value.toStringAsFixed(2);
    }

    return _addCommas(numStr, currency);
  }

  /// Currencies that use Indian numbering system (XX,XX,XXX)
  /// Used in India, Pakistan, Nepal, Sri Lanka, Bangladesh
  static const _indianSystemCurrencies = {'INR', 'PKR', 'NPR', 'LKR', 'BDT'};

  String _addCommas(String number, String currency) {
    // Split into integer and decimal parts
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Handle negative numbers
    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    String formatted;
    if (_indianSystemCurrencies.contains(currency)) {
      // Indian system: XX,XX,XXX (first comma after 3 digits, then every 2)
      formatted = _formatIndianSystem(digits);
    } else {
      // Western system: X,XXX,XXX (comma every 3 digits)
      formatted = _formatWesternSystem(digits);
    }

    return '${isNegative ? '-' : ''}$formatted$decimalPart';
  }

  /// Western number format: comma every 3 digits (1,234,567)
  String _formatWesternSystem(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Indian number format: first comma after 3 digits, then every 2 (12,34,567)
  String _formatIndianSystem(String digits) {
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    // First, handle the last 3 digits
    final lastThree = digits.substring(digits.length - 3);
    final remaining = digits.substring(0, digits.length - 3);

    // Format remaining digits with commas every 2 digits
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }

    // Add comma before last 3 digits
    if (remaining.isNotEmpty) {
      buffer.write(',');
    }
    buffer.write(lastThree);

    return buffer.toString();
  }
}

class _CurrencyCard extends StatelessWidget {
  final String currency;
  final String currencyName;
  final String symbol;
  final String value;
  final bool isInput;
  final VoidCallback onCurrencyTap;
  final double? rate;

  const _CurrencyCard({
    required this.currency,
    required this.currencyName,
    required this.symbol,
    required this.value,
    required this.isInput,
    required this.onCurrencyTap,
    this.rate,
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
                if (!isInput && rate != null)
                  Text(
                    '1 ${currency == 'USD' ? 'USD' : 'unit'} = ${rate!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
