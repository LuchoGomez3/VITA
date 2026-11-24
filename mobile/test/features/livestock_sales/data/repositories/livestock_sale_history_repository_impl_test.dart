import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_history_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';

void main() {
  test('lee el establecimiento solicitado y mapea sus ventas', () async {
    final store = _Store([_brickSale]);
    final repository = LivestockSaleHistoryRepositoryImpl(saleStore: store);

    final result = await repository.getSales('establishment-id');

    expect(store.requestedEstablishmentId, 'establishment-id');
    final sales = (result as Success<List<LivestockSale>>).data;
    expect(sales.single.id, 'sale-id');
    expect(sales.single.totalAmountCents, 12500000);
    expect(sales.single.syncStatus, LivestockSaleSyncStatus.synchronized);
    expect(sales.single.registeredByName, 'Franco Productor');
  });

  test('obtiene una venta local por establecimiento y UUID', () async {
    final repository = LivestockSaleHistoryRepositoryImpl(
      saleStore: _Store([_brickSale]),
    );

    final result = await repository.getSale(
      establishmentId: 'establishment-id',
      saleId: 'sale-id',
    );

    expect((result as Success<LivestockSale>).data.id, 'sale-id');
  });
}

class _Store implements LivestockSaleBrickStore {
  _Store(this.sales);

  final List<BrickLivestockSaleModel> sales;
  String? requestedEstablishmentId;

  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<List<BrickLivestockSaleModel>> getLocalSales(
    String? establishmentId,
  ) async {
    requestedEstablishmentId = establishmentId;
    return sales;
  }

  @override
  Future<void> pullRemoteSales(String establishmentId) async {}

  @override
  Future<void> synchronizeSales(String establishmentId) async {}

  @override
  Future<BrickLivestockSaleModel> saveSale(BrickLivestockSaleModel sale) {
    throw StateError('Unexpected saveSale call');
  }
}

final _brickSale = BrickLivestockSaleModel(
  localId: 'sale-id',
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 11, 24),
  buyerType: 'particular',
  buyerName: 'Juan',
  buyerLastName: 'Perez',
  isCompany: false,
  dteNumber: '001234567-9',
  saleType: 'al_bulto',
  totalAmount: '125000.00',
  animalIdsJson: '["animal-id"]',
  paymentCondition: 'pendiente',
  createdAt: DateTime.utc(2026, 11, 24),
  updatedAt: DateTime.utc(2026, 11, 24),
  registeredById: 'user-id',
  registeredByName: 'Franco Productor',
  syncStatus: BrickLivestockSaleSyncStatus.synchronized,
);
