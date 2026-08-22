import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_operating_balance_card.dart';

void main() {
  testWidgets('muestra gastos reales sin inventar un balance ni valor de stock', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOperatingBalanceCard(
            dashboard: _dashboard,
            onRegisterExpense: () {},
            onRegisterIncome: () {},
            onViewMovements: () {},
          ),
        ),
      ),
    );

    expect(find.text(HomeStrings.noData), findsNWidgets(2));
    expect(find.text(r'- $ 1.230,45'), findsOneWidget);
  });

  testWidgets('delega las acciones mediante callbacks', (tester) async {
    var expenseRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOperatingBalanceCard(
            dashboard: _dashboard,
            onRegisterExpense: () => expenseRequests++,
            onRegisterIncome: () {},
            onViewMovements: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text(HomeStrings.registerExpense));

    expect(expenseRequests, 1);
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
);
