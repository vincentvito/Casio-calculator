import 'package:dio/dio.dart';

/// Service to fetch live currency exchange rates
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final Dio _fiatDio = Dio(BaseOptions(
    baseUrl: 'https://api.frankfurter.app',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final Dio _cryptoDio = Dio(BaseOptions(
    baseUrl: 'https://api.binance.com/api/v3',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Map<String, double>? _cachedRates;
  String? _cachedBase;
  DateTime? _cacheTime;

  // Cache duration: 30 seconds for crypto (real-time updates)
  static const _cacheDuration = Duration(seconds: 30);

  /// Cryptocurrencies supported
  static const List<String> cryptoCurrencies = ['BTC', 'ETH', 'SOL', 'XRP', 'DOGE'];

  /// Binance trading pair symbols
  static const Map<String, String> _cryptoSymbols = {
    'BTC': 'BTCUSDT',
    'ETH': 'ETHUSDT',
    'SOL': 'SOLUSDT',
    'XRP': 'XRPUSDT',
    'DOGE': 'DOGEUSDT',
  };

  /// Supported currencies (fiat + crypto)
  static const List<String> supportedCurrencies = [
    // Crypto first for visibility
    'BTC', 'ETH', 'SOL', 'XRP', 'DOGE',
    // Fiat currencies
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'MXN',
    'NZD', 'SGD', 'HKD', 'KRW', 'BRL', 'ZAR', 'SEK', 'NOK', 'DKK', 'PLN',
  ];

  /// Fiat-only currencies (for Frankfurter API)
  static const List<String> fiatCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY', 'INR', 'MXN',
    'NZD', 'SGD', 'HKD', 'KRW', 'BRL', 'ZAR', 'SEK', 'NOK', 'DKK', 'PLN',
  ];

  static const Map<String, String> currencyNames = {
    // Crypto
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'XRP': 'Ripple',
    'DOGE': 'Dogecoin',
    // Fiat
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
    // Crypto
    'BTC': '₿',
    'ETH': 'Ξ',
    'SOL': '◎',
    'XRP': '✕',
    'DOGE': 'Ð',
    // Fiat
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

  /// Currencies with no decimal places
  static const Set<String> noDecimalCurrencies = {'JPY', 'KRW'};

  /// Check if currency is crypto
  static bool isCrypto(String currency) => cryptoCurrencies.contains(currency);

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
      Map<String, double> rates = {};

      // Fetch crypto rates from CoinGecko (always in USD first)
      final cryptoRates = await _fetchCryptoRates();

      // Fetch fiat rates
      final fiatRates = await _fetchFiatRates(baseCurrency);

      // Combine rates based on base currency type
      if (isCrypto(baseCurrency)) {
        // Base is crypto - need to convert everything relative to this crypto
        final baseInUsd = cryptoRates[baseCurrency] ?? 1.0;

        // Add other cryptos relative to base
        for (final crypto in cryptoCurrencies) {
          final cryptoInUsd = cryptoRates[crypto] ?? 0.0;
          if (cryptoInUsd > 0 && baseInUsd > 0) {
            rates[crypto] = cryptoInUsd / baseInUsd;
          }
        }

        // Add fiat currencies relative to base crypto
        // 1 BASE_CRYPTO = baseInUsd USD, so 1 BASE_CRYPTO = baseInUsd * fiatRate FIAT
        final usdFiatRates = await _fetchFiatRates('USD');
        for (final fiat in fiatCurrencies) {
          final fiatRateFromUsd = usdFiatRates[fiat] ?? 1.0;
          rates[fiat] = baseInUsd * fiatRateFromUsd;
        }
      } else {
        // Base is fiat
        rates.addAll(fiatRates);

        // Add crypto rates relative to base fiat
        // cryptoRates[X] = price in USD
        // We need price in baseCurrency
        // If baseCurrency is EUR, and 1 USD = 0.92 EUR (from fiatRates perspective, it's inverted)
        // Actually fiatRates gives us: 1 BASE = X TARGET
        // So we need: 1 BASE = (1/cryptoRates[crypto]) * (fiatRates[USD] or 1 if base is USD)
        final usdRate = baseCurrency == 'USD' ? 1.0 : (fiatRates['USD'] ?? 1.0);

        for (final crypto in cryptoCurrencies) {
          final cryptoInUsd = cryptoRates[crypto] ?? 0.0;
          if (cryptoInUsd > 0) {
            // 1 baseCurrency = usdRate USD = usdRate/cryptoInUsd crypto
            rates[crypto] = usdRate / cryptoInUsd;
          }
        }
      }

      // Add base currency with rate 1.0
      rates[baseCurrency] = 1.0;

      // Update cache
      _cachedRates = rates;
      _cachedBase = baseCurrency;
      _cacheTime = DateTime.now();

      return rates;
    } catch (e) {
      // Return cached rates if available, even if expired
      if (_cachedRates != null && _cachedBase == baseCurrency) {
        return _cachedRates!;
      }
      rethrow;
    }
  }

  /// Fetch fiat rates from Frankfurter API
  Future<Map<String, double>> _fetchFiatRates(String baseCurrency) async {
    // If base is crypto, use USD as base for fiat
    final fiatBase = isCrypto(baseCurrency) ? 'USD' : baseCurrency;

    final response = await _fiatDio.get('/latest', queryParameters: {
      'from': fiatBase,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final rates = (data['rates'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble()));
      rates[fiatBase] = 1.0;
      return rates;
    }

    throw Exception('Failed to fetch fiat rates');
  }

  /// Fetch crypto rates from Binance (real-time prices in USD)
  Future<Map<String, double>> _fetchCryptoRates() async {
    // Fetch all ticker prices at once
    final response = await _cryptoDio.get('/ticker/price');

    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      final rates = <String, double>{};

      // Build a map of symbol -> price for quick lookup
      final priceMap = <String, double>{};
      for (final item in data) {
        final symbol = item['symbol'] as String;
        final price = double.tryParse(item['price'] as String) ?? 0.0;
        priceMap[symbol] = price;
      }

      // Map our crypto symbols to prices
      for (final entry in _cryptoSymbols.entries) {
        final crypto = entry.key;
        final binanceSymbol = entry.value;
        if (priceMap.containsKey(binanceSymbol)) {
          rates[crypto] = priceMap[binanceSymbol]!;
        }
      }

      return rates;
    }

    throw Exception('Failed to fetch crypto rates');
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

  /// Clear the cache (useful for refresh)
  void clearCache() {
    _cachedRates = null;
    _cachedBase = null;
    _cacheTime = null;
  }
}
