import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_history.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_history_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';

void main() {
  late _Repository repository;
  late LivestockSaleHistoryCubit cubit;

  setUp(() {
    repository = _Repository();
    cubit = LivestockSaleHistoryCubit(
      establishmentId: 'establishment-id',
      getHistory: GetLivestockSaleHistoryUseCase(repository),
      now: () => DateTime(2026, 11, 24),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.close();
  });

  test('carga y ordena las ventas desde la mas reciente', () async {
    await cubit.load();

    expect(repository.requestedEstablishmentId, 'establishment-id');
    final visible = (cubit.state.history as Data<List<LivestockSale>>).data;
    expect(visible.map((sale) => sale.id), ['recent-partial', 'recent-total', 'old']);
  });

  test('combina fecha, tipo, comprador y estado de cobro', () async {
    await cubit.load();

    cubit
      ..selectCustomRange(DateTime(2026, 11), DateTime(2026, 11, 30))
      ..selectType(LivestockSaleType.perKilogram)
      ..searchBuyer('ana frigorifico')
      ..selectPaymentCondition(LivestockSalePaymentCondition.partial);

    final visible = (cubit.state.history as Data<List<LivestockSale>>).data;
    expect(visible.map((sale) => sale.id), ['recent-partial']);
    expect(cubit.state.filters.hasActiveFilters, isTrue);
  });

  test('limpiar filtros restaura todo el historial ordenado', () async {
    await cubit.load();
    cubit
      ..selectPeriod(LivestockSaleHistoryPeriod.currentMonth)
      ..searchBuyer('sin coincidencias');

    expect(
      (cubit.state.history as Data<List<LivestockSale>>).data,
      isEmpty,
    );

    cubit.clearFilters();

    final visible = (cubit.state.history as Data<List<LivestockSale>>).data;
    expect(visible.map((sale) => sale.id), ['recent-partial', 'recent-total', 'old']);
    expect(cubit.state.filters.hasActiveFilters, isFalse);
  });

  test('actualiza el listado cuando Brick modifica una venta local', () async {
    await cubit.load();
    repository.sales = [
      _sale(
        id: 'recent-partial',
        date: DateTime(2026, 11, 22),
        buyerName: 'Ana',
        buyerLastName: 'Frigorifico',
        type: LivestockSaleType.perKilogram,
        payment: LivestockSalePaymentCondition.partial,
      ).copyWith(syncStatus: LivestockSaleSyncStatus.synchronized),
    ];

    repository.notifyChanges();
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final visible = (cubit.state.history as Data<List<LivestockSale>>).data;
    expect(visible, hasLength(1));
    expect(visible.single.syncStatus, LivestockSaleSyncStatus.synchronized);
  });
}

class _Repository implements LivestockSaleHistoryRepository {
  String? requestedEstablishmentId;
  final _changes = StreamController<void>.broadcast();
  List<LivestockSale>? sales;

  @override
  Stream<void> get changes => _changes.stream;

  void notifyChanges() => _changes.add(null);

  Future<void> close() => _changes.close();

  @override
  Future<Result<List<LivestockSale>>> getSales(
    String establishmentId,
  ) async {
    requestedEstablishmentId = establishmentId;
    return Result.success(
      sales ??
          [
            _sale(
              id: 'old',
              date: DateTime(2026, 8, 10),
              buyerName: 'Juan',
              buyerLastName: 'Perez',
              type: LivestockSaleType.bulk,
              payment: LivestockSalePaymentCondition.pending,
            ),
            _sale(
              id: 'recent-total',
              date: DateTime(2026, 11, 20),
              buyerName: 'Campo Norte',
              type: LivestockSaleType.bulk,
              payment: LivestockSalePaymentCondition.total,
            ),
            _sale(
              id: 'recent-partial',
              date: DateTime(2026, 11, 22),
              buyerName: 'Ana',
              buyerLastName: 'Frigorifico',
              type: LivestockSaleType.perKilogram,
              payment: LivestockSalePaymentCondition.partial,
            ),
          ],
    );
  }

  @override
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  }) async {
    final sales = (await getSales(establishmentId) as Success<List<LivestockSale>>).data;
    return Result.success(sales.firstWhere((sale) => sale.id == saleId));
  }
}

LivestockSale _sale({
  required String id,
  required DateTime date,
  required String buyerName,
  required LivestockSaleType type,
  required LivestockSalePaymentCondition payment,
  String? buyerLastName,
}) {
  return LivestockSale(
    id: id,
    establishmentId: 'establishment-id',
    operationDate: date,
    buyerType: LivestockSaleBuyerType.privateBuyer,
    buyerName: buyerName,
    buyerLastName: buyerLastName,
    isCompany: buyerLastName == null,
    dteNumber: '001234567-9',
    saleType: type,
    totalAmountCents: 12500000,
    animalIds: const ['animal-id'],
    paymentCondition: payment,
    createdAt: date.toUtc(),
    updatedAt: date.toUtc(),
    syncStatus: LivestockSaleSyncStatus.pending,
  );
}
