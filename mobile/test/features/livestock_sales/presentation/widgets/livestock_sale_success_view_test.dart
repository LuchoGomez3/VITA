import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/widgets/livestock_sale_success_view.dart';

void main() {
  testWidgets('muestra solo confirmacion y cantidad de animales', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        sale: _sale,
        onRegisterAnotherSale: () {},
        onBackHome: () {},
      ),
    );

    expect(find.text(LivestockSaleStrings.successTitle), findsOneWidget);
    expect(
      find.text(LivestockSaleStrings.soldAnimalCount(4)),
      findsOneWidget,
    );
    expect(
      find.text(LivestockSaleStrings.successOfflineMessage),
      findsOneWidget,
    );

    // La pantalla final no repite informacion economica ni del comprador.
    expect(find.text('Juan Pérez'), findsNothing);
    expect(find.text(r'$ 10.000,00'), findsNothing);
  });

  testWidgets('expone las acciones para reiniciar o volver al inicio', (
    tester,
  ) async {
    var registerAnotherCalls = 0;
    var backHomeCalls = 0;
    await tester.pumpWidget(
      _TestApp(
        sale: _sale,
        onRegisterAnotherSale: () => registerAnotherCalls++,
        onBackHome: () => backHomeCalls++,
      ),
    );

    await tester.tap(
      find.byKey(const Key('livestockSaleRegisterAnotherButton')),
    );
    await tester.tap(find.byKey(const Key('livestockSaleBackHomeButton')));

    expect(registerAnotherCalls, 1);
    expect(backHomeCalls, 1);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.sale,
    required this.onRegisterAnotherSale,
    required this.onBackHome,
  });

  final LivestockSale sale;
  final VoidCallback onRegisterAnotherSale;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: LivestockSaleSuccessView(
          sale: sale,
          onRegisterAnotherSale: onRegisterAnotherSale,
          onBackHome: onBackHome,
        ),
      ),
    );
  }
}

final _sale = LivestockSale(
  id: 'sale-id',
  establishmentId: 'establishment-id',
  operationDate: DateTime(2026, 8, 24),
  buyerType: LivestockSaleBuyerType.privateBuyer,
  buyerName: 'Juan',
  isCompany: false,
  buyerLastName: 'Pérez',
  dteNumber: '001234567-9',
  saleType: LivestockSaleType.bulk,
  totalAmountCents: 1000000,
  animalIds: const ['animal-1', 'animal-2', 'animal-3', 'animal-4'],
  paymentCondition: LivestockSalePaymentCondition.total,
  createdAt: DateTime.utc(2026, 8, 24),
  updatedAt: DateTime.utc(2026, 8, 24),
  syncStatus: LivestockSaleSyncStatus.pending,
);
