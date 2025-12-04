import 'package:uuid/uuid.dart';
import 'target_type.dart';

/// Model que representa un objectiu al radar (tió real o fals)
class RadarTarget {
  final String id;
  final double lat;
  final double lng;
  final TargetType type;
  bool found;

  RadarTarget({
    String? id,
    required this.lat,
    required this.lng,
    required this.type,
    this.found = false,
  }) : id = id ?? const Uuid().v4();

  /// Crea un RadarTarget des d'un mapa JSON
  factory RadarTarget.fromJson(Map<String, dynamic> json) {
    return RadarTarget(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: TargetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TargetType.realTio,
      ),
      found: json['found'] as bool? ?? false,
    );
  }

  /// Converteix el RadarTarget a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'type': type.name,
      'found': found,
    };
  }

  /// Crea una còpia amb els camps modificats
  RadarTarget copyWith({
    String? id,
    double? lat,
    double? lng,
    TargetType? type,
    bool? found,
  }) {
    return RadarTarget(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      found: found ?? this.found,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadarTarget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
