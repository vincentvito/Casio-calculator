/// Unit conversion categories
enum UnitType {
  length,
  weight,
  temperature,
  volume,
  area,
  speed,
  time,
  data,
}

extension UnitTypeExtension on UnitType {
  String get displayName {
    switch (this) {
      case UnitType.length:
        return 'Length';
      case UnitType.weight:
        return 'Weight';
      case UnitType.temperature:
        return 'Temperature';
      case UnitType.volume:
        return 'Volume';
      case UnitType.area:
        return 'Area';
      case UnitType.speed:
        return 'Speed';
      case UnitType.time:
        return 'Time';
      case UnitType.data:
        return 'Data';
    }
  }

  String get icon {
    switch (this) {
      case UnitType.length:
        return '📏';
      case UnitType.weight:
        return '⚖️';
      case UnitType.temperature:
        return '🌡️';
      case UnitType.volume:
        return '🧪';
      case UnitType.area:
        return '📐';
      case UnitType.speed:
        return '🚀';
      case UnitType.time:
        return '⏱️';
      case UnitType.data:
        return '💾';
    }
  }
}

/// Length units
enum LengthUnit {
  millimeter,
  centimeter,
  meter,
  kilometer,
  inch,
  foot,
  yard,
  mile,
}

extension LengthUnitExtension on LengthUnit {
  String get symbol {
    switch (this) {
      case LengthUnit.millimeter:
        return 'mm';
      case LengthUnit.centimeter:
        return 'cm';
      case LengthUnit.meter:
        return 'm';
      case LengthUnit.kilometer:
        return 'km';
      case LengthUnit.inch:
        return 'in';
      case LengthUnit.foot:
        return 'ft';
      case LengthUnit.yard:
        return 'yd';
      case LengthUnit.mile:
        return 'mi';
    }
  }

  String get displayName {
    switch (this) {
      case LengthUnit.millimeter:
        return 'Millimeters';
      case LengthUnit.centimeter:
        return 'Centimeters';
      case LengthUnit.meter:
        return 'Meters';
      case LengthUnit.kilometer:
        return 'Kilometers';
      case LengthUnit.inch:
        return 'Inches';
      case LengthUnit.foot:
        return 'Feet';
      case LengthUnit.yard:
        return 'Yards';
      case LengthUnit.mile:
        return 'Miles';
    }
  }

  /// Conversion factor to meters (base unit)
  double get toBase {
    switch (this) {
      case LengthUnit.millimeter:
        return 0.001;
      case LengthUnit.centimeter:
        return 0.01;
      case LengthUnit.meter:
        return 1.0;
      case LengthUnit.kilometer:
        return 1000.0;
      case LengthUnit.inch:
        return 0.0254;
      case LengthUnit.foot:
        return 0.3048;
      case LengthUnit.yard:
        return 0.9144;
      case LengthUnit.mile:
        return 1609.344;
    }
  }
}

/// Weight units
enum WeightUnit {
  gram,
  kilogram,
  ounce,
  pound,
  stone,
}

extension WeightUnitExtension on WeightUnit {
  String get symbol {
    switch (this) {
      case WeightUnit.gram:
        return 'g';
      case WeightUnit.kilogram:
        return 'kg';
      case WeightUnit.ounce:
        return 'oz';
      case WeightUnit.pound:
        return 'lb';
      case WeightUnit.stone:
        return 'st';
    }
  }

  String get displayName {
    switch (this) {
      case WeightUnit.gram:
        return 'Grams';
      case WeightUnit.kilogram:
        return 'Kilograms';
      case WeightUnit.ounce:
        return 'Ounces';
      case WeightUnit.pound:
        return 'Pounds';
      case WeightUnit.stone:
        return 'Stone';
    }
  }

  /// Conversion factor to grams (base unit)
  double get toBase {
    switch (this) {
      case WeightUnit.gram:
        return 1.0;
      case WeightUnit.kilogram:
        return 1000.0;
      case WeightUnit.ounce:
        return 28.3495;
      case WeightUnit.pound:
        return 453.592;
      case WeightUnit.stone:
        return 6350.29;
    }
  }
}

/// Temperature units
enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

extension TemperatureUnitExtension on TemperatureUnit {
  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.kelvin:
        return 'K';
    }
  }

  String get displayName {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Celsius';
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit';
      case TemperatureUnit.kelvin:
        return 'Kelvin';
    }
  }
}

/// Volume units
enum VolumeUnit {
  milliliter,
  liter,
  fluidOunce,
  cup,
  pint,
  gallon,
}

extension VolumeUnitExtension on VolumeUnit {
  String get symbol {
    switch (this) {
      case VolumeUnit.milliliter:
        return 'mL';
      case VolumeUnit.liter:
        return 'L';
      case VolumeUnit.fluidOunce:
        return 'fl oz';
      case VolumeUnit.cup:
        return 'cup';
      case VolumeUnit.pint:
        return 'pt';
      case VolumeUnit.gallon:
        return 'gal';
    }
  }

  String get displayName {
    switch (this) {
      case VolumeUnit.milliliter:
        return 'Milliliters';
      case VolumeUnit.liter:
        return 'Liters';
      case VolumeUnit.fluidOunce:
        return 'Fluid Ounces';
      case VolumeUnit.cup:
        return 'Cups';
      case VolumeUnit.pint:
        return 'Pints';
      case VolumeUnit.gallon:
        return 'Gallons';
    }
  }

  /// Conversion factor to milliliters (base unit)
  double get toBase {
    switch (this) {
      case VolumeUnit.milliliter:
        return 1.0;
      case VolumeUnit.liter:
        return 1000.0;
      case VolumeUnit.fluidOunce:
        return 29.5735;
      case VolumeUnit.cup:
        return 236.588;
      case VolumeUnit.pint:
        return 473.176;
      case VolumeUnit.gallon:
        return 3785.41;
    }
  }
}

/// Area units
enum AreaUnit {
  squareMeter,
  squareFoot,
  acre,
  hectare,
}

extension AreaUnitExtension on AreaUnit {
  String get symbol {
    switch (this) {
      case AreaUnit.squareMeter:
        return 'm²';
      case AreaUnit.squareFoot:
        return 'ft²';
      case AreaUnit.acre:
        return 'ac';
      case AreaUnit.hectare:
        return 'ha';
    }
  }

  String get displayName {
    switch (this) {
      case AreaUnit.squareMeter:
        return 'Square Meters';
      case AreaUnit.squareFoot:
        return 'Square Feet';
      case AreaUnit.acre:
        return 'Acres';
      case AreaUnit.hectare:
        return 'Hectares';
    }
  }

  /// Conversion factor to square meters (base unit)
  double get toBase {
    switch (this) {
      case AreaUnit.squareMeter:
        return 1.0;
      case AreaUnit.squareFoot:
        return 0.092903;
      case AreaUnit.acre:
        return 4046.86;
      case AreaUnit.hectare:
        return 10000.0;
    }
  }
}

/// Speed units
enum SpeedUnit {
  metersPerSecond,
  kilometersPerHour,
  milesPerHour,
  knots,
}

extension SpeedUnitExtension on SpeedUnit {
  String get symbol {
    switch (this) {
      case SpeedUnit.metersPerSecond:
        return 'm/s';
      case SpeedUnit.kilometersPerHour:
        return 'km/h';
      case SpeedUnit.milesPerHour:
        return 'mph';
      case SpeedUnit.knots:
        return 'kn';
    }
  }

  String get displayName {
    switch (this) {
      case SpeedUnit.metersPerSecond:
        return 'Meters/Second';
      case SpeedUnit.kilometersPerHour:
        return 'Kilometers/Hour';
      case SpeedUnit.milesPerHour:
        return 'Miles/Hour';
      case SpeedUnit.knots:
        return 'Knots';
    }
  }

  /// Conversion factor to meters per second (base unit)
  double get toBase {
    switch (this) {
      case SpeedUnit.metersPerSecond:
        return 1.0;
      case SpeedUnit.kilometersPerHour:
        return 0.277778;
      case SpeedUnit.milesPerHour:
        return 0.44704;
      case SpeedUnit.knots:
        return 0.514444;
    }
  }
}

/// Time units
enum TimeUnit {
  second,
  minute,
  hour,
  day,
  week,
  month,
  year,
}

extension TimeUnitExtension on TimeUnit {
  String get symbol {
    switch (this) {
      case TimeUnit.second:
        return 's';
      case TimeUnit.minute:
        return 'min';
      case TimeUnit.hour:
        return 'hr';
      case TimeUnit.day:
        return 'day';
      case TimeUnit.week:
        return 'wk';
      case TimeUnit.month:
        return 'mo';
      case TimeUnit.year:
        return 'yr';
    }
  }

  String get displayName {
    switch (this) {
      case TimeUnit.second:
        return 'Seconds';
      case TimeUnit.minute:
        return 'Minutes';
      case TimeUnit.hour:
        return 'Hours';
      case TimeUnit.day:
        return 'Days';
      case TimeUnit.week:
        return 'Weeks';
      case TimeUnit.month:
        return 'Months';
      case TimeUnit.year:
        return 'Years';
    }
  }

  /// Conversion factor to seconds (base unit)
  double get toBase {
    switch (this) {
      case TimeUnit.second:
        return 1.0;
      case TimeUnit.minute:
        return 60.0;
      case TimeUnit.hour:
        return 3600.0;
      case TimeUnit.day:
        return 86400.0;
      case TimeUnit.week:
        return 604800.0;
      case TimeUnit.month:
        return 2629746.0; // Average month
      case TimeUnit.year:
        return 31556952.0; // Average year
    }
  }
}

/// Data storage units
enum DataUnit {
  byte,
  kilobyte,
  megabyte,
  gigabyte,
  terabyte,
}

extension DataUnitExtension on DataUnit {
  String get symbol {
    switch (this) {
      case DataUnit.byte:
        return 'B';
      case DataUnit.kilobyte:
        return 'KB';
      case DataUnit.megabyte:
        return 'MB';
      case DataUnit.gigabyte:
        return 'GB';
      case DataUnit.terabyte:
        return 'TB';
    }
  }

  String get displayName {
    switch (this) {
      case DataUnit.byte:
        return 'Bytes';
      case DataUnit.kilobyte:
        return 'Kilobytes';
      case DataUnit.megabyte:
        return 'Megabytes';
      case DataUnit.gigabyte:
        return 'Gigabytes';
      case DataUnit.terabyte:
        return 'Terabytes';
    }
  }

  /// Conversion factor to bytes (base unit)
  double get toBase {
    switch (this) {
      case DataUnit.byte:
        return 1.0;
      case DataUnit.kilobyte:
        return 1024.0;
      case DataUnit.megabyte:
        return 1048576.0;
      case DataUnit.gigabyte:
        return 1073741824.0;
      case DataUnit.terabyte:
        return 1099511627776.0;
    }
  }
}
