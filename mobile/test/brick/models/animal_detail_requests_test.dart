import 'dart:convert';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/brick.g.dart';
import 'package:frontend_mayoral/brick/models/animal_observation.model.dart';
import 'package:frontend_mayoral/brick/models/animal_update.model.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final date = DateTime.utc(2026, 10, 5);
  late List<Request> requests;
  late RestProvider provider;
  setUp(() {
    requests = [];
    provider = RestProvider(
      'http://localhost:8000',
      modelDictionary: restModelDictionary,
      client: MockClient((request) async {
        requests.add(request);
        return Response('{"success":true,"data":{}}', 200, request: request);
      }),
    );
  });
  test('PUT sends only edit fields and includes explicit null reproduction', () async {
    await provider.upsert<BrickAnimalUpdateModel>(
      BrickAnimalUpdateModel(
        localId: 'animal-id',
        categoryId: 'category-id',
        status: 'muerto',
        reproductiveStatus: null,
        updatedAt: date,
      ),
    );
    final request = requests.single;
    expect(request.method, 'PUT');
    expect(request.url.path, '/api/v1/animales/animal-id');
    expect(jsonDecode(request.body), {
      'id': 'animal-id',
      'categoria_id': 'category-id',
      'estado': 'muerto',
      'estado_reproductivo': null,
      'updated_at': date.toIso8601String(),
    });
  });
  test('POST observations are independent, unwrapped and without client author', () async {
    await provider.upsert<BrickAnimalObservationModel>(
      BrickAnimalObservationModel(
        localId: 'note-id',
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
        text: 'Control veterinario',
        date: date,
        createdAt: date,
        updatedAt: date,
      ),
    );
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/api/v1/observaciones_animales');
    expect(body['texto'], 'Control veterinario');
    expect(body['animal_id'], 'animal-id');
    expect(body.containsKey('data'), isFalse);
    expect(body.containsKey('autor_id'), isFalse);
  });
  test('POST weighing uses the existing manual weighing contract', () async {
    await provider.upsert<BrickPesajeModel>(
      BrickPesajeModel(
        localId: 'weight-id',
        establishmentId: 'establishment-id',
        animalId: 'animal-id',
        weightKg: 350.5,
        date: date,
        createdAt: date,
        updatedAt: date,
      ),
    );
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(requests.single.url.path, '/api/v1/pesajes');
    expect(body['peso_kg'], 350.5);
    expect(body['metodo'], 'manual');
    expect(body.containsKey('data'), isFalse);
  });
  test('SQLite adapters tolerate old rows without the newly added columns', () async {
    final sqlite = SqliteProvider(
      'unused.db',
      modelDictionary: sqliteModelDictionary,
      databaseFactory: databaseFactoryFfi,
    );
    final category = await BrickCategoriaModelAdapter().fromSqlite({
      '_brick_id': 1,
      'local_id': 'category-id',
      'name': 'Vaca',
      'created_at': date.toIso8601String(),
      'updated_at': date.toIso8601String(),
      'sync_status': 1,
    }, provider: sqlite);
    expect(category.allowedSex, 'ambos');
    expect(category.allowsReproductiveStatus, isFalse);
    final animal = await BrickAnimalModelAdapter().fromSqlite({
      '_brick_id': 1,
      'local_id': 'animal-id',
      'rfid_tag_number': '123',
      'visual_tag': '123',
      'sex': 1,
      'breed': 'Angus',
      'birth_date': date.toIso8601String(),
      'category_id': 'category-id',
      'category_name': 'Vaca',
      'lot_id': '',
      'lot_name': '',
      'establishment_id': 'establishment-id',
      'weighing_method': 0,
      'weighing_date': date.toIso8601String(),
      'sync_status': 1,
      'created_at': date.toIso8601String(),
      'updated_at': date.toIso8601String(),
    }, provider: sqlite);
    expect(animal.status, 'activo');
    expect(animal.reproductiveStatus, isNull);
  });
}
