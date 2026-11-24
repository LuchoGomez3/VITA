import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/brick/core/repository.dart';
import 'package:frontend_mayoral/brick/stores/animal_observation_brick_store.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_observations_repository.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/animal_observations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('guarda una nota sin conexión y la devuelve solo para su animal y establecimiento', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('vita-observations-');
    final databasePath = path.join(directory.path, 'brick.sqlite');
    final queuePath = path.join(directory.path, 'queue.sqlite');
    addTearDown(() async {
      await databaseFactoryFfi.deleteDatabase(databasePath);
      await databaseFactoryFfi.deleteDatabase(queuePath);
      await directory.delete(recursive: true);
    });
    await AppBrickRepository.configure(
      sqlitePath: databasePath,
      offlineQueuePath: queuePath,
      localDatabaseFactory: databaseFactoryFfi,
      tokenProvider: const _TestTokenProvider(),
      client: MockClient((_) async => http.Response('offline', 503)),
    );
    final repository = AppBrickRepository.instance;
    BrickAnimalObservationStore.configure(repository);
    final store = BrickAnimalObservationStore.instance;
    addTearDown(store.dispose);
    final actions = AnimalObservations(AnimalObservationsRepository(store, repository.localChanges));
    final events = StreamIterator(actions.watch('field-a', 'animal-a'));
    addTearDown(events.cancel);

    expect(await events.moveNext(), isTrue);
    expect(events.current, isEmpty);
    final next = events.moveNext();
    await actions.add('field-a', 'animal-a', ' Nota local ');
    expect(await next, isTrue);
    expect(events.current.single.text, 'Nota local');
    expect(events.current.single.status, AnimalSyncStatus.pending);
    expect(await store.getLocalObservations('field-b', 'animal-a'), isEmpty);
    expect(await store.getLocalObservations('field-a', 'animal-b'), isEmpty);
  });
}

class _TestTokenProvider implements BackendAccessTokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getAccessToken() async => 'test-token';
}
