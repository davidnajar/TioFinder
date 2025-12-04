import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

/// Provider per gestionar l'estat del radar
class RadarProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  final FakeTargetGenerator _fakeGenerator = FakeTargetGenerator();
  final AudioVibrateService _audioService = AudioVibrateService();

  static const double maxRadarRadius = 300.0; // metres
  static const double foundThreshold = 8.0; // metres per considerar "trobat"

  // Estat
  List<RadarTarget> _allTargets = [];
  List<PolarTarget> _polarTargets = [];
  Position? _currentPosition;
  double _currentHeading = 0;
  bool _isInitialized = false;
  bool _hasLocationPermission = false;
  String? _errorMessage;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<double>? _headingSub;

  // Getters
  List<PolarTarget> get polarTargets => _polarTargets;
  Position? get currentPosition => _currentPosition;
  double get currentHeading => _currentHeading;
  bool get isInitialized => _isInitialized;
  bool get hasLocationPermission => _hasLocationPermission;
  String? get errorMessage => _errorMessage;
  List<RadarTarget> get allTargets => _allTargets;

  /// Inicialitza el provider
  Future<void> init() async {
    await _storageService.init();
    await _audioService.init();
    
    _hasLocationPermission = await _locationService.checkAndRequestPermission();
    
    if (!_hasLocationPermission) {
      _errorMessage = "Cal permís de localització per utilitzar el radar";
      notifyListeners();
      return;
    }

    // Obtenir posició inicial
    _currentPosition = await _locationService.getCurrentPosition();
    
    if (_currentPosition == null) {
      _errorMessage = "No s'ha pogut obtenir la ubicació";
      notifyListeners();
      return;
    }

    // Carregar tiós reals
    final realTios = await _storageService.getUnfoundTios();
    _allTargets = List.from(realTios);

    // Generar targets falsos
    final fakeTargets = _fakeGenerator.generateSpacedFakeTargets(
      centerLat: _currentPosition!.latitude,
      centerLng: _currentPosition!.longitude,
    );
    _allTargets.addAll(fakeTargets);

    // Iniciar streams
    _startListening();

    // Calcular posicions polars inicials
    _updatePolarTargets();

    _isInitialized = true;
    notifyListeners();
  }

  void _startListening() {
    _locationService.startAllStreams();

    _positionSub = _locationService.positionStream.listen((position) {
      _currentPosition = position;
      _checkProximity();
      _updatePolarTargets();
      notifyListeners();
    });

    _headingSub = _locationService.headingStream.listen((heading) {
      _currentHeading = heading;
      _updatePolarTargets();
      notifyListeners();
    });
  }

  /// Comprova la proximitat als targets
  void _checkProximity() {
    if (_currentPosition == null) return;

    final toRemove = <String>[];
    final foundRealTios = <RadarTarget>[];

    for (final target in _allTargets) {
      if (target.found) continue;

      final distance = GeoUtils.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );

      if (distance < foundThreshold) {
        if (target.type == TargetType.realTio) {
          foundRealTios.add(target);
        } else if (target.type == TargetType.fakeVanish) {
          toRemove.add(target.id);
          _audioService.playPoofSound();
        }
        // fakePersistent no fa res quan t'hi acostes
      }
    }

    // Processar tiós trobats
    for (final tio in foundRealTios) {
      _onRealTioFound(tio);
    }

    // Eliminar fakeVanish
    _allTargets.removeWhere((t) => toRemove.contains(t.id));
  }

  /// Callback que s'ha de configurar des de la UI per mostrar el diàleg
  void Function(RadarTarget tio)? onTioFoundCallback;

  void _onRealTioFound(RadarTarget tio) {
    // Marcar com trobat
    final index = _allTargets.indexWhere((t) => t.id == tio.id);
    if (index != -1) {
      _allTargets[index] = _allTargets[index].copyWith(found: true);
    }

    // Guardar a persistent storage
    _storageService.markTioAsFound(tio.id);

    // Reproduir so i vibrar
    _audioService.playFoundSound();

    // Notificar UI
    onTioFoundCallback?.call(tio);
  }

  /// Actualitza les coordenades polars de tots els targets
  void _updatePolarTargets() {
    if (_currentPosition == null) return;

    final headingRad = _currentHeading * pi / 180;
    
    _polarTargets = _allTargets.map((target) {
      final distance = GeoUtils.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );

      final bearing = GeoUtils.calculateBearing(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );

      // Angle relatiu al heading de l'usuari
      var relativeAngle = bearing - headingRad;
      // Normalitzar a -π a π
      while (relativeAngle > pi) relativeAngle -= 2 * pi;
      while (relativeAngle < -pi) relativeAngle += 2 * pi;

      // Factor de distància (0 a 1, limitat al radi màxim)
      final factor = (distance / maxRadarRadius).clamp(0.0, 1.0);

      return PolarTarget(
        id: target.id,
        angle: relativeAngle,
        factor: factor,
        type: target.type,
        found: target.found,
      );
    }).toList();
  }

  /// Neteja i allibera recursos
  @override
  void dispose() {
    _positionSub?.cancel();
    _headingSub?.cancel();
    _locationService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
