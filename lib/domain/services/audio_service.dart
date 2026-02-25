import 'package:just_audio/just_audio.dart';

/// Types of sound effects
enum SoundType {
  clickLight,
  clickMedium,
  clickHeavy,
  toggle,
  dialTick,
  error,
}

/// Service for managing sound effect playback
class AudioService {
  final Map<SoundType, AudioPlayer> _players = {};
  bool _isInitialized = false;
  bool _isEnabled = true;
  double _volume = 0.7;

  /// Asset paths for each sound type
  static const Map<SoundType, String> _soundAssets = {
    SoundType.clickLight: 'assets/sounds/click_light.mp3',
    SoundType.clickMedium: 'assets/sounds/click_medium.mp3',
    SoundType.clickHeavy: 'assets/sounds/click_heavy.mp3',
    SoundType.toggle: 'assets/sounds/toggle.mp3',
    SoundType.dialTick: 'assets/sounds/dial_tick.mp3',
    SoundType.error: 'assets/sounds/error.mp3',
  };

  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  /// Initialize and preload all sounds
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create a player for each sound type
      for (final type in SoundType.values) {
        final player = AudioPlayer();
        try {
          await player.setAsset(_soundAssets[type]!);
          await player.setVolume(_volume);
          _players[type] = player;
        } catch (_) {
          // Asset doesn't exist yet, skip
        }
      }
      _isInitialized = true;
    } catch (_) {
      // Audio service initialization failed - sounds will be disabled
    }
  }

  /// Play a sound effect by type
  Future<void> playSound(SoundType type) async {
    if (!_isEnabled || !_isInitialized) return;

    final player = _players[type];
    if (player == null) return;

    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (_) {
      // Sound playback failed - ignore silently
    }
  }

  // Convenience methods for specific sounds
  Future<void> playClickLight() => playSound(SoundType.clickLight);
  Future<void> playClickMedium() => playSound(SoundType.clickMedium);
  Future<void> playClickHeavy() => playSound(SoundType.clickHeavy);
  Future<void> playToggle() => playSound(SoundType.toggle);
  Future<void> playDialTick() => playSound(SoundType.dialTick);
  Future<void> playError() => playSound(SoundType.error);

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    for (final player in _players.values) {
      await player.setVolume(_volume);
    }
  }

  /// Enable or disable sound
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Clean up resources
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}
