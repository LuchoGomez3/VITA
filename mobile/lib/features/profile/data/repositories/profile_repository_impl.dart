import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_repository.dart';

/// Lee desde storage los establecimientos descargados durante el login.
class ProfileRepositoryImpl implements ProfileRepository {
  /// Crea el repositorio con el storage seguro compartido.
  const ProfileRepositoryImpl({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<Result<List<EstablishmentDetails>>> getEstablishments() async {
    try {
      final encoded = await _secureStorage.read(
        SecureStorageKeys.establishmentCatalog,
      );
      if (encoded == null || encoded.isEmpty) {
        return const Result.success([]);
      }

      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Invalid establishment catalog.');
      }

      return Result.success(
        decoded.whereType<Map<String, dynamic>>().map(_mapEstablishment).toList(),
      );
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron cargar los establecimientos.',
        ),
      );
    }
  }

  EstablishmentDetails _mapEstablishment(Map<String, dynamic> json) {
    return (
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      renspaNumber: json['renspa_number'] as String?,
      cuit: json['cuit'] as String?,
      areaHectares: (json['area_hectares'] as num?)?.toDouble(),
      province: json['province'] as String?,
      department: json['department'] as String?,
      locality: json['locality'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
