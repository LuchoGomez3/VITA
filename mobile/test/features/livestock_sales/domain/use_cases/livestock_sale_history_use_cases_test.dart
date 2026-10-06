import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/livestock_sale_history_use_cases.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';

void main() {
  late _Repository repository;
  late CollectUnpaidLivestockSaleUseCase collect;
  final now = DateTime(2026, 10, 6, 15, 30);

  setUp(() {
    repository = _Repository();
    collect = CollectUnpaidLivestockSaleUseCase(repository, now: () => now, createId: () => 'payment-id');
  });

  test('confirmar el total conserva la venta y genera un cobro con auditoría', () async {
    final sale = _sale();
    final result = await collect(sale: sale, amountCents: 10000, method: LivestockSalePaymentMethod.bankTransfer);

    final saved = result.when(success: (value) => value, failure: (error) => throw error);
    expect(saved.paymentCondition, LivestockSalePaymentCondition.total);
    expect(saved.totalAmountCents, sale.totalAmountCents);
    expect(saved.id, sale.id);
    expect(saved.animalIds, sale.animalIds);
    expect(saved.initialPayment?.amountCents, 10000);
    expect(saved.initialPayment?.method, LivestockSalePaymentMethod.bankTransfer);
    expect(saved.initialPayment?.id, 'payment-id');
    expect(saved.updatedAt, now.toUtc());
  });

  test('rechaza importes inválidos sin escribir en el repositorio', () async {
    for (final amount in [0, -1, 10001]) {
      final result = await collect(sale: _sale(), amountCents: amount, method: LivestockSalePaymentMethod.cash);
      expect(result, isA<Failure<LivestockSale>>());
    }
    expect(repository.writes, 0);
  });

  test('no reemplaza un cobro existente', () async {
    await collect(sale: _sale(), amountCents: 10000, method: LivestockSalePaymentMethod.cash);
    final result = await collect(
      sale: repository.sales.single,
      amountCents: 10000,
      method: LivestockSalePaymentMethod.card,
    );
    expect(result, isA<Failure<LivestockSale>>());
    expect(repository.writes, 1);
  });

  test('el Cubit refresca el listado con el cobro persistido', () async {
    final cubit = LivestockSaleHistoryCubit(
      establishmentId: 'establishment-id',
      getHistory: GetLivestockSaleHistoryUseCase(repository),
      collectSale: collect,
    );
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.collect(_sale(), LivestockSalePaymentMethod.cash);
    final sales = await GetLivestockSaleHistoryUseCase(repository)('establishment-id');
    expect(repository.requestedEstablishment, 'establishment-id');
    expect(
      sales.when(success: (data) => data.single.paymentCondition, failure: (error) => throw error),
      LivestockSalePaymentCondition.total,
    );
    expect(repository.writes, 1);
  });

  test('el Cubit permite reintentar después de un error de cobro', () async {
    final cubit = LivestockSaleHistoryCubit(
      establishmentId: 'establishment-id',
      getHistory: GetLivestockSaleHistoryUseCase(repository),
      collectSale: collect,
    );
    addTearDown(cubit.close);
    repository.failPayment = true;
    await cubit.collect(_sale(), LivestockSalePaymentMethod.cash);
    repository.failPayment = false;
    await cubit.collect(_sale(), LivestockSalePaymentMethod.cash);
    expect(repository.writes, 1);
  });
}

/// Repositorio en memoria para probar validación y actualización del listado.
class _Repository implements LivestockSaleHistoryRepository {
  List<LivestockSale> sales = [_sale()];
  int writes = 0;
  String? requestedEstablishment;
  bool failPayment = false;

  @override
  Future<Result<List<LivestockSale>>> getSales(String establishmentId) async {
    requestedEstablishment = establishmentId;
    return Result.success(sales);
  }

  @override
  Future<Result<LivestockSale>> collectUnpaidSale(LivestockSale sale) async {
    if (failPayment) return const Result.failure(DomainException(message: 'Database unavailable'));
    writes++;
    sales = [sale];
    return Result.success(sale);
  }
}

LivestockSale _sale() => LivestockSale(
  id: 'sale-id',
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 10, 5),
  buyerType: LivestockSaleBuyerType.privateBuyer,
  buyerName: 'Juan',
  buyerLastName: 'Pérez',
  isCompany: false,
  dteNumber: '123-4',
  saleType: LivestockSaleType.bulk,
  totalAmountCents: 10000,
  animalIds: ['animal-id'],
  paymentCondition: LivestockSalePaymentCondition.pending,
  createdAt: DateTime.utc(2026, 10, 5),
  updatedAt: DateTime.utc(2026, 10, 5),
  syncStatus: LivestockSaleSyncStatus.pending,
);
