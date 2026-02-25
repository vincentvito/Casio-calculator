import 'package:flutter/foundation.dart';
import '../../core/enums/enums.dart';
import '../../data/datasources/local/hive_boxes.dart';
import '../../data/models/app_settings.dart';

/// Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  bool _isLoaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  // Convenience getters
  bool get soundEnabled => _settings.soundEnabled;
  bool get hapticEnabled => _settings.hapticEnabled;
  HapticIntensity get hapticIntensity => _settings.hapticIntensity;
  int get decimalPlaces => _settings.decimalPlaces;
  bool get useGroupingSeparator => _settings.useGroupingSeparator;
  String get defaultCurrency => _settings.defaultCurrency;
  List<String> get favoriteCurrencies => _settings.favoriteCurrencies;
  AngleMode get defaultAngleMode => _settings.defaultAngleMode;
  bool get isDarkMode => _settings.isDarkMode;
  double get soundVolume => _settings.soundVolume;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = HiveBoxes.settingsBox;
      final savedSettings = box.get('app_settings');
      if (savedSettings != null) {
        _settings = savedSettings;
      }
      _isLoaded = true;
      notifyListeners();
    } catch (_) {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final box = HiveBoxes.settingsBox;
      await box.put('app_settings', _settings);
    } catch (_) {
      // Silently fail - settings will be saved next time
    }
  }

  void updateSoundEnabled(bool value) {
    _settings = _settings.copyWith(soundEnabled: value);
    _saveSettings();
    notifyListeners();
  }

  void updateHapticEnabled(bool value) {
    _settings = _settings.copyWith(hapticEnabled: value);
    _saveSettings();
    notifyListeners();
  }

  void updateHapticIntensity(HapticIntensity intensity) {
    _settings = _settings.copyWith(hapticIntensityIndex: intensity.index);
    _saveSettings();
    notifyListeners();
  }

  void updateDecimalPlaces(int places) {
    _settings = _settings.copyWith(decimalPlaces: places);
    _saveSettings();
    notifyListeners();
  }

  void updateUseGroupingSeparator(bool value) {
    _settings = _settings.copyWith(useGroupingSeparator: value);
    _saveSettings();
    notifyListeners();
  }

  void updateDefaultCurrency(String currency) {
    _settings = _settings.copyWith(defaultCurrency: currency);
    _saveSettings();
    notifyListeners();
  }

  void updateFavoriteCurrencies(List<String> currencies) {
    _settings = _settings.copyWith(favoriteCurrencies: currencies);
    _saveSettings();
    notifyListeners();
  }

  void addFavoriteCurrency(String currency) {
    if (!_settings.favoriteCurrencies.contains(currency)) {
      final newFavorites = [..._settings.favoriteCurrencies, currency];
      updateFavoriteCurrencies(newFavorites);
    }
  }

  void removeFavoriteCurrency(String currency) {
    final newFavorites =
        _settings.favoriteCurrencies.where((c) => c != currency).toList();
    updateFavoriteCurrencies(newFavorites);
  }

  void updateDefaultAngleMode(AngleMode mode) {
    _settings = _settings.copyWith(defaultAngleModeIndex: mode.index);
    _saveSettings();
    notifyListeners();
  }

  void updateIsDarkMode(bool value) {
    _settings = _settings.copyWith(isDarkMode: value);
    _saveSettings();
    notifyListeners();
  }

  void updateSoundVolume(double volume) {
    _settings = _settings.copyWith(soundVolume: volume.clamp(0.0, 1.0));
    _saveSettings();
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _settings = AppSettings();
    await _saveSettings();
    notifyListeners();
  }
}
