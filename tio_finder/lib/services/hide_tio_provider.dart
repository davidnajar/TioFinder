import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider per gestionar l'amagat de tions
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
  
  // Múltiples zones de fake tions
  List<FakeTionsZone> _fakeTionsZones = [];

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
  
  /// Llista de totes les zones de fake tions configurades
  List<FakeTionsZone> get fakeTionsZones => _fakeTionsZones;
  
  /// Indica si hi ha zones de fake tions configurades
  bool get hasFakeTionsZones => _fakeTionsZones.isNotEmpty;

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
    
    // Carregar múltiples zones de fake tions
    _fakeTionsZones = await _storageService.getFakeTionsZones();
    
    await loadTios();

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega tots els tions guardats
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

  /// Elimina tots els tions
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
    _fakeTionsZones = [];
    await _storageService.resetFakeTionsSettings();
    await _storageService.deleteAllFakeTionsZones();
    notifyListeners();
  }

  // ============== Multiple Fake Tions Zones ==============

  /// Afegeix una nova zona de fake tions
  Future<void> addFakeTionsZone(FakeTionsZone zone) async {
    _fakeTionsZones.add(zone);
    await _storageService.addFakeTionsZone(zone);
    notifyListeners();
  }

  /// Afegeix una zona de fake tions amb les coordenades i radi especificats
  Future<void> addFakeTionsZoneFromCoords(double lat, double lng, double radius) async {
    final zone = FakeTionsZone(
      lat: lat,
      lng: lng,
      radius: radius,
    );
    await addFakeTionsZone(zone);
  }

  /// Elimina una zona de fake tions per ID
  Future<void> deleteFakeTionsZone(String id) async {
    _fakeTionsZones.removeWhere((z) => z.id == id);
    await _storageService.deleteFakeTionsZone(id);
    notifyListeners();
  }

  /// Actualitza una zona de fake tions existent
  Future<void> updateFakeTionsZone(FakeTionsZone zone) async {
    final index = _fakeTionsZones.indexWhere((z) => z.id == zone.id);
    if (index != -1) {
      _fakeTionsZones[index] = zone;
      await _storageService.updateFakeTionsZone(zone);
      notifyListeners();
    }
  }

  /// Elimina totes les zones de fake tions
  Future<void> deleteAllFakeTionsZones() async {
    _fakeTionsZones = [];
    await _storageService.deleteAllFakeTionsZones();
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
