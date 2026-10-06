import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/livestock_sale_history_use_cases.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/pages/livestock_sale_history_page.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('tocar una venta pendiente confirma el cobro y actualiza la tarjeta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _Repository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LivestockSaleHistoryPage(
            establishmentName: 'La Esperanza',
            onExpensesSelected: () {},
            createCubit: () => LivestockSaleHistoryCubit(
              establishmentId: 'establishment-id',
              getHistory: GetLivestockSaleHistoryUseCase(repository),
              collectSale: CollectUnpaidLivestockSaleUseCase(repository),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text(LivestockSaleHistoryStrings.pending), findsOneWidget);
    expect(find.text(LivestockSaleHistoryStrings.recordCount(1)), findsOneWidget);
    expect(find.text(r'$ 100,00'), findsNWidgets(2));

    // Cancelar la confirmación mantiene intacto el cobro pendiente.
    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(LivestockSaleHistoryStrings.cancel));
    await tester.pumpAndSettle();
    expect(repository.writes, 0);

    await tester.ensureVisible(find.text(LivestockSaleHistoryStrings.collect));
    await tester.pumpAndSettle();
    await tester.tap(find.text(LivestockSaleHistoryStrings.collect));
    await tester.pumpAndSettle();
    await tester.tap(find.text(LivestockSaleHistoryStrings.confirm));
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
    expect(find.text(LivestockSaleHistoryStrings.collected), findsOneWidget);
    expect(find.text(r'Cobrado: $ 100,00'), findsOneWidget);
    expect(find.text(r'Saldo pendiente: $ 0,00'), findsOneWidget);
    expect(find.text(LivestockSaleHistoryStrings.collect), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

/// Mantiene el cobro escrito para verificar el refresco visible del historial.
class _Repository implements LivestockSaleHistoryRepository {
  int writes = 0;
  LivestockSale sale = LivestockSale(
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

  @override
  Future<Result<List<LivestockSale>>> getSales(String establishmentId) async => Result.success([sale]);

  @override
  Future<Result<LivestockSale>> collectUnpaidSale(LivestockSale value) async {
    writes++;
    sale = value;
    return Result.success(value);
  }
}
