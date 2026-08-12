import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/sync/data/datasources/establishment_remote_data_source.dart';
import 'package:frontend_mayoral/features/sync/data/repositories/initial_data_sync_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('InitialDataSyncRepositoryImpl', () {
    late _MemorySecureStorage storage;
    late _RecordingAnimalStore animalStore;
    late _RecordingCategoryStore categoryStore;
    late _RecordingWeighingStore weighingStore;
    late List<Map<String, Object?>> establishments;

    setUp(() {
      storage = _MemorySecureStorage();
      animalStore = _RecordingAnimalStore();
      categoryStore = _RecordingCategoryStore();
      weighingStore = _RecordingWeighingStore();
      establishments = [];
    });

    InitialDataSyncRepositoryImpl createRepository() {
      return InitialDataSyncRepositoryImpl(
        secureStorage: storage,
        establishmentRemoteDataSource: EstablishmentRemoteDataSource(
          backendBaseUrl: 'http://localhost:8000',
          tokenProvider: const _FixedTokenProvider(),
          client: MockClient((request) async {
            expect(request.url.path, '/api/v1/establecimientos');
            return http.Response(
              jsonEncode({'success': true, 'data': establishments}),
              200,
            );
          }),
        ),
        animalStore: animalStore,
        categoryStore: categoryStore,
        weighingStore: weighingStore,
      );
    }

    test('syncs a new establishment after an initially empty catalog', () async {
      final repository = createRepository();

      final emptyResult = await repository.syncForUser(_userId);
      expect(emptyResult, isA<Success<PostAuthenticationSummary>>());
      expect((emptyResult as Success<PostAuthenticationSummary>).data.hasEstablishments, isFalse);

      establishments = [_establishmentJson(_firstEstablishmentId)];
      final populatedResult = await repository.syncForUser(_userId);
      expect(populatedResult, isA<Success<PostAuthenticationSummary>>());
      expect(
        (populatedResult as Success<PostAuthenticationSummary>).data.establishmentIds,
        [_firstEstablishmentId],
      );
      expect(categoryStore.pulledIds, [_firstEstablishmentId]);
      expect(animalStore.pulledIds, [_firstEstablishmentId]);
      expect(weighingStore.pulledIds, [_firstEstablishmentId]);
    });

    test('downloads only establishments not initialized before', () async {
      final repository = createRepository();
      establishments = [_establishmentJson(_firstEstablishmentId)];
      await repository.syncForUser(_userId);

      establishments = [
        _establishmentJson(_firstEstablishmentId),
        _establishmentJson(_secondEstablishmentId),
      ];
      await repository.syncForUser(_userId);

      expect(categoryStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
      ]);
      expect(animalStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
      ]);
      expect(weighingStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
      ]);
    });

    test('resumes a partial failure without repeating completed data', () async {
      final repository = createRepository();
      establishments = [
        _establishmentJson(_firstEstablishmentId),
        _establishmentJson(_secondEstablishmentId),
      ];
      weighingStore.failingId = _secondEstablishmentId;

      expect(
        await repository.syncForUser(_userId),
        isA<Failure<PostAuthenticationSummary>>(),
      );

      weighingStore.failingId = null;
      await repository.syncForUser(_userId);

      expect(categoryStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
        _secondEstablishmentId,
      ]);
      expect(animalStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
        _secondEstablishmentId,
      ]);
      expect(weighingStore.pulledIds, [
        _firstEstablishmentId,
        _secondEstablishmentId,
        _secondEstablishmentId,
      ]);
    });
  });
}

const _userId = 'user-1';
const _firstEstablishmentId = 'establishment-1';
const _secondEstablishmentId = 'establishment-2';

Map<String, Object?> _establishmentJson(String id) => {
  'id': id,
  'owner_id': _userId,
  'nombre': 'Campo $id',
  'nro_renspa': '01.001.0.00001/00',
  'created_at': '2026-08-08T10:00:00Z',
  'updated_at': '2026-08-08T10:00:00Z',
};

class _FixedTokenProvider implements BackendAccessTokenProvider {
  const _FixedTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}

class _MemorySecureStorage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class _RecordingAnimalStore implements AnimalBrickStore {
  final pulledIds = <String>[];

  @override
  Future<void> pullRemoteAnimals(String establishmentId) async {
    pulledIds.add(establishmentId);
  }

  @override
  Future<BrickAnimalModel> cacheAnimal(BrickAnimalModel animal) => throw UnimplementedError();

  @override
  Future<BrickAnimalModel?> getAnimalById(String animalId) => throw UnimplementedError();

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() => throw UnimplementedError();

  @override
  Future<BrickAnimalModel> upsertAnimal(BrickAnimalModel animal) => throw UnimplementedError();
}

class _RecordingCategoryStore implements CategoriaBrickStore {
  final pulledIds = <String>[];

  @override
  Future<void> pullRemoteCategorias(String establishmentId) async {
    pulledIds.add(establishmentId);
  }

  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias(String establishmentId) => throw UnimplementedError();

  @override
  Future<BrickCategoriaModel> upsertCategoria(BrickCategoriaModel categoria) => throw UnimplementedError();
}

class _RecordingWeighingStore implements PesajeBrickStore {
  final pulledIds = <String>[];
  String? failingId;

  @override
  Future<void> pullRemotePesajes(
    String establishmentId, {
    String? animalId,
  }) async {
    pulledIds.add(establishmentId);
    if (establishmentId == failingId) {
      throw StateError('Simulated sync failure.');
    }
  }

  @override
  Future<List<BrickPesajeModel>> getLocalPesajes() => throw UnimplementedError();

  @override
  Future<List<BrickPesajeModel>> getLocalPesajesByAnimal(String animalId) => throw UnimplementedError();

  @override
  Future<List<BrickPesajeModel>> loadPesajesByAnimal(
    String establishmentId,
    String animalId,
  ) => throw UnimplementedError();

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) => throw UnimplementedError();
}
