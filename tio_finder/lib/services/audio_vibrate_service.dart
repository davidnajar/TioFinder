import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Servei per gestionar sons i vibracions
/// Nota: Per activar sons, afegir els fitxers found.mp3 i poof.mp3 a assets/sounds/
/// i descomentar les línies d'assets al pubspec.yaml
class AudioVibrateService {
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
    // So desactivat - descomentar quan s'afegeixin els fitxers d'àudio
    // try {
    //   await _foundPlayer.play(AssetSource('sounds/found.mp3'));
    // } catch (e) {
    //   debugPrint('Error reproduint so found: $e');
    // }
    
    if (_hasVibrator) {
      try {
        // Patró de vibració per celebrar: llarg-curt-llarg
        // Prova primer amb intensitats, si no funciona, fa fallback a patró simple
        final hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
        if (hasAmplitudeControl) {
          await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 300], intensities: [0, 255, 0, 200, 0, 255]);
        } else {
          // Fallback a patró sense intensitats
          await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 300]);
        }
      } catch (e) {
        // Fallback a vibració simple
        try {
          await Vibration.vibrate(duration: 500);
        } catch (e2) {
          debugPrint('Error vibrant: $e2');
        }
      }
    }
  }

  /// Reprodueix el so de desaparició (poof) amb vibració suau
  Future<void> playPoofSound() async {
    // So desactivat - descomentar quan s'afegeixin els fitxers d'àudio
    // try {
    //   await _poofPlayer.play(AssetSource('sounds/poof.mp3'));
    // } catch (e) {
    //   debugPrint('Error reproduint so poof: $e');
    // }
    
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(duration: 100);
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
    // Res a netejar sense AudioPlayers
  }
}
