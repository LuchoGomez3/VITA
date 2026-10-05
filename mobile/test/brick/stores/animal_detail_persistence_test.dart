import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/animal_observation_brick_store.dart';
import 'package:frontend_mayoral/brick/sync/backend_sync_result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('SQLite preserves notes and ignores death responses older than undo', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('vita_animal_detail_');
    final sqlitePath = '${directory.path}/brick.sqlite';
    final queuePath = '${directory.path}/queue.sqlite';
    await AppBrickRepository.configure(
      sqlitePath: sqlitePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
    );
    final repository = AppBrickRepository.instance;
    BrickAnimalStore.configure(repository);
    BrickAnimalObservationStore.configure(repository);
    final store = BrickAnimalStore.instance;
    final notes = BrickAnimalObservationStore.instance;
    final date = DateTime.utc(2026, 10, 5);
    final undoDate = date.add(const Duration(milliseconds: 1));
    final restored = BrickAnimalModel(
      localId: 'animal-id',
      rfidTagNumber: '123',
      visualTag: '123',
      sex: BrickAnimalSex.female,
      breed: 'Angus',
      birthDate: date,
      categoryId: 'cow',
      lotId: '',
      establishmentId: 'establishment-id',
      initialWeight: null,
      weighingMethod: BrickAnimalWeighingMethod.manual,
      weighingDate: date,
      createdAt: date,
      updatedAt: undoDate,
    );
    await store.cacheAnimal(restored);
    await store.applyAnimalSyncResult(
      BackendSyncResult(
        resourcePath: '/api/v1/animales/animal-id',
        localId: 'animal-id',
        updatedAt: date,
        synchronized: false,
        errorCode: 'stale-death-error',
      ),
    );
    expect((await store.getAnimalById('animal-id'))!.syncStatus, BrickAnimalSyncStatus.pending);
    await store.applyAnimalSyncResult(
      BackendSyncResult(
        resourcePath: '/api/v1/animales/animal-id',
        localId: 'animal-id',
        updatedAt: undoDate,
        synchronized: true,
      ),
    );
    final confirmed = (await store.getAnimalById('animal-id'))!;
    expect(confirmed.status, 'activo');
    expect(confirmed.syncStatus, BrickAnimalSyncStatus.synchronized);
    await repository.upsertLocal<BrickAnimalObservationModel>(
      BrickAnimalObservationModel(
        localId: 'note-id',
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
        text: 'Control',
        date: date,
        createdAt: date,
        updatedAt: date,
      ),
    );
    final persistedNotes = await notes.getLocalObservations('establishment-id', 'animal-id');
    expect(persistedNotes.single.text, 'Control');
    expect(await notes.getLocalObservations('other-establishment', 'animal-id'), isEmpty);
    expect(await repository.sqliteProvider.get<BrickAnimalModel>(repository: repository), hasLength(1));
    await store.dispose();
    await notes.dispose();
    await databaseFactoryFfi.deleteDatabase(sqlitePath);
    await databaseFactoryFfi.deleteDatabase(queuePath);
    await directory.delete(recursive: true);
  });
}
