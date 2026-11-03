import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/pesaje.model.dart';
import 'package:frontend_mayoral/brick/stores/pesaje_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/weighing/data/repositories/weighing_repository_impl.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';

void main() {
  final weighing = AnimalWeighing(
    id: 'pesaje-1',
    establishmentId: 'campo-1',
    animalId: 'animal-1',
    weightKg: 371.5,
    date: DateTime.utc(2026, 10, 14, 13),
    source: AnimalWeighingSource.manual,
  );

  test('stores the weighing in Brick, pending sync, with the same id', () async {
    final store = _FakePesajeStore();

    final result = await WeighingRepositoryImpl(pesajeStore: store).save(weighing);

    expect(result, isA<Success<AnimalWeighing>>());
    final stored = store.upserted.single;
    expect(stored.localId, 'pesaje-1');
    expect(stored.establishmentId, 'campo-1');
    expect(stored.animalId, 'animal-1');
    expect(stored.weightKg, 371.5);
    expect(stored.date, DateTime.utc(2026, 10, 14, 13));
    expect(stored.method, BrickPesajeMethod.manual);
    expect(stored.syncStatus, BrickPesajeSyncStatus.pending);
  });

  test('returns a readable failure when the local store fails', () async {
    final result = await WeighingRepositoryImpl(pesajeStore: _FakePesajeStore(fail: true)).save(weighing);

    expect(
      result,
      isA<Failure<AnimalWeighing>>().having((f) => f.error.message, 'message', contains('No se pudo guardar')),
    );
  });
}

class _FakePesajeStore implements PesajeBrickStore {
  _FakePesajeStore({this.fail = false});

  final bool fail;
  final upserted = <BrickPesajeModel>[];

  @override
  Future<BrickPesajeModel> upsertPesaje(BrickPesajeModel pesaje) async {
    if (fail) {
      throw StateError('SQLite no disponible');
    }
    upserted.add(pesaje);
    return pesaje;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
