import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_detail_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_animals_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_detail_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/pages/livestock_sale_detail_page.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_detail_strings.dart';

void main() {
  testWidgets('muestra una venta por kilo en modo solo lectura', (tester) async {
    var backRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LivestockSaleDetailPage(
          createCubit: () => LivestockSaleDetailCubit(
            establishmentId: 'establishment-id',
            saleId: 'sale-id',
            getDetail: GetLivestockSaleDetailUseCase(_Repository()),
            getAnimals: GetLivestockSaleDetailAnimalsUseCase(
              _AnimalRepository(),
            ),
          ),
          onBackPressed: () => backRequests++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(LivestockSaleDetailStrings.title), findsOneWidget);
    expect(find.text('Frigorífico Norte'), findsOneWidget);
    expect(find.text('1.610 kg'), findsOneWidget);
    expect(find.text(r'$ 1.000/kg'), findsOneWidget);
    expect(find.text(r'$ 1.610.000,00'), findsOneWidget);
    expect(find.text(LivestockSaleDetailStrings.registeredAt), findsOneWidget);
    expect(find.text('Franco Productor'), findsOneWidget);
    expect(
      find.text(LivestockSaleDetailStrings.informationalAmountsNotice),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNothing);

    await tester.scrollUntilVisible(
      find.textContaining('982000412991416'),
      300,
    );
    expect(find.text('Novillo'), findsOneWidget);
    expect(find.text('Lote Norte'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(backRequests, 1);
  });
}

class _AnimalRepository implements LivestockSaleDetailAnimalRepository {
  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByIds(
    List<String> animalIds,
  ) async {
    return const Result.success([
      LivestockSaleAnimal(
        id: 'animal-id',
        establishmentId: 'establishment-id',
        rfidTagNumber: '982000412991416',
        visualTag: '003 1295',
        categoryName: 'Novillo',
        lotName: 'Lote Norte',
        status: LivestockSaleAnimalStatus.sold,
      ),
    ]);
  }
}

class _Repository implements LivestockSaleHistoryRepository {
  @override
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  }) async => Result.success(_sale);

  @override
  Future<Result<List<LivestockSale>>> getSales(String establishmentId) {
    throw StateError('Unexpected history request');
  }
}

final _sale = LivestockSale(
  id: 'sale-id',
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 11, 24),
  buyerType: LivestockSaleBuyerType.slaughterhouse,
  buyerName: 'Frigorífico Norte',
  isCompany: true,
  dteNumber: '001234567-9',
  saleType: LivestockSaleType.perKilogram,
  totalAmountCents: 161000000,
  totalWeightGrams: 1610000,
  pricePerKgMicros: 1000000000,
  animalIds: const ['animal-id'],
  paymentCondition: LivestockSalePaymentCondition.partial,
  initialPayment: LivestockSaleInitialPayment(
    id: 'payment-id',
    date: DateTime(2026, 11, 24),
    amountCents: 50000000,
    method: LivestockSalePaymentMethod.bankTransfer,
    createdAt: DateTime.utc(2026, 11, 24),
    updatedAt: DateTime.utc(2026, 11, 24),
  ),
  createdAt: DateTime.utc(2026, 11, 24),
  updatedAt: DateTime.utc(2026, 11, 24),
  registeredById: 'user-id',
  registeredByName: 'Franco Productor',
  syncStatus: LivestockSaleSyncStatus.synchronized,
);
