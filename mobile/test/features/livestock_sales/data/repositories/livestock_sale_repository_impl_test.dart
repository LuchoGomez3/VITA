import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/livestock_sale.model.dart';
import 'package:frontend_mayoral/brick/stores/livestock_sale_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/data/repositories/livestock_sale_repository_impl.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';

void main() {
  test('persiste mediante el store y devuelve la venta de dominio', () async {
    final store = _Store();
    final repository = LivestockSaleRepositoryImpl(saleStore: store);
    final sale = _sale();

    final result = await repository.createSale(sale);

    expect(store.saved?.localId, sale.id);
    expect(
      result.when(success: (saved) => saved, failure: (error) => throw error),
      sale,
    );
  });

  test('traduce un animal inactivo a conflicto de dominio', () async {
    final repository = LivestockSaleRepositoryImpl(
      saleStore: _Store(
        error: const LivestockSaleLocalException(
          LivestockSaleLocalErrorCode.animalNotActive,
          animalId: 'animal-a',
        ),
      ),
    );

    final result = await repository.createSale(_sale());

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.animalNotActive,
    );
  });
}

LivestockSale _sale() {
  final timestamp = DateTime.utc(2026, 10, 3, 18, 30);
  return LivestockSale(
    id: 'sale-id',
    establishmentId: 'establishment-id',
    operationDate: DateTime(2026, 10, 3),
    buyerType: LivestockSaleBuyerType.privateBuyer,
    buyerName: 'Juan',
    buyerLastName: 'Perez',
    isCompany: false,
    dteNumber: '00123456789',
    saleType: LivestockSaleType.bulk,
    totalAmountCents: 1000000,
    animalIds: const ['animal-a'],
    paymentCondition: LivestockSalePaymentCondition.pending,
    createdAt: timestamp,
    updatedAt: timestamp,
    syncStatus: LivestockSaleSyncStatus.pending,
  );
}

class _Store implements LivestockSaleBrickStore {
  _Store({this.error});

  final LivestockSaleLocalException? error;
  BrickLivestockSaleModel? saved;

  @override
  Future<BrickLivestockSaleModel> saveSale(BrickLivestockSaleModel sale) async {
    final error = this.error;
    if (error != null) throw error;
    saved = sale;
    return sale;
  }
}
