import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Servei per gestionar sons i vibracions
class AudioVibrateService {
  final AudioPlayer _foundPlayer = AudioPlayer();
  final AudioPlayer _poofPlayer = AudioPlayer();

  bool _hasVibrator = false;

  /// Inicialitza el servei
  Future<void> init() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      debugPrint('Error inicialitzant vibració: $e');
      _hasVibrator = false;
    }
  }

  /// Reprodueix el so de tió trobat i vibra
  Future<void> playFoundSound() async {
    try {
      await _foundPlayer.play(AssetSource('sounds/found.mp3'));
    } catch (e) {
      debugPrint('Error reproduint so found: $e');
    }
    
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(duration: 500, amplitude: 255);
      } catch (e) {
        debugPrint('Error vibrant: $e');
      }
    }
  }

  /// Reprodueix el so de desaparició (poof) amb vibració suau
  Future<void> playPoofSound() async {
    try {
      await _poofPlayer.play(AssetSource('sounds/poof.mp3'));
    } catch (e) {
      debugPrint('Error reproduint so poof: $e');
    }
    
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(duration: 100, amplitude: 128);
      } catch (e) {
        debugPrint('Error vibrant: $e');
      }
    }
  }

  /// Vibra sense so
  Future<void> vibrateOnly({int duration = 200}) async {
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(duration: duration);
      } catch (e) {
        debugPrint('Error vibrant: $e');
      }
    }
  }

  /// Allibera recursos
  void dispose() {
    _foundPlayer.dispose();
    _poofPlayer.dispose();
  }
}
