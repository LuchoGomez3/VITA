import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/sync/data/mappers/sync_operation_kind_mapper.dart';
import 'package:frontend_mayoral/features/sync/domain/entities/sync_queue.dart';

void main() {
  test('traduce cada recurso sync-able a su tipo de operación', () {
    expect(syncOperationKindFor('/api/v1/pesajes'), SyncOperationKind.weighing);
    expect(syncOperationKindFor('/api/v1/movimientos_lotes'), SyncOperationKind.lotMovement);
    expect(syncOperationKindFor('/api/v1/lotes/abc'), SyncOperationKind.lot);
    expect(syncOperationKindFor('/api/v1/egresos_operativos'), SyncOperationKind.operatingExpense);
    expect(syncOperationKindFor('/api/v1/egresos_operativos/categorias'), SyncOperationKind.operatingExpenseCategory);
    expect(syncOperationKindFor('/api/v1/ventas'), SyncOperationKind.other);
  });

  test('un animal se distingue por método solo cuando se conoce', () {
    expect(syncOperationKindFor('/api/v1/animales', method: 'POST'), SyncOperationKind.animalRegistration);
    expect(syncOperationKindFor('/api/v1/animales/abc', method: 'PUT'), SyncOperationKind.animalUpdate);
    expect(syncOperationKindFor('/api/v1/animales'), SyncOperationKind.animal);
  });
}
