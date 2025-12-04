import 'dart:math';

/// Utilitats per a càlculs geogràfics
class GeoUtils {
  static const double _earthRadius = 6371000; // Radi de la Terra en metres
  
  /// Metres per grau de latitud (aproximadament constant)
  static const double _metersPerDegreeLat = 111320;

  /// Calcula la distància entre dos punts en metres usant la fórmula de Haversine
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return _earthRadius * c;
  }

  /// Calcula el rumb (bearing) des d'un punt a un altre en radians
  /// Retorna un valor entre 0 i 2π (0 = nord, π/2 = est, π = sud, 3π/2 = oest)
  static double calculateBearing(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLng = _toRadians(lng2 - lng1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);
    
    final x = sin(dLng) * cos(lat2Rad);
    final y = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLng);
    
    var bearing = atan2(x, y);
    
    // Normalitzar a 0-2π
    if (bearing < 0) {
      bearing += 2 * pi;
    }
    
    return bearing;
  }

  /// Genera un punt aleatori dins d'un radi donat des d'un punt central
  static ({double lat, double lng}) generateRandomPoint(
    double centerLat,
    double centerLng,
    double maxRadius,
  ) {
    final random = Random();
    
    // Distància aleatòria amb distribució uniforme en àrea
    final distance = maxRadius * sqrt(random.nextDouble());
    
    // Angle aleatori
    final angle = random.nextDouble() * 2 * pi;
    
    // Convertir a desplaçament en graus
    // _metersPerDegreeLat és una constant que representa metres per grau de latitud
    final dLat = (distance * cos(angle)) / _metersPerDegreeLat;
    // La longitud varia segons la latitud (més estreta als pols)
    final dLng = (distance * sin(angle)) / 
        (_metersPerDegreeLat * cos(_toRadians(centerLat)));
    
    return (lat: centerLat + dLat, lng: centerLng + dLng);
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  
  static double toDegrees(double radians) => radians * 180 / pi;
}
