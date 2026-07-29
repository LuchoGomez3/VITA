import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';

/// Implementacion que descarga datos iniciales a SQLite para uso offline.
///
/// Esta clase es infraestructura de sync: puede usar secure storage, data
/// sources HTTP y stores Brick. El dominio solo conoce el contrato
/// [InitialDataSyncRepository].
class InitialDataSyncRepositoryImpl implements InitialDataSyncRepository {
  /// Crea el repositorio con storage local y stores Brick por entidad.
  ///
  /// [establishmentRemoteDataSource] obtiene el alcance del usuario autenticado.
  /// [animalStore] descarga animales de cada establecimiento hacia SQLite.
  const InitialDataSyncRepositoryImpl({
    required SecureStorageService secureStorage,
    required EstablishmentRemoteDataSource establishmentRemoteDataSource,
    required AnimalBrickStore animalStore,
    required CategoriaBrickStore categoryStore,
    required PesajeBrickStore weighingStore,
  }) : _secureStorage = secureStorage,
       _establishmentRemoteDataSource = establishmentRemoteDataSource,
       _animalStore = animalStore,
       _categoryStore = categoryStore,
       _weighingStore = weighingStore;

  final SecureStorageService _secureStorage;
  final EstablishmentRemoteDataSource _establishmentRemoteDataSource;
  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final PesajeBrickStore _weighingStore;

  @override
  Future<Result<void>> syncForUser(String userId) async {
    final markerKey = SecureStorageKeys.initialDataSyncCompleted(userId);

    try {
      final establishments =
          await _establishmentRemoteDataSource.fetchEstablishments();
      await _secureStorage.write(
        key: SecureStorageKeys.establishmentCatalog,
        value: jsonEncode(
          establishments.map((establishment) => establishment.toJson()).toList(),
        ),
      );
      final completed = await _secureStorage.read(markerKey);
      if (completed == 'true') {
        return const Result.success(null);
      }

      _logInitialSyncStep('establishments=${establishments.length}');
      for (final establishment in establishments) {
        final establishmentId = establishment.id;
        // El catalogo se cachea antes que los animales para que sus referencias
        // de categoria ya esten disponibles en los flujos offline.
        _logInitialSyncStep(
          'pulling categories for establishment=$establishmentId',
        );
        await _categoryStore.pullRemoteCategorias(establishmentId);
        _logInitialSyncStep(
          'pulling animals for establishment=$establishmentId',
        );
        await _animalStore.pullRemoteAnimals(establishmentId);
        _logInitialSyncStep(
          'pulling weighings for establishment=$establishmentId',
        );
        await _weighingStore.pullRemotePesajes(establishmentId);
      }
      await _secureStorage.write(key: markerKey, value: 'true');

      return const Result.success(null);
    } on SocketException {
      return const Result.failure(
        DomainException(
          message:
              'No se pudieron preparar los datos offline por falta de conexion.',
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
