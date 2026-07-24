import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('InitialDataSyncRepositoryImpl', () {
    final tokenProvider = SessionBackendAccessTokenProvider.instance;

    setUp(() {
      tokenProvider.session = BackendTokenSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        accessTokenExpiresAt: DateTime.now().toUtc().add(
          const Duration(hours: 1),
        ),
      );
    });

    tearDown(tokenProvider.clearAccessToken);

    test(
      'descarga categorias, animales y pesajes antes de guardar el marcador',
      () async {
        final operations = <String>[];
        final storage = _MemorySecureStorage();
        final repository = InitialDataSyncRepositoryImpl(
          secureStorage: storage,
          establishmentRemoteDataSource: EstablishmentRemoteDataSource(
            backendBaseUrl: 'http://localhost:8000',
            tokenProvider: tokenProvider,
            client: MockClient((request) async {
              expect(request.url.path, '/api/v1/establecimientos');
              expect(request.headers['Authorization'], 'Bearer access-token');
              return http.Response(
                jsonEncode({
                  'data': [
                    {'id': 'establishment-1'},
                    {'id': 'establishment-2'},
                  ],
                }),
                200,
              );
            }),
          ),
          animalStore: _FakeAnimalStore(operations),
          categoryStore: _FakeCategoryStore(operations),
          weighingStore: _FakeWeighingStore(operations),
        );

        final result = await repository.syncForUser('user-1');

        expect(result, const Result<void>.success(null));
        expect(operations, [
          'categories:establishment-1',
          'animals:establishment-1',
          'weighings:establishment-1',
          'categories:establishment-2',
          'animals:establishment-2',
          'weighings:establishment-2',
        ]);
        expect(
          await storage.read(
            SecureStorageKeys.initialDataSyncCompleted('user-1'),
          ),
          'true',
        );
      },
    );
  });
}

class _FakeAnimalStore implements AnimalBrickStore {
  _FakeAnimalStore(this.operations);

  final List<String> operations;

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {
    operations.add('animals:$establishmentId');
  }

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) {
    throw UnimplementedError();
  }

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() {
    throw UnimplementedError();
  }

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) {
    throw UnimplementedError();
  }
}

class _FakeCategoryStore implements CategoriaBrickStore {
  _FakeCategoryStore(this.operations);

  final List<String> operations;

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {
    operations.add('categories:$establishmentId');
  }

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(
    String establishmentId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<BrickCategoriaModel> upsertCategoria(
    BrickCategoriaModel categoria,
  ) {
    throw UnimplementedError();
  }
}

class _MemorySecureStorage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    _values[key] = value;
  }
}

class _FakeWeighingStore implements PesajeBrickStore {
  _FakeWeighingStore(this.operations);

  final List<String> operations;

  @override
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  }) async {
    operations.add('weighings:$establishmentId');
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() {
    throw UnimplementedError();
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(String animalId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) {
    throw UnimplementedError();
  }
}
