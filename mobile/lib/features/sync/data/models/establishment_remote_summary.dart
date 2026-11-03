import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Datos completos de un establecimiento conservados para el uso offline.
class EstablishmentRemoteSummary {
  /// Crea el establecimiento recibido desde el backend.
  const EstablishmentRemoteSummary({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.renspaNumber,
    this.cuit,
    this.areaHectares,
    this.province,
    this.department,
    this.locality,
    this.latitude,
    this.longitude,
    this.boundary = const [],
  });

  /// Construye el establecimiento desde el contrato REST.
  factory EstablishmentRemoteSummary.fromJson(Map<String, dynamic> json) {
    return EstablishmentRemoteSummary(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['nombre'] as String,
      role: UserRolePermissions.fromBackend(_readString(json['rol'])),
      renspaNumber: json['nro_renspa'] as String?,
      cuit: json['cuit'] as String?,
      areaHectares: _readDouble(json['superficie_ha']),
      province: json['provincia'] as String?,
      department: json['departamento'] as String?,
      locality: json['localidad'] as String?,
      latitude: _readDouble(json['latitud']),
      longitude: _readDouble(json['longitud']),
      boundary: _readBoundary(json['poligono']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// ID estable compartido por los datos productivos.
  final String id;

  /// ID del propietario del establecimiento.
  final String ownerId;

  /// Nombre visible para selectores de establecimiento.
  final String name;

  /// Rol del usuario autenticado en este establecimiento.
  final UserRole role;

  /// Numero RENSPA informado por el backend.
  final String? renspaNumber;

  /// CUIT asociado al establecimiento.
  final String? cuit;

  /// Superficie productiva expresada en hectareas.
  final double? areaHectares;

  /// Provincia del establecimiento.
  final String? province;

  /// Departamento del establecimiento.
  final String? department;

  /// Localidad del establecimiento.
  final String? locality;

  /// Latitud del punto de referencia del campo, en grados.
  final double? latitude;

  /// Longitud del punto de referencia del campo, en grados.
  final double? longitude;

  /// Vértices del contorno del campo, en orden; vacío si no se delimitó.
  final List<({double latitude, double longitude})> boundary;

  /// Fecha de creacion informada por el backend.
  final DateTime createdAt;

  /// Fecha de ultima actualizacion informada por el backend.
  final DateTime updatedAt;

  /// Convierte todos los datos al formato persistido para Perfil y Home.
  Map<String, Object?> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'name': name,
    'role': role.backendValue,
    'renspa_number': renspaNumber,
    'cuit': cuit,
    'area_hectares': areaHectares,
    'province': province,
    'department': department,
    'locality': locality,
    'latitude': latitude,
    'longitude': longitude,
    'boundary': [
      for (final point in boundary) {'latitude': point.latitude, 'longitude': point.longitude},
    ],
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  static double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  /// El backend manda `[{orden, latitud, longitud}]`; un vértice incompleto
  /// invalida el contorno entero en vez de dibujar una figura distinta.
  static List<({double latitude, double longitude})> _readBoundary(Object? value) {
    if (value is! List) {
      return const [];
    }
    final vertices = value.whereType<Map<String, dynamic>>().toList();
    if (vertices.length != value.length) {
      return const [];
    }
    vertices.sort((a, b) => ((a['orden'] as num?) ?? 0).compareTo((b['orden'] as num?) ?? 0));
    final points = <({double latitude, double longitude})>[];
    for (final vertex in vertices) {
      final latitude = _readDouble(vertex['latitud']);
      final longitude = _readDouble(vertex['longitud']);
      if (latitude == null || longitude == null) {
        return const [];
      }
      points.add((latitude: latitude, longitude: longitude));
    }
    return points;
  }

  static String? _readString(Object? value) => value is String ? value : null;
}
