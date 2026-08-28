import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/financial_access_denied_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/widgets/operating_expense_history_card.dart';

void main() {
  test('el guard evalua el establecimiento solicitado', () async {
    String? requestedId;

    final canAccess = await AppRouter.canAccessFinancialRoute(
      establishmentId: 'establishment-owner',
      getRole: (establishmentId) async {
        requestedId = establishmentId;
        return UserRole.owner;
      },
    );

    expect(requestedId, 'establishment-owner');
    expect(canAccess, isTrue);
  });

  testWidgets('employee no ve movimientos financieros en Home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HomeDashboardCubit(
            getHomeDashboardUseCase: GetHomeDashboardUseCase(_HomeRepository()),
            getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(_HomeRepository()),
          ),
          child: const Scaffold(
            body: HomeDashboardContent(
              dashboard: _dashboard,
              canViewFinancialInformation: false,
              onEstablishmentSelectionRequested: _noop,
            ),
          ),
        ),
      ),
    );

    expect(find.text(HomeStrings.movements), findsNothing);
    expect(find.text(HomeStrings.operatingBalance), findsNothing);
  });

  testWidgets('Home muestra el rol del establecimiento seleccionado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(
          createCubit: _createHomeCubit,
          userName: 'Ernesto',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _createdHomeCubit.selectEstablishment('employee-establishment');
    await tester.pumpAndSettle();

    expect(find.text('${HomeStrings.roleLabel}: Empleado'), findsOneWidget);
  });

  testWidgets('ruta protegida muestra el mensaje financiero requerido', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinancialAccessDeniedPage()));

    expect(find.text(OperatingExpenseStrings.accessDenied), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('tarjeta audita nombre completo y pendiente con texto e icono', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OperatingExpenseHistoryCard(
            expense: OperatingExpense(
              id: 'expense-id',
              establishmentId: 'establishment-id',
              amountCents: 15000000,
              type: OperatingExpenseType.productionCost,
              category: 'sanidad',
              categoryLabel: 'Sanidad',
              supply: 'Vacunas reproductivas',
              date: DateTime(2026, 8, 26),
              loadedByName: 'Juan Pérez',
              createdAt: DateTime.utc(2026, 8, 26),
              updatedAt: DateTime.utc(2026, 8, 26),
              syncStatus: OperatingExpenseSyncStatus.pending,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Juan Pérez'), findsOneWidget);
    expect(find.text(OperatingExpenseStrings.pendingSync), findsOneWidget);
    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    expect(find.text(r'$ 150.000,00'), findsOneWidget);
  });
}

void _noop() {}

late HomeDashboardCubit _createdHomeCubit;

HomeDashboardCubit _createHomeCubit() {
  final repository = _HomeRepository();
  return _createdHomeCubit = HomeDashboardCubit(
    getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
    getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
  );
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
);

class _HomeRepository implements HomeDashboardRepository {
  @override
  Future<Result<HomeDashboard>> getDashboard({Set<String>? establishmentIds}) async => const Result.success(_dashboard);

  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async {
    return const Result.success({
      'employee-establishment': EstablishmentMembership(
        id: 'employee-establishment',
        name: 'Campo Sur',
        role: UserRole.employee,
      ),
    });
  }
}
