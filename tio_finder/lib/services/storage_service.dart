import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Servei per gestionar l'emmagatzematge persistent dels tiós
class StorageService {
  static const String _tiosKey = 'saved_tios';
  
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
}
