import 'target_type.dart';

/// Model que representa un objectiu en coordenades polars
/// per a renderitzar al radar
class PolarTarget {
  /// Angle en radians (0 = nord, positiu en sentit horari)
  final double angle;
  
  /// Factor de distància (0 = centre, 1 = vora del radar)
  final double factor;
  
  /// Tipus de target
  final TargetType type;
  
  /// Si el target ha estat trobat
  final bool found;
  
  /// ID original del target
  final String id;

  const PolarTarget({
    required this.angle,
    required this.factor,
    required this.type,
    required this.found,
    required this.id,
  });

  @override
  String toString() {
    return 'PolarTarget(angle: $angle, factor: $factor, type: $type, found: $found)';
  }
}
