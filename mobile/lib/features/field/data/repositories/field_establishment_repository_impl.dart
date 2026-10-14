import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/field_establishment_repository.dart';

/// Recupera el catálogo de establecimientos ya disponible offline.
class FieldEstablishmentRepositoryImpl implements FieldEstablishmentRepository {
  /// Crea el repositorio con almacenamiento seguro inyectable.
  const FieldEstablishmentRepositoryImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<Result<Map<String, String>>> getEstablishments() async {
    try {
      final encoded = await _storage.read(SecureStorageKeys.establishmentCatalog);
      if (encoded == null || encoded.isEmpty) return const Result.success({});
      final decoded = jsonDecode(encoded);
      if (decoded is! List) throw const FormatException('Invalid establishment catalog.');
      final result = <String, String>{};
      for (final item in decoded.whereType<Map<String, dynamic>>()) {
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
}
