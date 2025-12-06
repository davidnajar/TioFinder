import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Servei per gestionar la ubicació GPS i el compàs
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  /// Stream controller per a la posició
  final _positionController = StreamController<Position>.broadcast();
  
  /// Stream controller per al heading del compàs
  final _headingController = StreamController<double>.broadcast();

  /// Stream de posicions
  Stream<Position> get positionStream => _positionController.stream;
  
  /// Stream del heading (en graus, 0 = nord)
  Stream<double> get headingStream => _headingController.stream;

  Position? _lastPosition;
  double _lastHeading = 0;

  /// Última posició coneguda
  Position? get lastPosition => _lastPosition;
  
  /// Últim heading conegut
  double get lastHeading => _lastHeading;

  /// Comprova i demana permisos de localització
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obté la posició actual una vegada
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastPosition = position;
      return position;
    } catch (e) {
      debugPrint('Error obtenint posició: $e');
      return null;
    }
  }

  /// Inicia el seguiment de la posició
  void startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1, // Actualitza cada metre per a major precisió
        timeLimit: Duration(seconds: 10),
      ),
    ).listen(
      (Position position) {
        _lastPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        debugPrint('Error en stream de posició: $error');
      },
    );
  }

  /// Inicia el seguiment del compàs
  void startCompassStream() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        final heading = event.heading ?? 0;
        _lastHeading = heading;
        _headingController.add(heading);
      },
      onError: (error) {
        debugPrint('Error en stream de compàs: $error');
      },
    );
  }

  /// Inicia tots els streams
  void startAllStreams() {
    startPositionStream();
    startCompassStream();
  }

  /// Atura tots els streams
  void stopAllStreams() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    _positionSubscription = null;
    _compassSubscription = null;
  }

  /// Allibera recursos
  void dispose() {
    stopAllStreams();
    _positionController.close();
    _headingController.close();
  }
}
