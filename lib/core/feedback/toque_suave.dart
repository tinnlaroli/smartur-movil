import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show HapticFeedback;

/// Vibración ligera + un sonido corto y suave al elegir una respuesta.
///
/// El sonido no pide el foco de audio (no pausa la música de la persona), usa el canal de
/// sonidos de interfaz y, en iOS, respeta el interruptor de silencio. Si el audio falla,
/// queda solo la vibración.
abstract final class ToqueSuave {
  static const _asset = 'sonidos/toque_suave.wav';
  static const _volumen = 0.35;
  static AudioPlayer? _player;
  static bool _desactivado = Platform.environment.containsKey('FLUTTER_TEST');

  static Future<AudioPlayer> _reproductor() async {
    final existente = _player;
    if (existente != null) return existente;
    final player = AudioPlayer();
    await player.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    ));
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setSource(AssetSource(_asset));
    await player.setVolume(_volumen);
    return _player = player;
  }

  /// Elección (respuesta, tarjeta, chip): vibración de selección + toque.
  static void elegir() {
    HapticFeedback.selectionClick();
    _sonar();
  }

  /// Avance de paso: vibración un poco más firme + toque.
  static void avanzar() {
    HapticFeedback.lightImpact();
    _sonar();
  }

  static Future<void> _sonar() async {
    if (_desactivado) return;
    try {
      final player = await _reproductor();
      await player.stop();
      await player.resume();
    } catch (e) {
      // Sin audio disponible: se queda solo la vibración y no se vuelve a intentar.
      _desactivado = true;
      debugPrint('[toque_suave] sin sonido: $e');
    }
  }
}
