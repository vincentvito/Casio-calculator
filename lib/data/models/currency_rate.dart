import 'package:hive/hive.dart';

part 'currency_rate.g.dart';

/// Currency exchange rate model
@HiveType(typeId: 1)
class CurrencyRate extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double rate; // Rate relative to base currency (usually USD)

  @HiveField(3)
  final DateTime timestamp;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
    required this.timestamp,
  });

  /// Check if rate is stale (older than 1 hour)
  bool get isStale {
    final age = DateTime.now().difference(timestamp);
    return age.inHours >= 1;
  }

  /// Check if rate is very stale (older than 24 hours)
  bool get isVeryStale {
    final age = DateTime.now().difference(timestamp);
    return age.inHours >= 24;
  }

  CurrencyRate copyWith({
    String? code,
    String? name,
    double? rate,
    DateTime? timestamp,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'CurrencyRate($code: $rate)';
}

/// Container for cached currency rates
@HiveType(typeId: 2)
class CachedRates extends HiveObject {
  @HiveField(0)
  final String baseCurrency;

  @HiveField(1)
  final List<CurrencyRate> rates;

  @HiveField(2)
  final DateTime fetchedAt;

  CachedRates({
    required this.baseCurrency,
    required this.rates,
    required this.fetchedAt,
  });

  Map<String, CurrencyRate> get ratesMap {
    return {for (var rate in rates) rate.code: rate};
  }

  bool get isStale {
    final age = DateTime.now().difference(fetchedAt);
    return age.inHours >= 1;
  }
}
