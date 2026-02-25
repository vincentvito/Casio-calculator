/// Types of haptic feedback
enum HapticType {
  light,
  medium,
  heavy,
  error,
  success,
}

extension HapticTypeExtension on HapticType {
  String get description {
    switch (this) {
      case HapticType.light:
        return 'Light tap for number buttons';
      case HapticType.medium:
        return 'Medium click for operators';
      case HapticType.heavy:
        return 'Heavy thunk for equals/enter';
      case HapticType.error:
        return 'Error feedback';
      case HapticType.success:
        return 'Success feedback';
    }
  }
}

/// Haptic intensity levels
enum HapticIntensity {
  off,
  light,
  medium,
  strong,
}

extension HapticIntensityExtension on HapticIntensity {
  String get displayName {
    switch (this) {
      case HapticIntensity.off:
        return 'Off';
      case HapticIntensity.light:
        return 'Light';
      case HapticIntensity.medium:
        return 'Medium';
      case HapticIntensity.strong:
        return 'Strong';
    }
  }

  double get multiplier {
    switch (this) {
      case HapticIntensity.off:
        return 0.0;
      case HapticIntensity.light:
        return 0.5;
      case HapticIntensity.medium:
        return 0.75;
      case HapticIntensity.strong:
        return 1.0;
    }
  }
}
