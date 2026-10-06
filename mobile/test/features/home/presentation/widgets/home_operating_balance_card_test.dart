import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_operating_balance_card.dart';

void main() {
  testWidgets('muestra ventas menos gastos como balance operativo', (tester) async {
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

    expect(find.text(r'$ 691.900,00'), findsOneWidget);
    expect(find.text(r'$ 1.200.000,00'), findsOneWidget);
    expect(find.text(HomeStrings.salesRevenue), findsOneWidget);
    expect(find.text(r'- $ 508.100,00'), findsOneWidget);
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
  operatingExpensesCents: 50810000,
  salesRevenueCents: 120000000,
);
