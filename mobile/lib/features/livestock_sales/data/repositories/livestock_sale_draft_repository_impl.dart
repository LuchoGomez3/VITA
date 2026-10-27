import 'dart:convert';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/mappers/livestock_sale_saved_draft_mapper.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_draft_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_draft_repository.dart';

/// Guarda borradores con el almacenamiento cifrado disponible en el equipo.
class LivestockSaleDraftRepositoryImpl implements LivestockSaleDraftRepository {
  /// Crea el repositorio con una dependencia reemplazable en pruebas.
  const LivestockSaleDraftRepositoryImpl({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<Result<LivestockSaleSavedDraft?>> load({
    required String userId,
    required String establishmentId,
  }) async {
    try {
      final value = await _secureStorage.read(
        SecureStorageKeys.livestockSaleDraft(userId, establishmentId),
      );
      if (value == null) return const Result.success(null);
      final json = jsonDecode(value);
      if (json is! Map<String, Object?>) {
        return const Result.failure(
          DomainException(
            message: 'invalid_livestock_sale_draft',
            reason: LivestockSaleDraftError.invalidData,
          ),
        );
      }
      return Result.success(LivestockSaleSavedDraftMapper.fromJson(json));
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'livestock_sale_draft_read_failed',
          reason: LivestockSaleDraftError.localRead,
        ),
      );
    }
  }

  @override
  Future<Result<void>> save({
    required String userId,
    required LivestockSaleSavedDraft draft,
  }) async {
    try {
      await _secureStorage.write(
        key: SecureStorageKeys.livestockSaleDraft(
          userId,
          draft.establishmentId,
        ),
        value: jsonEncode(LivestockSaleSavedDraftMapper.toJson(draft)),
      );
      return const Result.success(null);
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'livestock_sale_draft_write_failed',
          reason: LivestockSaleDraftError.localWrite,
        ),
      );
    }
  }

  @override
  Future<Result<void>> delete({
    required String userId,
    required String establishmentId,
  }) async {
    try {
      await _secureStorage.delete(
        SecureStorageKeys.livestockSaleDraft(userId, establishmentId),
      );
      return const Result.success(null);
    } on Object {
      return const Result.failure(
        DomainException(
          message: 'livestock_sale_draft_delete_failed',
          reason: LivestockSaleDraftError.localDelete,
        ),
      );
    }
  }
}
