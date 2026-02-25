import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../core/enums/haptic_type.dart';

/// Service for haptic feedback with different intensity patterns
class HapticService {
  bool _hasVibrator = false;
  bool _hasCustomVibrations = false;
  HapticIntensity _intensity = HapticIntensity.medium;
  bool _isEnabled = true;

  /// Initialize the haptic service
  Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator() ?? false;
    _hasCustomVibrations = await Vibration.hasCustomVibrationsSupport() ?? false;
  }

  /// Set haptic intensity level
  void setIntensity(HapticIntensity intensity) {
    _intensity = intensity;
  }

  /// Enable or disable haptics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;
  bool get hasVibrator => _hasVibrator;

  /// Light tap - for number buttons
  Future<void> lightTap() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      await Vibration.vibrate(duration: _getDuration(20), amplitude: _getAmplitude(64));
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  /// Medium tap - for operators
  Future<void> mediumTap() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      await Vibration.vibrate(duration: _getDuration(35), amplitude: _getAmplitude(128));
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Heavy thunk - for equals, enter
  Future<void> heavyThunk() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      await Vibration.vibrate(duration: _getDuration(50), amplitude: _getAmplitude(200));
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Error feedback - distinct pattern
  Future<void> errorVibration() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      // Double pulse pattern
      await Vibration.vibrate(
        pattern: [0, _getDuration(50), 100, _getDuration(50)],
        intensities: [0, _getAmplitude(200), 0, _getAmplitude(200)],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Success feedback
  Future<void> successVibration() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      // Quick ascending pattern
      await Vibration.vibrate(
        pattern: [0, _getDuration(30), 50, _getDuration(50)],
        intensities: [0, _getAmplitude(100), 0, _getAmplitude(180)],
      );
    } else {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Dial tick - for mode dial rotation
  Future<void> dialTick() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    if (_hasCustomVibrations) {
      await Vibration.vibrate(duration: _getDuration(15), amplitude: _getAmplitude(50));
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  /// Selection click - for toggles and selections
  Future<void> selectionClick() async {
    if (!_isEnabled || _intensity == HapticIntensity.off) return;

    await HapticFeedback.selectionClick();
  }

  /// Adjust duration based on intensity
  int _getDuration(int baseDuration) {
    return (baseDuration * _intensity.multiplier).round();
  }

  /// Adjust amplitude based on intensity (0-255)
  int _getAmplitude(int baseAmplitude) {
    return (baseAmplitude * _intensity.multiplier).round().clamp(1, 255);
  }

  /// Trigger haptic based on type
  Future<void> trigger(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await lightTap();
      case HapticType.medium:
        await mediumTap();
      case HapticType.heavy:
        await heavyThunk();
      case HapticType.error:
        await errorVibration();
      case HapticType.success:
        await successVibration();
    }
  }
}
