import 'package:flutter/material.dart';
import '../../theme/neumorphic_theme.dart';
import 'settings_provider.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  NeumorphicThemeData _neumorphicTheme = NeumorphicThemeData.light();

  ThemeMode get themeMode => _themeMode;
  NeumorphicThemeData get neumorphicTheme => _neumorphicTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Update theme based on settings
  void updateFromSettings(SettingsProvider settings) {
    final newMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode != newMode) {
      _themeMode = newMode;
      _neumorphicTheme = settings.isDarkMode
          ? NeumorphicThemeData.dark()
          : NeumorphicThemeData.light();
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _neumorphicTheme = _themeMode == ThemeMode.dark
        ? NeumorphicThemeData.dark()
        : NeumorphicThemeData.light();
    notifyListeners();
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _neumorphicTheme = mode == ThemeMode.dark
          ? NeumorphicThemeData.dark()
          : NeumorphicThemeData.light();
      notifyListeners();
    }
  }
}
