import 'package:uuid/uuid.dart';

/// Model que representa una zona per generar fake tions
class FakeTionsZone {
  final String id;
  final double lat;
  final double lng;
  final double radius;

  FakeTionsZone({
    String? id,
    required this.lat,
    required this.lng,
    required this.radius,
  }) : id = id ?? const Uuid().v4();

  /// Crea un FakeTionsZone des d'un mapa JSON
  factory FakeTionsZone.fromJson(Map<String, dynamic> json) {
    return FakeTionsZone(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  /// Converteix el FakeTionsZone a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
  }

  /// Crea una còpia amb els camps modificats
  FakeTionsZone copyWith({
    String? id,
    double? lat,
    double? lng,
    double? radius,
  }) {
    return FakeTionsZone(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FakeTionsZone && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
