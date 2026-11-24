import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/constants/financial_movement_strings.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_history_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_history_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/cubit/livestock_sale_history_cubit.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/pages/livestock_sale_history_page.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_history_strings.dart';

void main() {
  testWidgets('muestra el resumen y los datos de una venta local', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestApp(onExpensesSelected: () {}));
    await tester.pumpAndSettle();

    expect(find.text('Campo Sur'), findsOneWidget);
    expect(find.text(r'$ 125.000,00'), findsNWidgets(3));
    expect(find.text('Juan Perez'), findsOneWidget);
    expect(find.text(LivestockSaleHistoryStrings.paymentPending), findsOneWidget);
    expect(find.text(LivestockSaleHistoryStrings.syncPending), findsOneWidget);
  });

  testWidgets('permite volver a la seccion de egresos', (tester) async {
    var requests = 0;
    await tester.pumpWidget(
      _TestApp(onExpensesSelected: () => requests++),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(FinancialMovementStrings.expenses));

    expect(requests, 1);
  });

  testWidgets('abre el detalle al tocar toda la tarjeta', (tester) async {
    String? selectedSaleId;
    await tester.pumpWidget(
      _TestApp(
        onExpensesSelected: () {},
        onSaleSelected: (saleId) => selectedSaleId = saleId,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Juan Perez'));

    expect(selectedSaleId, 'sale-id');
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('filtra por comprador y permite limpiar el resultado', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestApp(onExpensesSelected: () {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text(LivestockSaleHistoryStrings.filters));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        LivestockSaleHistoryStrings.buyerSearchHint,
      ),
      'Comprador inexistente',
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(LivestockSaleHistoryStrings.filteredEmpty),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text(LivestockSaleHistoryStrings.filteredEmpty),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.text(LivestockSaleHistoryStrings.clearFilters),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(LivestockSaleHistoryStrings.clearFilters));
    await tester.pump();

    expect(find.text('Juan Perez'), findsOneWidget);
  });

  testWidgets('compacta el encabezado al desplazar el historial', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_TestApp(onExpensesSelected: () {}));
    await tester.pumpAndSettle();

    final compactSummary = find.byKey(
      const ValueKey('compact-sales-summary'),
    );
    expect(
      tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: compactSummary,
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      0,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: compactSummary,
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      1,
    );
    expect(
      find.text(FinancialMovementStrings.expenses).hitTestable(),
      findsNothing,
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.onExpensesSelected,
    this.onSaleSelected,
  });

  final VoidCallback onExpensesSelected;
  final ValueChanged<String>? onSaleSelected;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: LivestockSaleHistoryPage(
        establishmentName: 'Campo Sur',
        onExpensesSelected: onExpensesSelected,
        onSaleSelected: onSaleSelected ?? (_) {},
        createCubit: () => LivestockSaleHistoryCubit(
          establishmentId: 'establishment-id',
          getHistory: GetLivestockSaleHistoryUseCase(_Repository()),
        ),
      ),
    );
  }
}

class _Repository implements LivestockSaleHistoryRepository {
  @override
  Future<Result<List<LivestockSale>>> getSales(
    String establishmentId,
  ) async {
    return Result.success([_sale]);
  }

  @override
  Future<Result<LivestockSale>> getSale({
    required String establishmentId,
    required String saleId,
  }) async {
    return Result.success(_sale);
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
