import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/health_event.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/health_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/health/data/repositories/health_repository_impl.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/domain/use_cases/health_use_cases.dart';
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
    for (final id in ['animal-1', 'animal-2']) {
      await animals.cacheAnimal(
        BrickAnimalModel(
          localId: id,
          rfidTagNumber: id == 'animal-1' ? '000000000000001' : '000000000000002',
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

class _Storage implements SecureStorageService {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async => _values[key] = value;
}
