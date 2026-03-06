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

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> with SingleTickerProviderStateMixin {
  final CurrencyService _currencyService = CurrencyService();
  late TabController _tabController;

  // Crypto tab state
  String _cryptoFrom = 'BTC';
  String _cryptoTo = 'USD';
  String _cryptoInput = '0';
  Map<String, double> _cryptoRates = {};
  bool _cryptoLoading = true;
  bool _cryptoError = false;

  // Fiat tab state
  String _fiatFrom = 'USD';
  String _fiatTo = 'EUR';
  String _fiatInput = '0';
  Map<String, double> _fiatRates = {};
  bool _fiatLoading = true;
  bool _fiatError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchCryptoRates();
    _fetchFiatRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      context.read<FeedbackProvider>().lightTap();
    }
  }

  Future<void> _fetchCryptoRates() async {
    setState(() {
      _cryptoLoading = true;
      _cryptoError = false;
    });

    try {
      final rates = await _currencyService.getRates(_cryptoFrom);
      setState(() {
        _cryptoRates = rates;
        _cryptoLoading = false;
      });
    } catch (e) {
      setState(() {
        _cryptoLoading = false;
        _cryptoError = true;
      });
    }
  }

  Future<void> _fetchFiatRates() async {
    setState(() {
      _fiatLoading = true;
      _fiatError = false;
    });

    try {
      final rates = await _currencyService.getRates(_fiatFrom);
      setState(() {
        _fiatRates = rates;
        _fiatLoading = false;
      });
    } catch (e) {
      setState(() {
        _fiatLoading = false;
        _fiatError = true;
      });
    }
  }

  bool get _isCryptoTab => _tabController.index == 1;

  String get _fromCurrency => _isCryptoTab ? _cryptoFrom : _fiatFrom;
  String get _toCurrency => _isCryptoTab ? _cryptoTo : _fiatTo;
  String get _inputValue => _isCryptoTab ? _cryptoInput : _fiatInput;
  Map<String, double> get _rates => _isCryptoTab ? _cryptoRates : _fiatRates;
  bool get _isLoading => _isCryptoTab ? _cryptoLoading : _fiatLoading;
  bool get _hasError => _isCryptoTab ? _cryptoError : _fiatError;

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
      if (_isCryptoTab) {
        final temp = _cryptoFrom;
        _cryptoFrom = _cryptoTo;
        _cryptoTo = temp;
      } else {
        final temp = _fiatFrom;
        _fiatFrom = _fiatTo;
        _fiatTo = temp;
      }
    });
    context.read<FeedbackProvider>().mediumTap();
    if (_isCryptoTab) {
      _fetchCryptoRates();
    } else {
      _fetchFiatRates();
    }
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_isCryptoTab) {
        if (_cryptoInput == '0' && digit != '0') {
          _cryptoInput = digit;
        } else if (_cryptoInput != '0') {
          _cryptoInput += digit;
        }
      } else {
        if (_fiatInput == '0' && digit != '0') {
          _fiatInput = digit;
        } else if (_fiatInput != '0') {
          _fiatInput += digit;
        }
      }
    });
    context.read<FeedbackProvider>().lightTap();
  }

  void _inputDecimal() {
    final currentInput = _isCryptoTab ? _cryptoInput : _fiatInput;
    if (!currentInput.contains('.')) {
      setState(() {
        if (_isCryptoTab) {
          _cryptoInput += '.';
        } else {
          _fiatInput += '.';
        }
      });
      context.read<FeedbackProvider>().lightTap();
    }
  }

  void _clear() {
    setState(() {
      if (_isCryptoTab) {
        _cryptoInput = '0';
      } else {
        _fiatInput = '0';
      }
    });
    context.read<FeedbackProvider>().mediumTap();
  }

  void _backspace() {
    setState(() {
      if (_isCryptoTab) {
        if (_cryptoInput.length > 1) {
          _cryptoInput = _cryptoInput.substring(0, _cryptoInput.length - 1);
        } else {
          _cryptoInput = '0';
        }
      } else {
        if (_fiatInput.length > 1) {
          _fiatInput = _fiatInput.substring(0, _fiatInput.length - 1);
        } else {
          _fiatInput = '0';
        }
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
          // Tab bar
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: theme.backgroundColor,
              unselectedLabelColor: theme.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Tab(text: 'Currency'),
                Tab(text: 'Crypto'),
              ],
              onTap: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 4),

          // Status bar (loading/error/last updated)
          SizedBox(
            height: 20,
            child: _buildStatusBar(theme),
          ),

          const SizedBox(height: 4),

          // Conversion display
          Expanded(
            flex: 3,
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: _swapCurrencies,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        shape: BoxShape.circle,
                        boxShadow: theme.convexShadows,
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        color: theme.accentColor,
                        size: 20,
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
                    value: _isLoading ? '...' : (_hasError ? '--' : _formatNumber(_convertedValue, _toCurrency)),
                    isInput: false,
                    onCurrencyTap: () => _showCurrencyPicker(false),
                    rate: _hasError ? null : _rates[_toCurrency],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Numeric keypad
          Expanded(
            flex: 4,
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

  void _refreshCurrentTab() {
    if (_isCryptoTab) {
      _fetchCryptoRates();
    } else {
      _fetchFiatRates();
    }
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
        onTap: _refreshCurrentTab,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
            const SizedBox(width: 4),
            Text(
              'Unable to fetch rates. Tap to retry.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _refreshCurrentTab,
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

    // Get currencies based on current tab
    final currencies = _isCryptoTab
        ? [...CurrencyService.cryptoCurrencies, ...CurrencyService.fiatCurrencies]
        : CurrencyService.fiatCurrencies;

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
              _isCryptoTab ? 'Select Crypto / Currency' : 'Select Currency',
              style: AppTypography.settingsTitle(theme.textPrimary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = isFrom
                      ? currency == _fromCurrency
                      : currency == _toCurrency;
                  final isCrypto = CurrencyService.isCrypto(currency);

                  return ListTile(
                    leading: Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text(
                        CurrencyService.currencySymbols[currency] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          color: isCrypto ? theme.accentColor : theme.textSecondary,
                        ),
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
                        if (_isCryptoTab) {
                          if (isFrom) {
                            _cryptoFrom = currency;
                            _fetchCryptoRates();
                          } else {
                            _cryptoTo = currency;
                          }
                        } else {
                          if (isFrom) {
                            _fiatFrom = currency;
                            _fetchFiatRates();
                          } else {
                            _fiatTo = currency;
                          }
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
    // Crypto currencies need more decimal places
    final isCrypto = CurrencyService.isCrypto(currency);
    // JPY, KRW don't use decimals
    final noDecimals = CurrencyService.noDecimalCurrencies.contains(currency);

    String numStr;

    if (isCrypto) {
      // Crypto: show up to 8 decimals for small values, fewer for large
      if (value.abs() < 0.00000001 && value != 0) {
        numStr = value.toStringAsFixed(10);
      } else if (value.abs() < 0.0001 && value != 0) {
        numStr = value.toStringAsFixed(8);
      } else if (value.abs() < 1) {
        numStr = value.toStringAsFixed(6);
      } else if (value.abs() < 100) {
        numStr = value.toStringAsFixed(4);
      } else {
        numStr = value.toStringAsFixed(2);
      }
      // Trim trailing zeros after decimal
      if (numStr.contains('.')) {
        numStr = numStr.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } else if (noDecimals) {
      // No decimals for JPY, KRW
      numStr = value.round().toString();
    } else {
      // Standard fiat: 2 decimal places, more for very small values
      if (value.abs() < 0.01 && value != 0) {
        numStr = value.toStringAsFixed(6);
      } else if (value == value.roundToDouble() && value.abs() < 1e12) {
        numStr = value.toInt().toString();
      } else {
        numStr = value.toStringAsFixed(2);
      }
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
