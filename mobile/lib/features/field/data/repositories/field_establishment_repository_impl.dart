import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/field_establishment_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';

/// Recupera el catálogo de establecimientos ya disponible offline.
class FieldEstablishmentRepositoryImpl implements FieldEstablishmentRepository {
  /// Crea el repositorio con almacenamiento seguro inyectable.
  const FieldEstablishmentRepositoryImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<Result<Map<String, String>>> getEstablishments() async {
    try {
      final result = <String, String>{};
      for (final item in await _readCatalog()) {
        if (item case {'id': final String id, 'name': final String name}) {
          result[id] = name;
        }
      }
      return Result.success(result);
    } on Object {
      return const Result.failure(
        DomainException(message: 'No se pudieron leer los establecimientos disponibles.'),
      );
    }
  }

  /// Reusa las coordenadas guardadas que se muestran en Establecimientos.
  Future<FieldMapLocation?> getMapLocation(String establishmentId) async {
    for (final item in await _readCatalog()) {
      if (item['id'] != establishmentId) continue;
      final center = _point(item);
      if (center == null) return null;
      final boundary = item['boundary'];
      return (
        center: center,
        boundary: boundary is List
            ? boundary.whereType<Map<String, Object?>>().map(_point).whereType<FieldMapPoint>().toList()
            : const <FieldMapPoint>[],
      );
    }
    return null;
  }

  Future<Iterable<Map<String, Object?>>> _readCatalog() async {
    final encoded = await _storage.read(SecureStorageKeys.establishmentCatalog);
    if (encoded == null || encoded.isEmpty) return const [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) throw const FormatException('Invalid establishment catalog.');
    return decoded.whereType<Map<String, Object?>>();
  }

  FieldMapPoint? _point(Map<String, Object?> item) {
    if (item case {
      'latitude': final num latitude,
      'longitude': final num longitude,
    } when latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) {
      return (latitude: latitude.toDouble(), longitude: longitude.toDouble());
    }
    return null;
  }
}
