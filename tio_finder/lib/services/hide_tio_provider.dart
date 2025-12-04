import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider per gestionar l'amagat de tiós
class HideTioProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  List<RadarTarget> _savedTios = [];
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  String? _errorMessage;
  String? _successMessage;

  // Configuració de fake tions
  int? _fakeTionsCount;
  double _fakeTionsZoneRadius = 300.0;
  ({double lat, double lng})? _fakeTionsZoneCenter;

  // Getters
  List<RadarTarget> get savedTios => _savedTios;
  bool get isLoading => _isLoading;
  bool get hasLocationPermission => _hasLocationPermission;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  /// Nombre de fake tions a generar (null = aleatori entre 8 i 15)
  int? get fakeTionsCount => _fakeTionsCount;
  
  /// Radi de la zona per als fake tions (en metres)
  double get fakeTionsZoneRadius => _fakeTionsZoneRadius;
  
  /// Centre de la zona per als fake tions (null = usar posició actual de l'usuari)
  ({double lat, double lng})? get fakeTionsZoneCenter => _fakeTionsZoneCenter;
  
  /// Indica si s'ha configurat una zona personalitzada per als fake tions
  bool get hasFakeTionsZoneCenter => _fakeTionsZoneCenter != null;

  /// Inicialitza el provider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.init();
    _hasLocationPermission = await _locationService.checkAndRequestPermission();
    
    // Carregar configuració de fake tions
    _fakeTionsCount = await _storageService.getFakeTionsCount();
    _fakeTionsZoneRadius = await _storageService.getFakeTionsZoneRadius();
    _fakeTionsZoneCenter = await _storageService.getFakeTionsZoneCenter();
    
    await loadTios();

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega tots els tiós guardats
  Future<void> loadTios() async {
    _savedTios = await _storageService.getAllTios();
    notifyListeners();
  }

  /// Obté la posició actual de l'usuari
  Future<({double lat, double lng})?> getCurrentPosition() async {
    if (!_hasLocationPermission) {
      _hasLocationPermission = await _locationService.checkAndRequestPermission();
      if (!_hasLocationPermission) {
        return null;
      }
    }
    final position = await _locationService.getCurrentPosition();
    if (position == null) return null;
    return (lat: position.latitude, lng: position.longitude);
  }

  /// Guarda un nou tió a la posició actual
  Future<bool> saveCurrentLocationAsTio() async {
    _errorMessage = null;
    _successMessage = null;

    if (!_hasLocationPermission) {
      _hasLocationPermission = await _locationService.checkAndRequestPermission();
      if (!_hasLocationPermission) {
        _errorMessage = "Cal permís de localització";
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        _errorMessage = "No s'ha pogut obtenir la ubicació";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newTio = RadarTarget(
        lat: position.latitude,
        lng: position.longitude,
        type: TargetType.realTio,
      );

      await _storageService.saveTio(newTio);
      await loadTios();

      _successMessage = "Tió amagat correctament!";
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error guardant el tió: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Guarda un nou tió a una ubicació personalitzada (seleccionada al mapa)
  Future<bool> saveTioAtLocation(double lat, double lng) async {
    _errorMessage = null;
    _successMessage = null;

    _isLoading = true;
    notifyListeners();

    try {
      final newTio = RadarTarget(
        lat: lat,
        lng: lng,
        type: TargetType.realTio,
      );

      await _storageService.saveTio(newTio);
      await loadTios();

      _successMessage = "Tió amagat correctament al mapa!";
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error guardant el tió: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un tió
  Future<void> deleteTio(String id) async {
    await _storageService.deleteTio(id);
    await loadTios();
  }

  /// Elimina tots els tiós
  Future<void> deleteAllTios() async {
    await _storageService.deleteAllTios();
    await loadTios();
  }

  /// Neteja missatges
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ============== Fake Tions Settings ==============

  /// Estableix el nombre de fake tions a generar
  /// Si count és null, es generarà un nombre aleatori
  Future<void> setFakeTionsCount(int? count) async {
    _fakeTionsCount = count;
    if (count != null) {
      await _storageService.saveFakeTionsCount(count);
    }
    notifyListeners();
  }

  /// Estableix el radi de la zona per als fake tions (en metres)
  Future<void> setFakeTionsZoneRadius(double radius) async {
    _fakeTionsZoneRadius = radius;
    await _storageService.saveFakeTionsZoneRadius(radius);
    notifyListeners();
  }

  /// Estableix el centre de la zona per als fake tions
  Future<void> setFakeTionsZoneCenter(double lat, double lng) async {
    _fakeTionsZoneCenter = (lat: lat, lng: lng);
    await _storageService.saveFakeTionsZoneCenter(lat, lng);
    notifyListeners();
  }

  /// Estableix el centre i el radi de la zona per als fake tions alhora
  Future<void> setFakeTionsZone(double lat, double lng, double radius) async {
    _fakeTionsZoneCenter = (lat: lat, lng: lng);
    _fakeTionsZoneRadius = radius;
    await _storageService.saveFakeTionsZoneCenter(lat, lng);
    await _storageService.saveFakeTionsZoneRadius(radius);
    notifyListeners();
  }

  /// Reseteja les configuracions de fake tions als valors per defecte
  Future<void> resetFakeTionsSettings() async {
    _fakeTionsCount = null;
    _fakeTionsZoneRadius = 300.0;
    _fakeTionsZoneCenter = null;
    await _storageService.resetFakeTionsSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
