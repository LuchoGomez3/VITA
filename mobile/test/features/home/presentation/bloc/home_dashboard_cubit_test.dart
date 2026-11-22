import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/animals/animal_productive_status.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard_source.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';

void main() {
  test('loads only the first cached establishment on startup', () async {
    final repository = _HomeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await cubit.initialize();

    expect(cubit.state.selectedEstablishmentId, 'farm-id');
    expect(repository.dashboardScopes, [
      {'farm-id'},
    ]);
  });

  test('preserves a manual selection on reload while it remains available', () async {
    final repository = _HomeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.selectEstablishment('south-farm-id');
    await cubit.load();
    expect(cubit.state.selectedEstablishmentId, 'south-farm-id');
    expect(repository.dashboardScopes.last, {'south-farm-id'});

    await cubit.selectEstablishment(null);
    await cubit.load();
    expect(cubit.state.selectedEstablishmentId, isNull);
    expect(repository.dashboardScopes.last, isNull);
  });

  test('selects the first available establishment when the catalog changes', () async {
    final repository = _HomeRepository();
    final memberships = Map.of(repository.establishments);
    repository.establishments.clear();
    final cubit = _cubit(
      repository,
      refreshOfflineData: () async => Result.success(
        PostAuthenticationSummary(establishmentIds: repository.establishments.keys.toList()),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.selectedEstablishmentId, isNull);

    repository.establishments.addAll(memberships);
    await cubit.refresh();
    expect(cubit.state.selectedEstablishmentId, 'farm-id');
    expect(repository.dashboardScopes.last, {'farm-id'});

    repository.establishments.remove('farm-id');
    await cubit.refresh();
    expect(cubit.state.selectedEstablishmentId, 'south-farm-id');
    expect(repository.dashboardScopes.last, {'south-farm-id'});
  });

  test('ignores initial indicators that arrive after a manual selection', () async {
    final repository = _HomeRepository();
    final initialDashboard = Completer<Result<HomeDashboardSource>>();
    repository.pendingDashboard = initialDashboard.future;
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final initialLoad = cubit.initialize();
    await cubit.stream.firstWhere((state) => state.selectedEstablishmentId == 'farm-id');
    repository.pendingDashboard = null;
    await cubit.selectEstablishment('south-farm-id');
    initialDashboard.complete(Result.success(_source(AnimalProductiveStatus.sold)));
    await initialLoad;

    final dashboard = (cubit.state.dashboardState as Data<HomeDashboard>).data;
    expect(cubit.state.selectedEstablishmentId, 'south-farm-id');
    expect(dashboard.activeAnimals, 1);
  });

  test('keeps cached dashboard visible while refresh is in progress', () async {
    final repository = _HomeRepository();
    final syncCompleter = Completer<Result<PostAuthenticationSummary>>();
    final cubit = _cubit(
      repository,
      refreshOfflineData: () => syncCompleter.future,
    );

    await cubit.initialize();

    expect(cubit.state.dashboardState, isA<Data<HomeDashboard>>());
    expect(cubit.state.isRefreshing, isTrue);

    repository.source = _source(AnimalProductiveStatus.sold);
    syncCompleter.complete(
      Result.success(
        PostAuthenticationSummary(establishmentIds: const ['farm-id']),
      ),
    );
    await cubit.stream.firstWhere((state) => !state.isRefreshing);

    final dashboard = (cubit.state.dashboardState as Data<HomeDashboard>).data;
    expect(dashboard.activeAnimals, 0);
    expect(dashboard.monthlyRemovals, 1);
    await cubit.close();
  });

  test('connectivity refresh preserves cache and exposes a sync error', () async {
    final repository = _HomeRepository();
    final connectivity = StreamController<bool>();
    var refreshCalls = 0;
    final cubit = _cubit(
      repository,
      connectivityChanges: connectivity.stream,
      refreshOfflineData: () async {
        refreshCalls += 1;
        return const Result.failure(
          DomainException(
            message: 'Sin conexion.',
            code: DomainErrorCode.offline,
          ),
        );
      },
    );
    await cubit.load();

    connectivity.add(true);
    await cubit.stream.firstWhere(
      (state) => !state.isRefreshing && state.refreshError != null,
    );

    expect(refreshCalls, 1);
    expect(cubit.state.dashboardState, isA<Data<HomeDashboard>>());
    expect(cubit.state.refreshError?.code, DomainErrorCode.offline);
    await connectivity.close();
    await cubit.close();
  });
}

HomeDashboardCubit _cubit(
  _HomeRepository repository, {
  PreparePostAuthentication? refreshOfflineData,
  Stream<bool>? connectivityChanges,
}) {
  return HomeDashboardCubit(
    getHomeDashboardUseCase: GetHomeDashboardUseCase(
      repository,
      now: () => DateTime.utc(2026, 10, 15),
    ),
    getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
    refreshOfflineData: refreshOfflineData,
    connectivityChanges: connectivityChanges,
  );
}

HomeDashboardSource _source(AnimalProductiveStatus status) {
  return HomeDashboardSource(
    animals: [
      HomeDashboardAnimal(
        id: 'animal-id',
        productiveStatus: status,
        createdAt: DateTime.utc(2026, 9),
        deletedAt: null,
        productiveStatusChangedAt: status.isProductiveRemoval ? DateTime.utc(2026, 10, 10) : null,
        categoryId: 'category-id',
        categoryName: 'Vaca',
        lotName: 'Norte',
        initialWeightKg: 300,
        initialWeighingDate: DateTime.utc(2026, 9),
      ),
    ],
    weighings: const [],
    categoryNamesById: const {'category-id': 'Vaca'},
    operatingExpensesCents: 0,
  );
}

class _HomeRepository implements HomeDashboardRepository {
  HomeDashboardSource source = _source(AnimalProductiveStatus.active);
  Future<Result<HomeDashboardSource>>? pendingDashboard;
  final dashboardScopes = <Set<String>?>[];
  final establishments = {
    'farm-id': const EstablishmentMembership(
      id: 'farm-id',
      name: 'Campo Norte',
      role: UserRole.owner,
    ),
    'south-farm-id': const EstablishmentMembership(
      id: 'south-farm-id',
      name: 'Campo Sur',
      role: UserRole.owner,
    ),
  };

  @override
  Future<Result<HomeDashboardSource>> getDashboardSource({
    Set<String>? establishmentIds,
  }) async {
    dashboardScopes.add(establishmentIds);
    final pending = pendingDashboard;
    return pending != null ? await pending : Result.success(source);
  }

  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async => Result.success(
    Map.of(establishments),
  );
}
