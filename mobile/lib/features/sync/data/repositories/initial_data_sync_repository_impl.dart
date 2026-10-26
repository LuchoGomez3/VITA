import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_lot_movement_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/lot_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';
import 'package:http/http.dart' as http;

/// Sincroniza los datos financieros de un establecimiento habilitado.
typedef SyncOperatingExpenseData = Future<void> Function(String establishmentId);

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
    required LotBrickStore lotStore,
    required PesajeBrickStore weighingStore,
    required AnimalLotMovementBrickStore movementStore,
    required SyncOperatingExpenseData syncOperatingExpenseData,
    Object? Function()? sessionIdentity,
    Future<void> Function(Future<void> Function())? persistSessionData,
  }) : _secureStorage = secureStorage,
       _establishmentRemoteDataSource = establishmentRemoteDataSource,
       _animalStore = animalStore,
       _categoryStore = categoryStore,
       _lotStore = lotStore,
       _weighingStore = weighingStore,
       _movementStore = movementStore,
       _syncOperatingExpenseData = syncOperatingExpenseData,
       _sessionIdentity = sessionIdentity,
       _persistSessionData = persistSessionData;

  final SecureStorageService _secureStorage;
  final EstablishmentRemoteDataSource _establishmentRemoteDataSource;
  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final LotBrickStore _lotStore;
  final PesajeBrickStore _weighingStore;
  final AnimalLotMovementBrickStore _movementStore;
  final SyncOperatingExpenseData _syncOperatingExpenseData;
  final Object? Function()? _sessionIdentity;
  final Future<void> Function(Future<void> Function())? _persistSessionData;

  @override
  Future<Result<PostAuthenticationSummary>> sync() async {
    final session = _sessionIdentity?.call();
    void requireSession() {
      if (session != _sessionIdentity?.call()) {
        throw const DomainException(message: 'Session changed', code: DomainErrorCode.unauthorized);
      }
    }

    try {
      final establishments = await _establishmentRemoteDataSource.fetchEstablishments();
      requireSession();
      Future<void> persistCatalog() async {
        requireSession();
        await _secureStorage.write(
          key: SecureStorageKeys.establishmentCatalog,
          value: jsonEncode(
            establishments.map((establishment) => establishment.toJson()).toList(),
          ),
        );
      }

      final persistSessionData = _persistSessionData;
      if (persistSessionData == null) {
        await persistCatalog();
      } else {
        await persistSessionData(persistCatalog);
      }
      requireSession();
      _logInitialSyncStep('establishments=${establishments.length}');
      _logInitialSyncStep('pulling global animal categories');
      await _categoryStore.pullRemoteCategorias();
      requireSession();
      for (final establishment in establishments) {
        final establishmentId = establishment.id;
        _logInitialSyncStep(
          'pushing pending lots for establishment=$establishmentId',
        );
        await _lotStore.pushPendingLots(establishmentId);
        requireSession();
        _logInitialSyncStep('pulling lots for establishment=$establishmentId');
        await _lotStore.pullRemoteLots(establishmentId);
        requireSession();
        _logInitialSyncStep(
          'pulling animals for establishment=$establishmentId',
        );
        await _animalStore.pullRemoteAnimals(establishmentId);
        requireSession();
        _logInitialSyncStep(
          'pushing pending lot movements for establishment=$establishmentId',
        );
        await _movementStore.pushPendingMovements(establishmentId);
        requireSession();
        _logInitialSyncStep(
          'reconciling animals after lot movements for establishment=$establishmentId',
        );
        await _animalStore.pullRemoteAnimals(establishmentId);
        requireSession();
        _logInitialSyncStep(
          'pulling lot movements for establishment=$establishmentId',
        );
        await _movementStore.pullRemoteMovements(establishmentId);
        requireSession();
        _logInitialSyncStep(
          'pulling weighings for establishment=$establishmentId',
        );
        await _weighingStore.pullRemotePesajes(establishmentId);
        requireSession();
        if (establishment.role.canViewFinancialInformation) {
          _logInitialSyncStep(
            'pulling operating expense data for establishment=$establishmentId',
          );
          await _syncOperatingExpenseData(establishmentId);
          requireSession();
        }
      }

      requireSession();
      return Result.success(
        PostAuthenticationSummary(
          establishmentIds: establishments.map((establishment) => establishment.id).toList(growable: false),
        ),
      );
    } on DomainException catch (error) {
      return Result.failure(error);
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
    } on http.ClientException {
      return const Result.failure(
        DomainException(
          message: 'No se pudieron preparar los datos offline por falta de conexion.',
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
