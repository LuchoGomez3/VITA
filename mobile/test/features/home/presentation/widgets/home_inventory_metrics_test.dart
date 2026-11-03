import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_inventory_metrics.dart';

void main() {
  testWidgets('agrupa altas y bajas del mes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeMonthlyMovementsCard(dashboard: _dashboard)),
      ),
    );

    expect(find.text(HomeStrings.monthlyMovements), findsOneWidget);
    expect(find.text(HomeStrings.monthlyAdditions), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text(HomeStrings.monthlyRemovals), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('explicita la cobertura del peso registrado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeLiveWeightCard(dashboard: _dashboard)),
      ),
    );

    expect(find.text('1250 kg'), findsOneWidget);
    expect(find.text(HomeStrings.weightCoverage(3, 8)), findsOneWidget);
  });

  testWidgets('muestra ausencia de datos cuando ningún animal tiene peso', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeLiveWeightCard(
            dashboard: HomeDashboard(
              activeAnimals: 8,
              monthlyAdditions: 0,
              monthlyRemovals: 0,
              knownLiveWeightKg: 0,
              animalsWithCurrentWeight: 0,
              animalsWithDailyGain: 0,
              categories: [],
              lots: [],
            ),
          ),
        ),
      ),
    );

    expect(find.text(HomeStrings.noData), findsOneWidget);
    expect(find.text(HomeStrings.weightCoverage(0, 8)), findsOneWidget);
  });
}

const _dashboard = HomeDashboard(
  activeAnimals: 8,
  monthlyAdditions: 4,
  monthlyRemovals: 2,
  knownLiveWeightKg: 1250,
  animalsWithCurrentWeight: 3,
  animalsWithDailyGain: 2,
  categories: [],
  lots: [],
);
