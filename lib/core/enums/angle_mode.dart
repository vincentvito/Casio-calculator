/// Angle mode for trigonometric functions
enum AngleMode {
  degrees,
  radians,
}

extension AngleModeExtension on AngleMode {
  String get symbol {
    switch (this) {
      case AngleMode.degrees:
        return 'DEG';
      case AngleMode.radians:
        return 'RAD';
    }
  }

  String get displayName {
    switch (this) {
      case AngleMode.degrees:
        return 'Degrees';
      case AngleMode.radians:
        return 'Radians';
    }
  }
}
