import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/operating_expense_category_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/operating_expense_catalog_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';
import 'package:http/http.dart' as http;

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
    required OperatingExpenseBrickStore operatingExpenseStore,
    required OperatingExpenseCategoryBrickStore operatingExpenseCategoryStore,
    required OperatingExpenseCatalogRemoteDataSource operatingExpenseCatalogRemoteDataSource,
  }) : _secureStorage = secureStorage,
       _establishmentRemoteDataSource = establishmentRemoteDataSource,
       _animalStore = animalStore,
       _categoryStore = categoryStore,
       _weighingStore = weighingStore,
       _operatingExpenseStore = operatingExpenseStore,
       _operatingExpenseCategoryStore = operatingExpenseCategoryStore,
       _operatingExpenseCatalogRemoteDataSource = operatingExpenseCatalogRemoteDataSource;

  final SecureStorageService _secureStorage;
  final EstablishmentRemoteDataSource _establishmentRemoteDataSource;
  final AnimalBrickStore _animalStore;
  final CategoriaBrickStore _categoryStore;
  final PesajeBrickStore _weighingStore;
  final OperatingExpenseBrickStore _operatingExpenseStore;
  final OperatingExpenseCategoryBrickStore _operatingExpenseCategoryStore;
  final OperatingExpenseCatalogRemoteDataSource _operatingExpenseCatalogRemoteDataSource;

  @override
  Future<Result<PostAuthenticationSummary>> sync() async {
    try {
      final establishments = await _establishmentRemoteDataSource.fetchEstablishments();
      await _secureStorage.write(
        key: SecureStorageKeys.establishmentCatalog,
        value: jsonEncode(
          establishments.map((establishment) => establishment.toJson()).toList(),
        ),
      );
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
        if (establishment.role.canViewFinancialInformation) {
          _logInitialSyncStep(
            'pulling operating expense categories for establishment=$establishmentId',
          );
          await _operatingExpenseCategoryStore.cacheRemoteCategories(
            await _operatingExpenseCatalogRemoteDataSource.fetchCustomCategories(establishmentId),
          );
          _logInitialSyncStep(
            'pulling operating expenses for establishment=$establishmentId',
          );
          await _operatingExpenseStore.pullRemoteExpenses(establishmentId);
        }
      }

      return Result.success(
        PostAuthenticationSummary(
          establishmentIds: establishments.map((establishment) => establishment.id).toList(growable: false),
        ),
      );
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
