import 'package:dio/dio.dart';

/// Service to fetch live currency exchange rates
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.frankfurter.app',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Map<String, double>? _cachedRates;
  String? _cachedBase;
  DateTime? _cacheTime;

  // Cache duration: 1 hour
  static const _cacheDuration = Duration(hours: 1);

  /// Supported currencies
  static const List<String> supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'MXN',
    'NZD', 'SGD', 'HKD', 'KRW', 'BRL', 'ZAR', 'SEK', 'NOK', 'DKK', 'PLN',
  ];

  static const Map<String, String> currencyNames = {
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
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'KRW': 'South Korean Won',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'DKK': 'Danish Krone',
    'PLN': 'Polish Zloty',
  };

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CNY': '¥',
    'INR': '₹',
    'MXN': 'MX\$',
    'NZD': 'NZ\$',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'KRW': '₩',
    'BRL': 'R\$',
    'ZAR': 'R',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
  };

  /// Fetch latest exchange rates for a base currency
  Future<Map<String, double>> getRates(String baseCurrency) async {
    // Check cache
    if (_cachedRates != null &&
        _cachedBase == baseCurrency &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedRates!;
    }

    try {
      final response = await _dio.get('/latest', queryParameters: {
        'from': baseCurrency,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = (data['rates'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

        // Add base currency with rate 1.0
        rates[baseCurrency] = 1.0;

        // Update cache
        _cachedRates = rates;
        _cachedBase = baseCurrency;
        _cacheTime = DateTime.now();

        return rates;
      }
    } catch (e) {
      // Return cached rates if available, even if expired
      if (_cachedRates != null && _cachedBase == baseCurrency) {
        return _cachedRates!;
      }
    }

    // Return fallback rates if API fails
    return _getFallbackRates(baseCurrency);
  }

  /// Convert amount between currencies
  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) return amount;

    final rates = await getRates(from);
    final rate = rates[to];

    if (rate != null) {
      return amount * rate;
    }

    // Fallback: try reverse conversion
    final reverseRates = await getRates(to);
    final reverseRate = reverseRates[from];

    if (reverseRate != null && reverseRate != 0) {
      return amount / reverseRate;
    }

    return amount; // No conversion possible
  }

  /// Fallback rates (approximate) when API is unavailable
  Map<String, double> _getFallbackRates(String baseCurrency) {
    // USD-based fallback rates
    const usdRates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.50,
      'CHF': 0.88,
      'CAD': 1.36,
      'AUD': 1.54,
      'CNY': 7.25,
      'INR': 83.50,
      'MXN': 17.20,
      'NZD': 1.67,
      'SGD': 1.34,
      'HKD': 7.82,
      'KRW': 1330.0,
      'BRL': 4.97,
      'ZAR': 18.50,
      'SEK': 10.45,
      'NOK': 10.65,
      'DKK': 6.88,
      'PLN': 4.02,
    };

    if (baseCurrency == 'USD') {
      return usdRates;
    }

    // Convert from USD rates to requested base
    final baseRateInUsd = usdRates[baseCurrency] ?? 1.0;
    return usdRates.map((key, value) => MapEntry(key, value / baseRateInUsd));
  }

  /// Clear the cache (useful for refresh)
  void clearCache() {
    _cachedRates = null;
    _cachedBase = null;
    _cacheTime = null;
  }
}
