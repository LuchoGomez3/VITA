/// Datos completos de un establecimiento conservados para el uso offline.
class EstablishmentRemoteSummary {
  /// Crea el establecimiento recibido desde el backend.
  const EstablishmentRemoteSummary({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.renspaNumber,
    this.cuit,
    this.areaHectares,
    this.province,
    this.department,
    this.locality,
  });

  /// Construye el establecimiento desde el contrato REST.
  factory EstablishmentRemoteSummary.fromJson(Map<String, dynamic> json) {
    return EstablishmentRemoteSummary(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['nombre'] as String,
      renspaNumber: json['nro_renspa'] as String?,
      cuit: json['cuit'] as String?,
      areaHectares: _readDouble(json['superficie_ha']),
      province: json['provincia'] as String?,
      department: json['departamento'] as String?,
      locality: json['localidad'] as String?,
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

  /// Número RENSPA informado por el backend.
  final String? renspaNumber;

  /// CUIT asociado al establecimiento.
  final String? cuit;

  /// Superficie productiva expresada en hectáreas.
  final double? areaHectares;

  /// Provincia del establecimiento.
  final String? province;

  /// Departamento del establecimiento.
  final String? department;

  /// Localidad del establecimiento.
  final String? locality;

  /// Fecha de creación informada por el backend.
  final DateTime createdAt;

  /// Fecha de última actualización informada por el backend.
  final DateTime updatedAt;

  /// Convierte todos los datos al formato persistido para Perfil y Home.
  Map<String, Object?> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'name': name,
    'renspa_number': renspaNumber,
    'cuit': cuit,
    'area_hectares': areaHectares,
    'province': province,
    'department': department,
    'locality': locality,
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
}
