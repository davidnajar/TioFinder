import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Servei per gestionar l'emmagatzematge persistent dels tiós
class StorageService {
  static const String _tiosKey = 'saved_tios';
  static const String _radarZoomKey = 'radar_zoom_level';
  static const String _fakeTionsCountKey = 'fake_tions_count';
  static const String _fakeTionsZoneRadiusKey = 'fake_tions_zone_radius';
  static const String _fakeTionsZoneCenterLatKey = 'fake_tions_zone_center_lat';
  static const String _fakeTionsZoneCenterLngKey = 'fake_tions_zone_center_lng';
  static const String _fakeTionsZonesKey = 'fake_tions_zones';
  
  SharedPreferences? _prefs;

  /// Inicialitza el servei
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Guarda un nou tió
  Future<void> saveTio(RadarTarget tio) async {
    final tios = await getAllTios();
    tios.add(tio);
    await _saveTios(tios);
  }

  /// Obté tots els tiós guardats
  Future<List<RadarTarget>> getAllTios() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? jsonString = _prefs?.getString(_tiosKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => RadarTarget.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obté només els tiós no trobats
  Future<List<RadarTarget>> getUnfoundTios() async {
    final tios = await getAllTios();
    return tios.where((tio) => !tio.found).toList();
  }

  /// Marca un tió com a trobat
  Future<void> markTioAsFound(String id) async {
    final tios = await getAllTios();
    final index = tios.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      tios[index] = tios[index].copyWith(found: true);
      await _saveTios(tios);
    }
  }

  /// Elimina un tió
  Future<void> deleteTio(String id) async {
    final tios = await getAllTios();
    tios.removeWhere((t) => t.id == id);
    await _saveTios(tios);
  }

  /// Elimina tots els tiós
  Future<void> deleteAllTios() async {
    await _prefs?.remove(_tiosKey);
  }

  Future<void> _saveTios(List<RadarTarget> tios) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonList = tios.map((t) => t.toJson()).toList();
    await _prefs?.setString(_tiosKey, json.encode(jsonList));
  }

  // ============== Radar Zoom Settings ==============

  /// Guarda el nivell de zoom del radar (índex del nivell)
  Future<void> saveRadarZoomLevel(int zoomLevelIndex) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(_radarZoomKey, zoomLevelIndex);
  }

  /// Obté el nivell de zoom del radar (índex del nivell, per defecte 0)
  Future<int> getRadarZoomLevel() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getInt(_radarZoomKey) ?? 0;
  }

  // ============== Fake Tions Settings ==============

  /// Guarda el nombre de fake tions a generar
  Future<void> saveFakeTionsCount(int count) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(_fakeTionsCountKey, count);
  }

  /// Obté el nombre de fake tions a generar (per defecte null = aleatori)
  Future<int?> getFakeTionsCount() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getInt(_fakeTionsCountKey);
  }

  /// Guarda el radi de la zona per als fake tions (en metres)
  Future<void> saveFakeTionsZoneRadius(double radius) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setDouble(_fakeTionsZoneRadiusKey, radius);
  }

  /// Obté el radi de la zona per als fake tions (per defecte 300m)
  Future<double> getFakeTionsZoneRadius() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getDouble(_fakeTionsZoneRadiusKey) ?? 300.0;
  }

  /// Reseteja les configuracions de fake tions als valors per defecte
  Future<void> resetFakeTionsSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_fakeTionsCountKey);
    await _prefs?.remove(_fakeTionsZoneRadiusKey);
    await _prefs?.remove(_fakeTionsZoneCenterLatKey);
    await _prefs?.remove(_fakeTionsZoneCenterLngKey);
  }

  /// Guarda el centre de la zona per als fake tions
  Future<void> saveFakeTionsZoneCenter(double lat, double lng) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setDouble(_fakeTionsZoneCenterLatKey, lat);
    await _prefs?.setDouble(_fakeTionsZoneCenterLngKey, lng);
  }

  /// Obté el centre de la zona per als fake tions (null si no s'ha configurat)
  Future<({double lat, double lng})?> getFakeTionsZoneCenter() async {
    _prefs ??= await SharedPreferences.getInstance();
    final lat = _prefs?.getDouble(_fakeTionsZoneCenterLatKey);
    final lng = _prefs?.getDouble(_fakeTionsZoneCenterLngKey);
    if (lat != null && lng != null) {
      return (lat: lat, lng: lng);
    }
    return null;
  }

  // ============== Multiple Fake Tions Zones ==============

  /// Guarda una llista de zones de fake tions
  Future<void> saveFakeTionsZones(List<FakeTionsZone> zones) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonList = zones.map((z) => z.toJson()).toList();
    await _prefs?.setString(_fakeTionsZonesKey, json.encode(jsonList));
  }

  /// Obté totes les zones de fake tions guardades
  Future<List<FakeTionsZone>> getFakeTionsZones() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? jsonString = _prefs?.getString(_fakeTionsZonesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => FakeTionsZone.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Retornar llista buida si hi ha error de parsing
      // Això pot passar si les dades guardades estan corruptes
      return [];
    }
  }

  /// Afegeix una nova zona de fake tions
  Future<void> addFakeTionsZone(FakeTionsZone zone) async {
    final zones = await getFakeTionsZones();
    zones.add(zone);
    await saveFakeTionsZones(zones);
  }

  /// Elimina una zona de fake tions per ID
  Future<void> deleteFakeTionsZone(String id) async {
    final zones = await getFakeTionsZones();
    zones.removeWhere((z) => z.id == id);
    await saveFakeTionsZones(zones);
  }

  /// Actualitza una zona de fake tions existent
  Future<void> updateFakeTionsZone(FakeTionsZone zone) async {
    final zones = await getFakeTionsZones();
    final index = zones.indexWhere((z) => z.id == zone.id);
    if (index != -1) {
      zones[index] = zone;
      await saveFakeTionsZones(zones);
    }
  }

  /// Elimina totes les zones de fake tions
  Future<void> deleteAllFakeTionsZones() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_fakeTionsZonesKey);
  }
}
