import 'package:just_audio/just_audio.dart';

import 'sound_generator.dart';

/// Types of sound effects
enum SoundType {
  clickLight,
  clickMedium,
  clickHeavy,
  toggle,
  dialTick,
  error,
}

/// Service for managing sound effect playback using synthesized audio
class AudioService {
  final Map<SoundType, AudioPlayer> _players = {};
  bool _isInitialized = false;
  bool _isEnabled = true;
  double _volume = 0.7;

  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  /// Initialize and preload all synthesized sounds
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final generators = {
        SoundType.clickLight: SoundGenerator.clickLight(),
        SoundType.clickMedium: SoundGenerator.clickMedium(),
        SoundType.clickHeavy: SoundGenerator.clickHeavy(),
        SoundType.toggle: SoundGenerator.toggle(),
        SoundType.dialTick: SoundGenerator.dialTick(),
        SoundType.error: SoundGenerator.error(),
      };

      for (final entry in generators.entries) {
        final player = AudioPlayer();
        try {
          await player.setAudioSource(SynthAudioSource(entry.value));
          await player.setVolume(_volume);
          _players[entry.key] = player;
        } catch (_) {
          // Skip this sound type if generation fails
        }
      }
      _isInitialized = true;
    } catch (_) {
      // Audio service initialization failed — sounds will be disabled
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
      // Sound playback failed — ignore silently
    }
  }

  // Convenience methods
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
