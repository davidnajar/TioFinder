import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';

/// Nivells de zoom disponibles per al radar (estil Dragon Ball)
class RadarZoomLevel {
  final String name;
  final double radiusMeters;
  final double multiplier;

  const RadarZoomLevel({
    required this.name,
    required this.radiusMeters,
    required this.multiplier,
  });
}

/// Provider per gestionar l'estat del radar
class RadarProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  final FakeTargetGenerator _fakeGenerator = FakeTargetGenerator();
  final AudioVibrateService _audioService = AudioVibrateService();

  static const double baseRadarRadius = 300.0; // metres (radi base)
  static const double foundThreshold = 8.0; // metres per considerar "trobat"

  /// Nivells de zoom disponibles (estil Dragon Ball)
  static const List<RadarZoomLevel> zoomLevels = [
    RadarZoomLevel(name: 'x1', radiusMeters: 300.0, multiplier: 1.0),
    RadarZoomLevel(name: 'x1.5', radiusMeters: 200.0, multiplier: 1.5),
    RadarZoomLevel(name: 'x2', radiusMeters: 150.0, multiplier: 2.0),
    RadarZoomLevel(name: 'x4', radiusMeters: 75.0, multiplier: 4.0),
    RadarZoomLevel(name: 'x6', radiusMeters: 50.0, multiplier: 6.0),
  ];

  // Estat
  List<RadarTarget> _allTargets = [];
  List<PolarTarget> _polarTargets = [];
  Position? _currentPosition;
  double _currentHeading = 0;
  bool _isInitialized = false;
  bool _hasLocationPermission = false;
  String? _errorMessage;
  
  // Zoom configurable
  int _currentZoomLevelIndex = 0;
  RadarTarget? _pendingFoundTio;

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
  RadarTarget? get pendingFoundTio => _pendingFoundTio;
  
  /// Índex del nivell de zoom actual
  int get currentZoomLevelIndex => _currentZoomLevelIndex;
  
  /// Nivell de zoom actual
  RadarZoomLevel get currentZoomLevel => zoomLevels[_currentZoomLevelIndex];
  
  /// Retorna el radi efectiu del radar segons el zoom actual
  double get effectiveRadarRadius => currentZoomLevel.radiusMeters;
  
  /// Indica si estem en un zoom alt (per a efectes visuals)
  bool get isHighZoom => _currentZoomLevelIndex >= 3; // x4 o superior

  /// Inicialitza el provider
  Future<void> init() async {
    await _storageService.init();
    await _audioService.init();
    
    // Carregar nivell de zoom guardat
    _currentZoomLevelIndex = await _storageService.getRadarZoomLevel();
    // Assegurar que l'índex és vàlid
    if (_currentZoomLevelIndex >= zoomLevels.length) {
      _currentZoomLevelIndex = 0;
    }
    
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

    // Carregar configuració de fake tions
    final fakeTionsCount = await _storageService.getFakeTionsCount();
    final fakeTionsRadius = await _storageService.getFakeTionsZoneRadius();

    // Generar targets falsos amb la configuració guardada
    final fakeTargets = _fakeGenerator.generateSpacedFakeTargets(
      centerLat: _currentPosition!.latitude,
      centerLng: _currentPosition!.longitude,
      maxRadius: fakeTionsRadius,
      count: fakeTionsCount,
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
    RadarTarget? closestRealTio;
    double closestRealTioDistance = double.infinity;

    for (final target in _allTargets) {
      if (target.found) continue;

      final distance = GeoUtils.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );

      if (target.type == TargetType.realTio) {
        // Buscar el tió real més proper
        if (distance < closestRealTioDistance) {
          closestRealTioDistance = distance;
          closestRealTio = target;
        }
      } else if (target.type == TargetType.fakeVanish && distance < foundThreshold) {
        // Els fake desapareixen quan t'acostes
        toRemove.add(target.id);
        _audioService.playPoofSound();
      }
      // fakePersistent no fa res quan t'hi acostes
    }

    // Gestionar el tió real pendent de confirmació
    if (closestRealTio != null && closestRealTioDistance < foundThreshold) {
      // Només actualitzar si és un tió diferent
      if (_pendingFoundTio?.id != closestRealTio.id) {
        _pendingFoundTio = closestRealTio;
      }
    } else {
      // Si ens allunyem del llindar, netejar pending
      if (_pendingFoundTio != null) {
        _pendingFoundTio = null;
      }
    }

    // Eliminar fakeVanish
    _allTargets.removeWhere((t) => toRemove.contains(t.id));
  }

  /// Callback que s'ha de configurar des de la UI per mostrar el diàleg
  void Function(RadarTarget tio)? onTioFoundCallback;

  /// Confirma que s'ha trobat el tió pendent (cridat quan l'usuari prem el botó)
  /// Retorna true si s'ha confirmat correctament, false si no hi havia tió pendent
  bool confirmFoundTio() {
    if (_pendingFoundTio == null) return false;
    
    final tio = _pendingFoundTio!;
    _onRealTioFound(tio);
    
    // Resetejar pending
    _pendingFoundTio = null;
    
    notifyListeners();
    return true;
  }

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
    final currentRadius = effectiveRadarRadius;
    
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

      // Factor de distància (0 a 1, limitat al radi efectiu actual)
      final factor = (distance / currentRadius).clamp(0.0, 1.0);

      return PolarTarget(
        id: target.id,
        angle: relativeAngle,
        factor: factor,
        type: target.type,
        found: target.found,
      );
    }).toList();
  }

  // ============== Zoom Control Methods ==============

  /// Canvia al nivell de zoom següent (cíclic)
  void nextZoomLevel() {
    _currentZoomLevelIndex = (_currentZoomLevelIndex + 1) % zoomLevels.length;
    _storageService.saveRadarZoomLevel(_currentZoomLevelIndex);
    _updatePolarTargets();
    notifyListeners();
  }

  /// Canvia al nivell de zoom anterior (cíclic)
  void previousZoomLevel() {
    _currentZoomLevelIndex = (_currentZoomLevelIndex - 1 + zoomLevels.length) % zoomLevels.length;
    _storageService.saveRadarZoomLevel(_currentZoomLevelIndex);
    _updatePolarTargets();
    notifyListeners();
  }

  /// Estableix un nivell de zoom específic
  void setZoomLevel(int index) {
    if (index < 0 || index >= zoomLevels.length) return;
    _currentZoomLevelIndex = index;
    _storageService.saveRadarZoomLevel(_currentZoomLevelIndex);
    _updatePolarTargets();
    notifyListeners();
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
