import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';

void main() {
  late _Repository repository;
  late ConfirmLivestockSaleUseCase useCase;

  setUp(() {
    repository = _Repository();
    final ids = ['sale-id', 'payment-id'].iterator;
    useCase = ConfirmLivestockSaleUseCase(
      repository: repository,
      now: () => DateTime(2026, 10, 3, 15, 30),
      createId: () {
        ids.moveNext();
        return ids.current;
      },
    );
  });

  test('crea una venta por kilo parcial con identidades offline', () async {
    final result = await useCase(_perKilogramDraft());

    final sale = result.when(
      success: (value) => value,
      failure: (error) => throw error,
    );
    expect(sale.id, 'sale-id');
    expect(sale.initialPayment?.id, 'payment-id');
    expect(sale.pricePerKgMicros, 1000123456);
    expect(sale.totalAmountCents, 1012624);
    expect(sale.syncStatus, LivestockSaleSyncStatus.pending);
    expect(repository.created, same(sale));
  });

  test('rechaza un total que no coincide con peso por precio', () async {
    final result = await useCase(
      _perKilogramDraft().copyWith(totalAmountCents: 1012625),
    );

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.inconsistentCalculatedTotal,
    );
    expect(repository.created, isNull);
  });

  test('una venta al bulto no admite peso ni precio por kilo', () async {
    final result = await useCase(
      _bulkDraft().copyWith(totalWeightGrams: 1000),
    );

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.bulkWithUnitValues,
    );
  });

  test('el cobro total debe coincidir con el monto de venta', () async {
    final result = await useCase(
      _bulkDraft().copyWith(
        paymentCondition: LivestockSalePaymentCondition.total,
        initialPayment: LivestockSaleInitialPaymentDraft(
          date: DateTime(2026, 10, 3),
          amountCents: 999999,
          method: LivestockSalePaymentMethod.cash,
        ),
      ),
    );

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.invalidInitialPaymentAmount,
    );
  });

  test('una venta pendiente no admite cobro inicial', () async {
    final result = await useCase(
      _bulkDraft().copyWith(
        initialPayment: LivestockSaleInitialPaymentDraft(
          date: DateTime(2026, 10, 3),
          amountCents: 100,
          method: LivestockSalePaymentMethod.card,
        ),
      ),
    );

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.pendingWithInitialPayment,
    );
  });

  test('empresa usa razon social y no admite apellido', () async {
    final result = await useCase(
      _bulkDraft().copyWith(
        buyerName: 'Frigorifico de Prueba SA',
        isCompany: true,
        buyerLastName: 'Perez',
      ),
    );

    expect(
      result.when(success: (_) => null, failure: (error) => error.reason),
      LivestockSaleError.companyWithLastName,
    );
  });
}

LivestockSaleDraft _perKilogramDraft() => LivestockSaleDraft(
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 10, 3),
  buyerType: LivestockSaleBuyerType.slaughterhouse,
  buyerName: 'Juan',
  buyerLastName: 'Perez',
  isCompany: false,
  dteNumber: '00123456789',
  saleType: LivestockSaleType.perKilogram,
  totalWeightGrams: 10125,
  pricePerKgMicros: 1000123456,
  totalAmountCents: 1012624,
  animalIds: const ['animal-a', 'animal-b'],
  paymentCondition: LivestockSalePaymentCondition.partial,
  initialPayment: LivestockSaleInitialPaymentDraft(
    date: DateTime(2026, 10, 3),
    amountCents: 500000,
    method: LivestockSalePaymentMethod.bankTransfer,
  ),
);

LivestockSaleDraft _bulkDraft() => LivestockSaleDraft(
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
);

class _Repository implements LivestockSaleRepository {
  LivestockSale? created;

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    created = sale;
    return Result.success(sale);
  }
}
