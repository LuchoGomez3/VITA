import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_operating_balance_card.dart';

void main() {
  testWidgets('muestra ingresos, gastos y balance operativo reales', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOperatingBalanceCard(
            dashboard: _dashboard,
            onRegisterExpense: () {},
            onRegisterSale: () {},
            onViewMovements: () {},
          ),
        ),
      ),
    );

    expect(find.text(HomeStrings.salesIncome), findsOneWidget);
    expect(find.text(r'$ 2.500,45'), findsOneWidget);
    expect(find.text(r'- $ 1.230,45'), findsOneWidget);
    expect(find.text(r'$ 1.270,00'), findsOneWidget);
  });

  testWidgets('delega las acciones mediante callbacks', (tester) async {
    var expenseRequests = 0;
    var saleRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOperatingBalanceCard(
            dashboard: _dashboard,
            onRegisterExpense: () => expenseRequests++,
            onRegisterSale: () => saleRequests++,
            onViewMovements: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text(HomeStrings.registerExpense));
    await tester.tap(find.text(HomeStrings.registerSale));

    expect(expenseRequests, 1);
    expect(saleRequests, 1);
  });

  testWidgets('muestra venta primero y conserva completas las etiquetas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOperatingBalanceCard(
            dashboard: _dashboard,
            onRegisterExpense: () {},
            onRegisterSale: () {},
            onViewMovements: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.text(HomeStrings.registerSale)).dx,
      lessThan(tester.getCenter(find.text(HomeStrings.registerExpense)).dx),
    );
    expect(find.text(HomeStrings.movements), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _dashboard = HomeDashboard(
  activeAnimals: 0,
  monthlyAdditions: 0,
  monthlyRemovals: 0,
  knownLiveWeightKg: 0,
  animalsWithCurrentWeight: 0,
  animalsWithDailyGain: 0,
  categories: [],
  lots: [],
  operatingExpensesCents: 123045,
  salesIncomeCents: 250045,
);
