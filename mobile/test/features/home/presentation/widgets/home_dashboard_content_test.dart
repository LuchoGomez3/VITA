import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('abre la venta del establecimiento activo y recarga al volver', (
    tester,
  ) async {
    final repository = _HomeRepository();
    final cubit = _createCubit(repository);
    await cubit.initialize();
    addTearDown(cubit.close);

    String? routedEstablishmentId;
    String? routedOrigin;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: const Scaffold(
              body: HomeDashboardContent(
                dashboard: _dashboard,
                onEstablishmentSelectionRequested: _noop,
                canViewFinancialInformation: true,
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.livestockSaleRegister,
          builder: (context, state) {
            routedEstablishmentId = state.uri.queryParameters['establecimientoId'];
            routedOrigin = state.uri.queryParameters['origen'];
            return Scaffold(
              body: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cerrar venta'),
              ),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HomeStrings.registerSale));
    await tester.pumpAndSettle();

    expect(routedEstablishmentId, _establishmentId);
    expect(routedOrigin, AppRoutes.livestockSaleHomeOrigin);

    await tester.tap(find.text('Cerrar venta'));
    await tester.pumpAndSettle();

    expect(repository.dashboardRequests, 2);
    expect(repository.establishmentRequests, 1);
  });

  testWidgets('solicita elegir establecimiento antes de registrar la venta', (
    tester,
  ) async {
    final repository = _HomeRepository();
    final cubit = _createCubit(repository);
    await cubit.initialize();
    await cubit.selectEstablishment(null);
    addTearDown(cubit.close);
    var selectionRequests = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: HomeDashboardContent(
              dashboard: _dashboard,
              onEstablishmentSelectionRequested: () => selectionRequests++,
              canViewFinancialInformation: true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(HomeStrings.registerSale));

    expect(selectionRequests, 1);
  });

  testWidgets('recarga la cache al volver de registrar un egreso', (
    tester,
  ) async {
    final repository = _HomeRepository();
    final cubit = _createCubit(repository);
    await cubit.initialize();
    addTearDown(cubit.close);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: const Scaffold(
              body: HomeDashboardContent(
                dashboard: _dashboard,
                onEstablishmentSelectionRequested: _noop,
                canViewFinancialInformation: true,
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expenseRegister,
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cerrar egreso'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HomeStrings.registerExpense));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar egreso'));
    await tester.pumpAndSettle();

    expect(repository.dashboardRequests, 2);
    expect(repository.establishmentRequests, 1);
  });
}

HomeDashboardCubit _createCubit(HomeDashboardRepository repository) {
  return HomeDashboardCubit(
    getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
    getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
  );
}

void _noop() {}

const _establishmentId = 'establishment-id';

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
  int dashboardRequests = 0;
  int establishmentRequests = 0;

  @override
  Future<Result<HomeDashboardSource>> getDashboardSource({
    Set<String>? establishmentIds,
  }) async {
    dashboardRequests++;
    return const Result.success(
      HomeDashboardSource(
        animals: [],
        weighings: [],
        categoryNamesById: {},
        operatingExpensesCents: 0,
      ),
    );
  }

  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async {
    establishmentRequests++;
    return const Result.success({
      _establishmentId: EstablishmentMembership(
        id: _establishmentId,
        name: 'Campo Sur',
        role: UserRole.owner,
      ),
    });
  }
}
