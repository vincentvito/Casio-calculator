import 'package:hive_flutter/hive_flutter.dart';
import '../../models/app_settings.dart';
import '../../models/currency_rate.dart';
import '../../models/calculation_history.dart';

/// Hive box names and initialization
class HiveBoxes {
  HiveBoxes._();

  // Box names
  static const String settings = 'settings';
  static const String currencyRates = 'currency_rates';
  static const String history = 'calculation_history';
  static const String colorOverrides = 'color_overrides';

  // Box instances (lazy initialized)
  static Box<AppSettings>? _settingsBox;
  static Box<CachedRates>? _currencyRatesBox;
  static Box<CalculationHistory>? _historyBox;
  static Box? _colorOverridesBox;

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CurrencyRateAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CachedRatesAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CalculationHistoryAdapter());
    }

    // Open boxes
    await Future.wait([
      _openSettingsBox(),
      _openCurrencyRatesBox(),
      _openHistoryBox(),
      _openColorOverridesBox(),
    ]);
  }

  static Future<void> _openSettingsBox() async {
    _settingsBox = await Hive.openBox<AppSettings>(settings);
  }

  static Future<void> _openCurrencyRatesBox() async {
    _currencyRatesBox = await Hive.openBox<CachedRates>(currencyRates);
  }

  static Future<void> _openHistoryBox() async {
    _historyBox = await Hive.openBox<CalculationHistory>(history);
  }

  static Future<void> _openColorOverridesBox() async {
    _colorOverridesBox = await Hive.openBox(colorOverrides);
  }

  /// Get settings box
  static Box<AppSettings> get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw StateError('Settings box not initialized. Call initialize() first.');
    }
    return _settingsBox!;
  }

  /// Get currency rates box
  static Box<CachedRates> get currencyRatesBox {
    if (_currencyRatesBox == null || !_currencyRatesBox!.isOpen) {
      throw StateError(
          'Currency rates box not initialized. Call initialize() first.');
    }
    return _currencyRatesBox!;
  }

  /// Get history box
  static Box<CalculationHistory> get historyBox {
    if (_historyBox == null || !_historyBox!.isOpen) {
      throw StateError('History box not initialized. Call initialize() first.');
    }
    return _historyBox!;
  }

  /// Get color overrides box
  static Box get colorOverridesBox {
    if (_colorOverridesBox == null || !_colorOverridesBox!.isOpen) {
      throw StateError(
          'Color overrides box not initialized. Call initialize() first.');
    }
    return _colorOverridesBox!;
  }

  /// Close all boxes
  static Future<void> close() async {
    await Future.wait([
      if (_settingsBox?.isOpen ?? false) _settingsBox!.close(),
      if (_currencyRatesBox?.isOpen ?? false) _currencyRatesBox!.close(),
      if (_historyBox?.isOpen ?? false) _historyBox!.close(),
      if (_colorOverridesBox?.isOpen ?? false) _colorOverridesBox!.close(),
    ]);
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAll() async {
    await Future.wait([
      if (_settingsBox?.isOpen ?? false) _settingsBox!.clear(),
      if (_currencyRatesBox?.isOpen ?? false) _currencyRatesBox!.clear(),
      if (_historyBox?.isOpen ?? false) _historyBox!.clear(),
      if (_colorOverridesBox?.isOpen ?? false) _colorOverridesBox!.clear(),
    ]);
  }
}
