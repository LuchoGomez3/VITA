import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/domain/repositories/initial_data_sync_repository.dart';

/// Implementacion que descarga datos iniciales a SQLite para uso offline.
class InitialDataSyncRepositoryImpl implements InitialDataSyncRepository {
  /// Crea el repositorio con storage local y stores Brick por entidad.
  const InitialDataSyncRepositoryImpl({
    required SecureStorageService secureStorage,
    required EstablishmentRemoteDataSource establishmentRemoteDataSource,
    required AnimalBrickStore animalStore,
  }) : _secureStorage = secureStorage,
       _establishmentRemoteDataSource = establishmentRemoteDataSource,
       _animalStore = animalStore;

  final SecureStorageService _secureStorage;
  final EstablishmentRemoteDataSource _establishmentRemoteDataSource;
  final AnimalBrickStore _animalStore;

  @override
  Future<Result<void>> syncForUser(String userId) async {
    final markerKey = SecureStorageKeys.initialDataSyncCompleted(userId);

    try {
      final completed = await _secureStorage.read(markerKey);
      if (completed == 'true') {
        return const Result.success(null);
      }

      final establishmentIds = await _establishmentRemoteDataSource.fetchEstablishmentIds();
      _logInitialSyncStep('establishments=${establishmentIds.length}');
      for (final establishmentId in establishmentIds) {
        _logInitialSyncStep('pulling animals for establishment=$establishmentId');
        await _animalStore.pullRemoteAnimals(establishmentId);
      }
      await _secureStorage.write(key: markerKey, value: 'true');

      return const Result.success(null);
    } on SocketException {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron preparar los datos offline por falta de conexion.',
          code: DomainErrorCode.offline,
        ),
      );
    } on TimeoutException {
      return const Result.failure(
        DomainException(
          message: 'La preparacion de datos offline tardo demasiado.',
          code: DomainErrorCode.offline,
        ),
      );
    } on Object catch (error, stackTrace) {
      _logInitialSyncError(error, stackTrace);
      return const Result.failure(
        DomainException(
          message: 'No se pudieron preparar los datos offline.',
          code: DomainErrorCode.syncFailed,
        ),
      );
    }
  }

  void _logInitialSyncError(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[Initial data sync] failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _logInitialSyncStep(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[Initial data sync] $message');
  }
}
