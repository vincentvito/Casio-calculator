import 'dart:ui';

import '../../core/enums/app_theme_id.dart';

/// Stores user's custom color overrides for a specific theme+mode combination.
/// Stored as a `Map<String, int>` in Hive where keys are property names
/// and values are ARGB32 color integers.
class ColorOverrides {
  final Map<String, int> _overrides;

  const ColorOverrides([Map<String, int>? overrides])
      : _overrides = overrides ?? const {};

  Color? get numberButton => _getColor('numberButton');
  Color? get functionButton => _getColor('functionButton');
  Color? get operatorButton => _getColor('operatorButton');
  Color? get displayBackground => _getColor('displayBackground');
  Color? get displayText => _getColor('displayText');

  bool get isEmpty => _overrides.isEmpty;
  bool get isNotEmpty => _overrides.isNotEmpty;

  bool hasOverride(String key) => _overrides.containsKey(key);

  Color? _getColor(String key) {
    final value = _overrides[key];
    return value != null ? Color(value) : null;
  }

  ColorOverrides copyWithColor(String key, Color? color) {
    final newMap = Map<String, int>.from(_overrides);
    if (color == null) {
      newMap.remove(key);
    } else {
      newMap[key] = color.toARGB32();
    }
    return ColorOverrides(newMap);
  }

  ColorOverrides clearAll() => const ColorOverrides();

  Map<String, int> toMap() => Map<String, int>.from(_overrides);

  static String storageKey(AppThemeId themeId, bool isDark) =>
      'color_overrides_${themeId.name}_${isDark ? "dark" : "light"}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ColorOverrides) return false;
    if (_overrides.length != other._overrides.length) return false;
    for (final key in _overrides.keys) {
      if (_overrides[key] != other._overrides[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_overrides.entries);
}
