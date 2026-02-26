import 'package:hive/hive.dart';
import '../../core/enums/enums.dart';

part 'app_settings.g.dart';

/// User preferences model
@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool hapticEnabled;

  @HiveField(2)
  int hapticIntensityIndex; // Maps to HapticIntensity enum

  @HiveField(3)
  int decimalPlaces;

  @HiveField(4)
  bool useGroupingSeparator;

  @HiveField(5)
  String defaultCurrency;

  @HiveField(6)
  List<String> favoriteCurrencies;

  @HiveField(7)
  int defaultAngleModeIndex; // Maps to AngleMode enum

  @HiveField(8)
  bool isDarkMode;

  @HiveField(9)
  double soundVolume;

  @HiveField(10, defaultValue: 0)
  int themeIdIndex; // Maps to AppThemeId enum

  AppSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.hapticIntensityIndex = 2, // Medium
    this.decimalPlaces = 10,
    this.useGroupingSeparator = true,
    this.defaultCurrency = 'USD',
    List<String>? favoriteCurrencies,
    this.defaultAngleModeIndex = 0, // Degrees
    this.isDarkMode = false,
    this.soundVolume = 0.7,
    this.themeIdIndex = 0, // Classic
  }) : favoriteCurrencies = favoriteCurrencies ?? ['USD', 'EUR', 'GBP', 'JPY'];

  HapticIntensity get hapticIntensity =>
      HapticIntensity.values[hapticIntensityIndex];

  set hapticIntensity(HapticIntensity value) {
    hapticIntensityIndex = value.index;
  }

  AngleMode get defaultAngleMode => AngleMode.values[defaultAngleModeIndex];

  set defaultAngleMode(AngleMode value) {
    defaultAngleModeIndex = value.index;
  }

  AppThemeId get themeId => AppThemeId.values[themeIdIndex.clamp(0, AppThemeId.values.length - 1)];

  set themeId(AppThemeId value) {
    themeIdIndex = value.index;
  }

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    int? hapticIntensityIndex,
    int? decimalPlaces,
    bool? useGroupingSeparator,
    String? defaultCurrency,
    List<String>? favoriteCurrencies,
    int? defaultAngleModeIndex,
    bool? isDarkMode,
    double? soundVolume,
    int? themeIdIndex,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      hapticIntensityIndex: hapticIntensityIndex ?? this.hapticIntensityIndex,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      useGroupingSeparator: useGroupingSeparator ?? this.useGroupingSeparator,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      favoriteCurrencies: favoriteCurrencies ?? this.favoriteCurrencies,
      defaultAngleModeIndex:
          defaultAngleModeIndex ?? this.defaultAngleModeIndex,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundVolume: soundVolume ?? this.soundVolume,
      themeIdIndex: themeIdIndex ?? this.themeIdIndex,
    );
  }
}
