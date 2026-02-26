import 'package:flutter/foundation.dart';

import '../../core/enums/button_type.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/services/haptic_service.dart';
import 'settings_provider.dart';

/// Unified provider for haptic + audio feedback.
/// Wraps both services, syncs with settings, exposes fire-and-forget methods.
class FeedbackProvider extends ChangeNotifier {
  final HapticService _hapticService = HapticService();
  final AudioService _audioService = AudioService();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Call once at startup. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    await _hapticService.initialize();
    await _audioService.initialize();
    _initialized = true;
  }

  /// Sync service state from settings. Called by ProxyProvider on every
  /// SettingsProvider change.
  void updateFromSettings(SettingsProvider settings) {
    _hapticService.setEnabled(settings.hapticEnabled);
    _hapticService.setIntensity(settings.hapticIntensity);
    _audioService.setEnabled(settings.soundEnabled);
    _audioService.setVolume(settings.soundVolume);
  }

  // ---- Fire-and-forget API for widgets ----

  /// Feedback for a button press, based on ButtonType.
  void onButtonPress(ButtonType type) {
    switch (type) {
      case ButtonType.number:
        _hapticService.lightTap();
        _audioService.playClickLight();
      case ButtonType.operation:
      case ButtonType.function:
        _hapticService.mediumTap();
        _audioService.playClickMedium();
      case ButtonType.equals:
        _hapticService.heavyThunk();
        _audioService.playClickHeavy();
      case ButtonType.clear:
      case ButtonType.memory:
        _hapticService.selectionClick();
        _audioService.playClickLight();
    }
  }

  /// Light tap (for number buttons, misc taps)
  void lightTap() {
    _hapticService.lightTap();
    _audioService.playClickLight();
  }

  /// Medium tap (for operators, toggles)
  void mediumTap() {
    _hapticService.mediumTap();
    _audioService.playClickMedium();
  }

  /// Heavy feedback (for equals, compute, solve)
  void heavyTap() {
    _hapticService.heavyThunk();
    _audioService.playClickHeavy();
  }

  /// Selection click (for toggles, tab bars, pickers)
  void selectionClick() {
    _hapticService.selectionClick();
    _audioService.playToggle();
  }

  /// Dial tick (for mode dial rotation)
  void dialTick() {
    _hapticService.dialTick();
    _audioService.playDialTick();
  }

  /// Error feedback
  void errorFeedback() {
    _hapticService.errorVibration();
    _audioService.playError();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
