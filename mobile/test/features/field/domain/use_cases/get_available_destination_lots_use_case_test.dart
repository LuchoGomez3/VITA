import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';
import 'package:frontend_mayoral/features/field/domain/repositories/lot_repository.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/get_available_destination_lots_use_case.dart';

void main() {
  test('devuelve solamente otros lotes activos del establecimiento', () async {
    final repository = _LotRepository([
      _lot('source', LotStatus.active),
      _lot('active', LotStatus.active),
      _lot('inactive', LotStatus.inactive),
    ]);
    final useCase = GetAvailableDestinationLotsUseCase(repository);

    final result = await useCase(
      establishmentId: 'est-1',
      sourceLotId: 'source',
    );

    expect(result, isA<Success<List<Lot>>>());
    expect((result as Success<List<Lot>>).data.map((lot) => lot.id), [
      'active',
    ]);
  });
}

Lot _lot(String id, LotStatus status) => Lot(
  id: id,
  establishmentId: 'est-1',
  name: id,
  boundary: const LotBoundary(),
  surfaceTenths: 10,
  hasWater: true,
  status: status,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _LotRepository implements LotRepository {
  _LotRepository(this.lots);

  final List<Lot> lots;

  @override
  Future<Result<Lot>> getLot(String lotId) async => Result.success(lots.singleWhere((lot) => lot.id == lotId));

  @override
  Future<Result<List<Lot>>> getLots(String establishmentId) async => Result.success(
    lots.where((lot) => lot.establishmentId == establishmentId).toList(growable: false),
  );

  @override
  Future<Result<Lot>> saveLot(Lot lot) async => Result.success(lot);
}
