import 'dart:math';
import '../models/models.dart';
import '../utils/utils.dart';

/// Servei per generar targets falsos al voltant de l'usuari
class FakeTargetGenerator {
  static const double _defaultMaxRadius = 300.0; // metres
  static const int _defaultMinTargets = 8;
  static const int _defaultMaxTargets = 15;
  static const double _fakeVanishProbability = 0.4; // 40% fakeVanish

  final Random _random = Random();

  /// Genera una llista de targets falsos al voltant d'una posició
  List<RadarTarget> generateFakeTargets({
    required double centerLat,
    required double centerLng,
    double maxRadius = _defaultMaxRadius,
    int? count,
  }) {
    // Determinar nombre de targets
    final targetCount = count ?? 
        (_random.nextInt(_defaultMaxTargets - _defaultMinTargets + 1) + _defaultMinTargets);

    final List<RadarTarget> targets = [];

    for (int i = 0; i < targetCount; i++) {
      // Generar posició aleatòria
      final point = GeoUtils.generateRandomPoint(centerLat, centerLng, maxRadius);
      
      // Determinar tipus (40% vanish, 60% persistent)
      final type = _random.nextDouble() < _fakeVanishProbability
          ? TargetType.fakeVanish
          : TargetType.fakePersistent;

      targets.add(RadarTarget(
        lat: point.lat,
        lng: point.lng,
        type: type,
      ));
    }

    return targets;
  }

  /// Genera una llista de targets falsos assegurant una distribució mínima de distàncies
  List<RadarTarget> generateSpacedFakeTargets({
    required double centerLat,
    required double centerLng,
    double maxRadius = _defaultMaxRadius,
    double minSpacing = 20.0, // metres mínims entre targets
    int? count,
  }) {
    final targetCount = count ?? 
        (_random.nextInt(_defaultMaxTargets - _defaultMinTargets + 1) + _defaultMinTargets);

    final List<RadarTarget> targets = [];
    int attempts = 0;
    const maxAttempts = 100;

    while (targets.length < targetCount && attempts < maxAttempts) {
      final point = GeoUtils.generateRandomPoint(centerLat, centerLng, maxRadius);
      
      // Comprovar que no estigui massa a prop d'altres targets
      bool tooClose = false;
      for (final existing in targets) {
        final distance = GeoUtils.calculateDistance(
          point.lat, point.lng, existing.lat, existing.lng
        );
        if (distance < minSpacing) {
          tooClose = true;
          break;
        }
      }

      if (!tooClose) {
        final type = _random.nextDouble() < _fakeVanishProbability
            ? TargetType.fakeVanish
            : TargetType.fakePersistent;

        targets.add(RadarTarget(
          lat: point.lat,
          lng: point.lng,
          type: type,
        ));
      }

      attempts++;
    }

    return targets;
  }
}
