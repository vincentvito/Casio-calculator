import 'dart:math';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

/// Golden ratio for maximally inharmonic frequency spacing
const double _phi = 1.618033988749895;

/// Generates synthesized mechanical click/tap sounds as WAV byte data.
/// No asset files needed — sounds are created at runtime.
///
/// Each sound is built from three layers that mimic a real key press:
///   1. Noise transient — broadband impact burst (many inharmonic sines)
///   2. Body resonance — low-frequency "thock" from housing vibration
///   3. High-frequency ring — crisp metallic edge
class SoundGenerator {
  static const int _sampleRate = 44100;
  static const int _bitsPerSample = 16;
  static const int _numChannels = 1;

  /// Light click — crisp, light mechanical tap for number buttons
  static Uint8List clickLight() {
    return _generateMechanicalClick(
      durationMs: 18,
      noiseMinFreq: 1200,
      noiseMaxFreq: 8000,
      noiseCount: 25,
      noiseDecayRate: 500,
      noiseVolume: 0.35,
      bodyFreqs: [280, 440, 720],
      bodyWeights: [0.5, 0.3, 0.2],
      bodyDecayRate: 90,
      bodyVolume: 0.35,
      ringFreq: 5500,
      ringDecayRate: 700,
      ringVolume: 0.12,
      masterVolume: 0.4,
    );
  }

  /// Medium click — firm, authoritative mechanical press for operators
  static Uint8List clickMedium() {
    return _generateMechanicalClick(
      durationMs: 28,
      noiseMinFreq: 800,
      noiseMaxFreq: 6000,
      noiseCount: 25,
      noiseDecayRate: 400,
      noiseVolume: 0.30,
      bodyFreqs: [180, 295, 480],
      bodyWeights: [0.55, 0.3, 0.15],
      bodyDecayRate: 65,
      bodyVolume: 0.45,
      ringFreq: 4200,
      ringDecayRate: 600,
      ringVolume: 0.10,
      masterVolume: 0.5,
    );
  }

  /// Heavy click — deep, satisfying mechanical thunk for equals
  static Uint8List clickHeavy() {
    return _generateMechanicalClick(
      durationMs: 45,
      noiseMinFreq: 600,
      noiseMaxFreq: 4000,
      noiseCount: 20,
      noiseDecayRate: 300,
      noiseVolume: 0.25,
      bodyFreqs: [120, 195, 310, 480],
      bodyWeights: [0.5, 0.25, 0.15, 0.1],
      bodyDecayRate: 40,
      bodyVolume: 0.55,
      ringFreq: 3200,
      ringDecayRate: 500,
      ringVolume: 0.08,
      masterVolume: 0.6,
    );
  }

  /// Toggle snap — mechanical switch snap for toggles
  static Uint8List toggle() {
    return _generateMechanicalSnap(
      durationMs: 15,
      noiseMinFreq: 2500,
      noiseMaxFreq: 10000,
      noiseCount: 15,
      noiseDecayRate: 700,
      noiseVolume: 0.30,
      bodyStartFreq: 500,
      bodyEndFreq: 650,
      bodyDecayRate: 100,
      bodyVolume: 0.25,
      ringFreq: 6000,
      ringDecayRate: 800,
      ringVolume: 0.10,
      masterVolume: 0.35,
    );
  }

  /// Dial tick — ultra-short mechanical detent click for rotation
  static Uint8List dialTick() {
    return _generateMechanicalClick(
      durationMs: 6,
      noiseMinFreq: 2000,
      noiseMaxFreq: 12000,
      noiseCount: 15,
      noiseDecayRate: 800,
      noiseVolume: 0.30,
      bodyFreqs: [400, 650],
      bodyWeights: [0.6, 0.4],
      bodyDecayRate: 150,
      bodyVolume: 0.20,
      ringFreq: 7000,
      ringDecayRate: 900,
      ringVolume: 0.08,
      masterVolume: 0.3,
    );
  }

  /// Error buzz — mechanical buzzer with descending tone
  static Uint8List error() {
    return _generateMechanicalBuzz(
      startFreq: 600,
      endFreq: 300,
      detuneOffset: -10,
      durationMs: 80,
      decayRate: 20,
      noiseDecayRate: 200,
      noiseVolume: 0.15,
      volume: 0.5,
    );
  }

  // ---------------------------------------------------------------------------
  // Synthesis engines
  // ---------------------------------------------------------------------------

  /// Synthesize a mechanical key click from three layers:
  /// noise transient + body resonance + high-frequency ring.
  static Uint8List _generateMechanicalClick({
    required int durationMs,
    required double noiseMinFreq,
    required double noiseMaxFreq,
    required int noiseCount,
    required double noiseDecayRate,
    required double noiseVolume,
    required List<double> bodyFreqs,
    required List<double> bodyWeights,
    required double bodyDecayRate,
    required double bodyVolume,
    required double ringFreq,
    required double ringDecayRate,
    required double ringVolume,
    required double masterVolume,
    int seed = 42,
  }) {
    final rng = Random(seed);
    final numSamples = (_sampleRate * durationMs / 1000).round();
    final samples = Float64List(numSamples);

    // Pre-compute noise frequencies using golden-ratio spacing for
    // maximally inharmonic distribution and random phase offsets.
    final noiseFreqs = List<double>.generate(noiseCount, (i) {
      final t = (i * _phi) % 1.0;
      return noiseMinFreq + (noiseMaxFreq - noiseMinFreq) * t;
    });
    final noisePhases =
        List<double>.generate(noiseCount, (_) => rng.nextDouble() * 2 * pi);

    // Pre-compute body phase offsets
    final bodyPhases =
        List<double>.generate(bodyFreqs.length, (_) => rng.nextDouble() * 2 * pi);

    final ringPhase = rng.nextDouble() * 2 * pi;

    for (int i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;

      // Sub-millisecond attack ramp to avoid DC click at sample 0
      final attack = 1.0 - exp(-3000 * t);

      // --- Layer 1: Noise transient ---
      var noise = 0.0;
      final noiseEnv = exp(-noiseDecayRate * t);
      for (int n = 0; n < noiseCount; n++) {
        noise += sin(2 * pi * noiseFreqs[n] * t + noisePhases[n]);
      }
      noise = (noise / noiseCount) * noiseEnv * noiseVolume;

      // --- Layer 2: Body resonance ---
      var body = 0.0;
      final bodyEnv = exp(-bodyDecayRate * t);
      for (int b = 0; b < bodyFreqs.length; b++) {
        body +=
            sin(2 * pi * bodyFreqs[b] * t + bodyPhases[b]) * bodyWeights[b];
      }
      body = body * bodyEnv * bodyVolume;

      // --- Layer 3: High-frequency ring ---
      final ringEnv = exp(-ringDecayRate * t);
      final ring =
          sin(2 * pi * ringFreq * t + ringPhase) * ringEnv * ringVolume;

      samples[i] = (noise + body + ring) * attack * masterVolume;
    }

    return _encodeWav(samples);
  }

  /// Synthesize a mechanical toggle snap — noise burst + sweeping body.
  static Uint8List _generateMechanicalSnap({
    required int durationMs,
    required double noiseMinFreq,
    required double noiseMaxFreq,
    required int noiseCount,
    required double noiseDecayRate,
    required double noiseVolume,
    required double bodyStartFreq,
    required double bodyEndFreq,
    required double bodyDecayRate,
    required double bodyVolume,
    required double ringFreq,
    required double ringDecayRate,
    required double ringVolume,
    required double masterVolume,
    int seed = 43,
  }) {
    final rng = Random(seed);
    final numSamples = (_sampleRate * durationMs / 1000).round();
    final samples = Float64List(numSamples);
    final duration = durationMs / 1000.0;

    final noiseFreqs = List<double>.generate(noiseCount, (i) {
      final t = (i * _phi) % 1.0;
      return noiseMinFreq + (noiseMaxFreq - noiseMinFreq) * t;
    });
    final noisePhases =
        List<double>.generate(noiseCount, (_) => rng.nextDouble() * 2 * pi);
    final ringPhase = rng.nextDouble() * 2 * pi;

    for (int i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;
      final progress = t / duration;
      final attack = 1.0 - exp(-3000 * t);

      // Noise transient
      var noise = 0.0;
      final noiseEnv = exp(-noiseDecayRate * t);
      for (int n = 0; n < noiseCount; n++) {
        noise += sin(2 * pi * noiseFreqs[n] * t + noisePhases[n]);
      }
      noise = (noise / noiseCount) * noiseEnv * noiseVolume;

      // Sweeping body — frequency rises to model snap tension release
      final bodyFreq =
          bodyStartFreq + (bodyEndFreq - bodyStartFreq) * progress;
      final bodyEnv = exp(-bodyDecayRate * t);
      final body = sin(2 * pi * bodyFreq * t) * bodyEnv * bodyVolume;

      // Ring
      final ringEnv = exp(-ringDecayRate * t);
      final ring =
          sin(2 * pi * ringFreq * t + ringPhase) * ringEnv * ringVolume;

      samples[i] = (noise + body + ring) * attack * masterVolume;
    }

    return _encodeWav(samples);
  }

  /// Synthesize a mechanical buzzer — two detuned sweeps + noise onset.
  static Uint8List _generateMechanicalBuzz({
    required double startFreq,
    required double endFreq,
    required double detuneOffset,
    required int durationMs,
    required double decayRate,
    required double noiseDecayRate,
    required double noiseVolume,
    required double volume,
    int seed = 44,
  }) {
    final rng = Random(seed);
    final numSamples = (_sampleRate * durationMs / 1000).round();
    final samples = Float64List(numSamples);
    final duration = durationMs / 1000.0;

    // Small noise layer for onset texture
    const noiseCount = 12;
    final noiseFreqs = List<double>.generate(noiseCount, (i) {
      final t = (i * _phi) % 1.0;
      return 800 + 4000 * t;
    });
    final noisePhases =
        List<double>.generate(noiseCount, (_) => rng.nextDouble() * 2 * pi);

    for (int i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;
      final progress = t / duration;
      final envelope = exp(-decayRate * t);

      // Primary sweep
      final freq = startFreq + (endFreq - startFreq) * progress;
      final primary = sin(2 * pi * freq * t);

      // Detuned sweep for roughness / beating
      final detunedFreq =
          (startFreq + detuneOffset) + (endFreq + detuneOffset - startFreq - detuneOffset) * progress;
      final detuned = sin(2 * pi * detunedFreq * t) * 0.7;

      // Noise onset
      var noise = 0.0;
      final noiseEnv = exp(-noiseDecayRate * t);
      for (int n = 0; n < noiseCount; n++) {
        noise += sin(2 * pi * noiseFreqs[n] * t + noisePhases[n]);
      }
      noise = (noise / noiseCount) * noiseEnv * noiseVolume;

      samples[i] = ((primary + detuned) / 1.7 + noise) * envelope * volume;
    }

    return _encodeWav(samples);
  }

  // ---------------------------------------------------------------------------
  // WAV encoder
  // ---------------------------------------------------------------------------

  /// Encode float samples (-1.0 to 1.0) as a 16-bit PCM WAV file
  static Uint8List _encodeWav(Float64List samples) {
    final dataSize = samples.length * (_bitsPerSample ~/ 8);
    final fileSize = 44 + dataSize; // 44-byte header + data
    final buffer = ByteData(fileSize);
    var offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // R
    buffer.setUint8(offset++, 0x49); // I
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint32(offset, fileSize - 8, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // W
    buffer.setUint8(offset++, 0x41); // A
    buffer.setUint8(offset++, 0x56); // V
    buffer.setUint8(offset++, 0x45); // E

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // f
    buffer.setUint8(offset++, 0x6D); // m
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x20); // (space)
    buffer.setUint32(offset, 16, Endian.little); // chunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM format
    offset += 2;
    buffer.setUint16(offset, _numChannels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, _sampleRate, Endian.little);
    offset += 4;
    final byteRate = _sampleRate * _numChannels * (_bitsPerSample ~/ 8);
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    final blockAlign = _numChannels * (_bitsPerSample ~/ 8);
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, _bitsPerSample, Endian.little);
    offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // d
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // PCM samples
    for (int i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final int16 = (clamped * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, int16, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}

/// StreamAudioSource backed by an in-memory WAV byte buffer.
/// Used by AudioService to play synthesized sounds via just_audio.
class SynthAudioSource extends StreamAudioSource {
  final Uint8List _buffer;

  SynthAudioSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
