import 'package:flutter/material.dart';
import '../../core/enums/app_theme_id.dart';
import '../../theme/app_theme.dart';
import '../../theme/neumorphic_theme.dart';
import '../../theme/theme_definitions.dart';
import 'settings_provider.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppThemeId _activeThemeId = AppThemeId.classic;
  NeumorphicThemeData _neumorphicTheme = NeumorphicThemeData.light();
  ThemeData _materialTheme = AppTheme.light;
  ThemeDefinition _definition = ThemeRegistry.classic;

  ThemeMode get themeMode => _themeMode;
  NeumorphicThemeData get neumorphicTheme => _neumorphicTheme;
  ThemeData get materialTheme => _materialTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppThemeId get activeThemeId => _activeThemeId;
  ThemeDefinition get themeDefinition => _definition;

  /// Update theme based on settings
  void updateFromSettings(SettingsProvider settings) {
    final newMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final newThemeId = settings.themeId;

    if (_themeMode != newMode || _activeThemeId != newThemeId) {
      _themeMode = newMode;
      _activeThemeId = newThemeId;
      _rebuildTheme();
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _rebuildTheme();
    notifyListeners();
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _rebuildTheme();
      notifyListeners();
    }
  }

  void _rebuildTheme() {
    _definition = ThemeRegistry.getById(_activeThemeId);
    final isDark = _themeMode == ThemeMode.dark;
    final palette = isDark ? _definition.darkPalette : _definition.lightPalette;

    _neumorphicTheme =
        NeumorphicThemeData.fromPalette(palette, isDark: isDark);
    _materialTheme = AppTheme.fromPalette(palette, isDark: isDark);
  }
}
