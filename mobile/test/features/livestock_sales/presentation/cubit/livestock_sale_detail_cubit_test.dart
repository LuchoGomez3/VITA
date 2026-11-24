import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_detail_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_animals_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_detail_cubit.dart';

void main() {
  test('consulta el UUID dentro del establecimiento activo', () async {
    final repository = _Repository();
    final animalRepository = _AnimalRepository();
    final cubit = LivestockSaleDetailCubit(
      establishmentId: 'establishment-id',
      saleId: 'sale-id',
      getDetail: GetLivestockSaleDetailUseCase(repository),
      getAnimals: GetLivestockSaleDetailAnimalsUseCase(animalRepository),
    );
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });

    await cubit.load();

    expect(repository.requestedEstablishmentId, 'establishment-id');
    expect(repository.requestedSaleId, 'sale-id');
    expect(animalRepository.requestedIds, ['animal-id']);
    final detail = (cubit.state as Data<LivestockSaleDetailData>).data;
    expect(detail.sale, _sale);
    expect(detail.animals, [_animal]);
  });

  test('relee la venta cuando Brick informa una reconciliacion', () async {
    final repository = _Repository();
    final cubit = LivestockSaleDetailCubit(
      establishmentId: 'establishment-id',
      saleId: 'sale-id',
      getDetail: GetLivestockSaleDetailUseCase(repository),
      getAnimals: GetLivestockSaleDetailAnimalsUseCase(_AnimalRepository()),
    );
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await cubit.load();

    repository.sale = _sale.copyWith(
      syncStatus: LivestockSaleSyncStatus.synchronized,
    );
    repository.notifyChanges();
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final detail = (cubit.state as Data<LivestockSaleDetailData>).data;
    expect(detail.sale.syncStatus, LivestockSaleSyncStatus.synchronized);
  });
}

class _AnimalRepository implements LivestockSaleDetailAnimalRepository {
  List<String>? requestedIds;

  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByIds(
    List<String> animalIds,
  ) async {
    requestedIds = animalIds;
    return Result.success([_animal]);
  }
}

class _Repository implements LivestockSaleHistoryRepository {
  String? requestedEstablishmentId;
  String? requestedSaleId;
  final _changes = StreamController<void>.broadcast();
  LivestockSale sale = _sale;

  @override
  Stream<void> get changes => _changes.stream;

  void notifyChanges() => _changes.add(null);

  Future<void> close() => _changes.close();

  @override
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  }) async {
    requestedEstablishmentId = establishmentId;
    requestedSaleId = saleId;
    return Result.success(sale);
  }

  @override
  Future<Result<List<LivestockSale>>> getSales(String establishmentId) {
    throw StateError('Unexpected history request');
  }
}

final _sale = LivestockSale(
  id: 'sale-id',
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 11, 24),
  buyerType: LivestockSaleBuyerType.privateBuyer,
  buyerName: 'Juan',
  buyerLastName: 'Perez',
  isCompany: false,
  dteNumber: '001234567-9',
  saleType: LivestockSaleType.bulk,
  totalAmountCents: 12500000,
  animalIds: const ['animal-id'],
  paymentCondition: LivestockSalePaymentCondition.pending,
  createdAt: DateTime.utc(2026, 11, 24),
  updatedAt: DateTime.utc(2026, 11, 24),
  syncStatus: LivestockSaleSyncStatus.pending,
);

const _animal = LivestockSaleAnimal(
  id: 'animal-id',
  establishmentId: 'establishment-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  categoryName: 'Novillo',
  lotName: 'Lote Norte',
  status: LivestockSaleAnimalStatus.sold,
);
