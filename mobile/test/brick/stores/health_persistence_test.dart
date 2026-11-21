import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/datasources/health_remote_data_source.dart';
import 'package:frontend_mayoral/features/health/data/mappers/health_codec.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/data/services/health_sync_service.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const farm = 'health-farm';
  const author = (userId: 'author', generation: 1);
  const other = (userId: 'other', generation: 2);
  const sampling = HealthPractice(id: 'study', name: 'Sangrado', kind: HealthPracticeKind.sampling);
  final date = DateTime.utc(2026, 10, 15);
  late Directory directory;
  late String sqlitePath;
  late String queuePath;
  late HealthBrickStore store;
  late HealthRepositoryImpl repository;
  late HealthSession current;

  setUpAll(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('vita_health_test_');
    sqlitePath = path.join(directory.path, 'brick.sqlite');
    queuePath = path.join(directory.path, 'queue.sqlite');
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      backendBaseUrl: 'http://localhost',
      localDatabaseFactory: databaseFactoryFfi,
    );
    final brick = AppBrickRepository.instance;
    BrickAnimalStore.configure(brick);
    final animals = BrickAnimalStore.instance;
    for (final id in ['animal-1', 'animal-2', 'animal-3', 'animal-4']) {
      await animals.cacheAnimal(
        BrickAnimalModel(
          localId: id,
          rfidTagNumber: id.split('-').last.padLeft(15, '0'),
          visualTag: id,
          sex: BrickAnimalSex.female,
          breed: '',
          birthDate: date,
          categoryId: '',
          lotId: '',
          establishmentId: farm,
          initialWeight: 0,
          weighingMethod: BrickAnimalWeighingMethod.manual,
          weighingDate: date,
          createdAt: date,
          updatedAt: date,
          productiveStatus: BrickAnimalProductiveStatus.active,
          localRegistrationAuthorId: author.userId,
        ),
      );
    }
    final catalog = EstablishmentCatalog(secureStorage: _Storage());
    await catalog.upsert(const EstablishmentMembership(id: farm, name: 'Campo', role: UserRole.employee));
    store = HealthBrickStore(brick);
    current = author;
    repository = HealthRepositoryImpl(
      store: store,
      animals: animals,
      memberships: catalog,
      session: () => current,
      now: () => date,
    );
  });

  tearDownAll(() async {
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    await directory.delete(recursive: true);
  });

  test('catalogue gates new applications and keeps its establishment', () async {
    expect(await repository.getCatalog(farm), isNull);
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    expect((await repository.getCatalog(farm))?.practices.single, sampling);
    await expectLater(repository.getCatalog('another-farm'), throwsA(isA<HealthFailure>()));
  });

  test('persists one outbox entry for a group and one result on an existing event', () async {
    final recipients = await repository.getRecipients(farm, ['animal-1', 'animal-2']);
    final original = HealthRegistration(
      establishmentId: farm,
      occurredAt: date,
      practice: sampling,
      details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
      responsible: 'Operario',
      recipients: [
        recipients.first,
        recipients.last.copyWith(sampleReference: 'muestra-2'),
      ],
    );
    await RegisterHealthEventsUseCase(repository)(original);
    final restartedStore = HealthBrickStore(AppBrickRepository.instance);
    final creation = (await restartedStore.operations(author.userId)).single;
    expect(HealthRepositoryImpl.registrationEventIds(creation), hasLength(2));

    final history = await repository.watchHistory(farm, 'animal-2').first;
    final event = history.single;
    expect(event.recipient.sampleReference, 'muestra-2');
    expect(event.syncStatus, HealthSyncStatus.pending);

    await RecordHealthResultUseCase(repository)(event, 'Resultado informado', date);
    final attempts = await restartedStore.operations(author.userId);
    expect(attempts.where((row) => row.resultEventId == event.id), hasLength(1));
    expect(await restartedStore.events(farm, animalId: 'animal-2'), hasLength(1));
    final updated = (await repository.watchHistory(farm, 'animal-2').first).single;
    expect(updated.id, event.id);
    expect(updated.result?.value, 'Resultado informado');
    expect(updated.resultSyncStatus, HealthSyncStatus.pending);

    current = other;
    expect(await repository.watchHistory(farm, 'animal-2').first, isEmpty);
    expect(await restartedStore.operations(other.userId), isEmpty);
    expect(await repository.getRecipients(farm, ['animal-1']), isEmpty);
    current = author;

    final paths = <String>[];
    final registrationBodies = <String>[];
    final knownAnimals = <String>{};
    final resultEvent = updated.copyWith(
      result: HealthStudyResult(value: 'Aceptado desde otro teléfono', reportedAt: date, reportedById: 'other'),
    );
    final initialEvents = [
      (await repository.watchHistory(farm, 'animal-1').first).single,
      event,
    ];
    final adapter = HealthRemoteDataSource(
      baseUrl: 'http://localhost',
      tokens: const _Tokens(),
      client: MockClient((request) async {
        paths.add('${request.method} ${request.url.path}');
        final parts = request.url.pathSegments;
        if (parts.contains('animales')) {
          if (request.method == 'GET') {
            return knownAnimals.contains(parts.last)
                ? _response({'id': parts.last, 'establecimiento_id': farm})
                : http.Response('', 404);
          }
          final body = HealthCodec.object(request.body);
          final id = body['id'] as String;
          expect(body.containsKey('local_registration_author_id'), isFalse);
          knownAnimals.add(id);
          return _response({'id': id, 'establecimiento_id': farm});
        }
        if (request.method == 'POST') {
          registrationBodies.add(request.body);
          if (registrationBodies.length == 1) throw http.ClientException('Interrupted response');
          return _response(initialEvents.map(_wire).toList());
        }
        expect(parts[parts.length - 2], event.id);
        return http.Response(
          jsonEncode({
            'success': false,
            'errors': [
              {
                'code': 'resultado_ya_completado',
                'details': {'evento': _wire(resultEvent)},
              },
            ],
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: HealthAnimalRegistrationRecovery(BrickAnimalStore.instance, adapter, repository).call,
    );
    addTearDown(sync.dispose);
    await sync.request();
    expect((await restartedStore.operations(author.userId)).map((row) => row.localId), contains(creation.localId));
    await sync.request();
    expect(registrationBodies, hasLength(2));
    expect(registrationBodies.toSet(), hasLength(1));
    expect(
      paths.where((entry) => !entry.startsWith('GET ')),
      [
        'POST /api/v1/animales',
        'POST /api/v1/animales',
        'POST /api/v1/eventos_sanitarios',
        'POST /api/v1/eventos_sanitarios',
        'PUT /api/v1/eventos_sanitarios/${event.id}/resultado',
      ],
    );
    final reconciled = (await repository.watchHistory(farm, 'animal-2').first).single;
    expect(reconciled.result?.value, resultEvent.result?.value);
    expect(reconciled.resultSyncStatus, isNull);
    expect(reconciled.resultErrorCode, 'resultado_ya_completado');
    expect(await restartedStore.operations(author.userId), isEmpty);
  });

  test('applies the canonical result and tombstone without consuming drafts on unrelated changes', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-1', 'animal-2']);
    await RegisterHealthEventsUseCase(repository)(
      HealthRegistration(
        establishmentId: farm,
        occurredAt: date,
        practice: sampling,
        details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
        responsible: 'Resultados',
        recipients: recipients,
      ),
    );
    final creation = (await store.operations(author.userId)).single;
    final events = [
      for (final id in HealthRepositoryImpl.registrationEventIds(creation))
        (await repository.localEvent(farm, id))!.copyWith(syncStatus: HealthSyncStatus.synchronized),
    ];
    await repository.accept(author, creation, events);
    final [first, second] = events;
    await RecordHealthResultUseCase(repository)(first, 'Resultado rechazado', date);
    final rejected = (await store.operations(author.userId)).single;
    await repository.reject(author, rejected, 'resultado_invalido');
    await RecordHealthResultUseCase(repository)(second, 'Resultado pendiente', date);

    current = other;
    addTearDown(() => current = author);
    final metadataTime = date.add(const Duration(minutes: 1));
    await repository.reconcilePage(other, farm, [first.copyWith(notes: 'Nota vigente', updatedAt: metadataTime)], '1');
    final retained = (await repository.localEvent(farm, first.id))!;
    expect(retained.notes, 'Nota vigente');
    expect(retained.result?.value, 'Resultado rechazado');
    expect(retained.resultSyncStatus, HealthSyncStatus.rejected);
    expect(await store.operations(author.userId), hasLength(2));

    final updated = date.add(const Duration(minutes: 2));
    final canonical = HealthStudyResult(value: 'Resultado vigente', reportedAt: updated, reportedById: other.userId);
    await repository.reconcilePage(other, farm, [
      first.copyWith(result: canonical, updatedAt: updated),
      second.copyWith(deletedAt: updated, updatedAt: updated),
    ], '2');

    final visible = (await repository.watchHistory(farm, first.recipient.animalId).first).singleWhere(
      (event) => event.id == first.id,
    );
    expect(visible.result, canonical);
    expect(visible.resultSyncStatus, isNull);
    expect(visible.resultErrorCode, isNull);
    expect(await repository.localEvent(farm, second.id), isNotNull);
    expect(
      (await repository.watchHistory(farm, second.recipient.animalId).first).map((event) => event.id),
      isNot(contains(second.id)),
    );
    expect(await store.operations(author.userId), isEmpty);
    expect(await repository.cursor(farm), '2');
  });

  test('allows correcting a group after a definitive animal rejection and keeps an excluded study result', () async {
    await repository.cacheCatalog(
      author,
      const HealthCatalog(establishmentId: farm, practices: [sampling], products: []),
    );
    final recipients = await repository.getRecipients(farm, ['animal-3', 'animal-4']);
    final registration = HealthRegistration(
      establishmentId: farm,
      occurredAt: date,
      practice: sampling,
      details: const HealthObservation(description: 'Control', sampleType: 'Sangre'),
      responsible: 'Operario',
      recipients: [
        recipients.first.copyWith(sampleReference: 'muestra-3'),
        recipients.last,
      ],
    );
    await RegisterHealthEventsUseCase(repository)(registration);
    final group = (await store.operations(author.userId)).single;
    final kept = (await repository.watchHistory(farm, 'animal-3').first).single;
    final blocked = (await repository.watchHistory(farm, 'animal-4').first).single;
    await RecordHealthResultUseCase(repository)(blocked, 'Resultado de muestra 4', date);

    var rejectedAnimalAttempts = 0;
    final groupRequests = <List<String>>[];
    final adapter = HealthRemoteDataSource(
      baseUrl: 'http://localhost',
      tokens: const _Tokens(),
      client: MockClient((request) async {
        final resource = request.url.pathSegments.last;
        if (resource == 'animal-3') return _response({'id': resource, 'establecimiento_id': farm});
        if (resource == 'animal-4') return http.Response('', 404);
        if (resource == 'animales') {
          if (++rejectedAnimalAttempts == 1) return http.Response('', 503);
          return http.Response(
            jsonEncode({
              'success': false,
              'errors': [
                {'code': 'caravana_duplicada'},
              ],
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        }
        final body = HealthCodec.object(request.body);
        final animals = (body['animales'] as List).cast<Map<String, dynamic>>();
        groupRequests.add([for (final animal in animals) animal['animal_id'] as String]);
        expect(body['id'], isNot(group.localId));
        expect(animals.single['id'], kept.id);
        expect(animals.single['referencia_muestra'], 'muestra-3');
        return _response([_wire(kept)]);
      }),
    );
    final sync = HealthSyncService(
      repository: repository,
      remote: adapter,
      resolveAnimal: HealthAnimalRegistrationRecovery(BrickAnimalStore.instance, adapter, repository).call,
    );
    addTearDown(sync.dispose);

    await sync.request();
    expect((await repository.localEvent(farm, kept.id))?.syncStatus, HealthSyncStatus.pending);
    await sync.request();
    final rejected = (await repository.localEvent(farm, kept.id))!;
    expect(rejected.syncStatus, HealthSyncStatus.rejected);
    expect(rejected.syncErrorCode, 'alta_animal_rechazada');
    expect(groupRequests, isEmpty);

    final draft = (await repository.getRejectedRegistration(rejected))!;
    expect(draft.id, group.localId);
    expect(draft.registration.recipients, hasLength(2));
    final selectable = await repository.getRecipients(farm, ['animal-3', 'animal-4']);
    expect(selectable.map((recipient) => recipient.animalId), ['animal-3']);
    await RegisterHealthEventsUseCase(repository)(
      draft.registration.copyWith(
        recipients: [draft.registration.recipients.firstWhere((r) => r.animalId == 'animal-3')],
      ),
      replacingOperationId: draft.id,
    );
    await sync.request();

    expect(groupRequests, [
      ['animal-3'],
    ]);
    expect((await repository.localEvent(farm, kept.id))?.syncStatus, HealthSyncStatus.synchronized);
    final remaining = (await repository.localEvent(farm, blocked.id))!;
    expect(remaining.syncStatus, HealthSyncStatus.rejected);
    expect(remaining.result?.value, 'Resultado de muestra 4');
    final pendingCorrection = (await repository.getRejectedRegistration(remaining))!;
    expect(pendingCorrection.registration.recipients.map((recipient) => recipient.animalId), ['animal-4']);
    expect(await store.operations(author.userId), hasLength(2));
  });

  test('rolls back all changes when the session changes inside a transaction', () async {
    var calls = 0;
    await expectLater(
      store.save(
        events: [
          BrickHealthEventModel(localId: 'rollback-1', establishmentId: farm, animalId: 'rollback', payload: '{}'),
          BrickHealthEventModel(localId: 'rollback-2', establishmentId: farm, animalId: 'rollback', payload: '{}'),
        ],
        requireSession: () {
          if (++calls == 2) throw StateError('session switched');
        },
      ),
      throwsStateError,
    );
    expect(await store.events(farm, animalId: 'rollback'), isEmpty);
  });
}

Map<String, dynamic> _wire(HealthEvent event) => HealthCodec.object(HealthCodec.eventRow(event).payload);

http.Response _response(Object data) => http.Response(
  jsonEncode({'success': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json'},
);

class _Tokens implements RefreshableBackendAccessTokenProvider {
  const _Tokens();

  @override
  Future<String?> getAccessToken() async => 'synthetic';

  @override
  Future<String?> refreshAccessToken() async => 'synthetic-refresh';
}

class _Storage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async => _values[key] = value;
}
