import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';

void main() {
  test('un único establecimiento queda seleccionado para mostrar el KPI inicial', () async {
    final repository = _Repository(['establishment-id']);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.selectedEstablishmentId, 'establishment-id');
    expect(repository.requestedIds, {'establishment-id'});
  });

  test('varios establecimientos conservan el alcance general hasta elegir uno', () async {
    final repository = _Repository(['first', 'second']);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.selectedEstablishmentId, isNull);
    expect(repository.requestedIds, isNull);

    await cubit.selectEstablishment('second');
    await cubit.load();
    expect(cubit.state.selectedEstablishmentId, 'second');
    expect(repository.requestedIds, {'second'});
  });
}

HomeDashboardCubit _cubit(_Repository repository) => HomeDashboardCubit(
  getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
  getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
);

/// Registra el alcance consultado sin depender de SQLite ni de un backend.
class _Repository implements HomeDashboardRepository {
  _Repository(this.ids);

  final List<String> ids;
  Set<String>? requestedIds;

  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async => Result.success({
    for (final id in ids) id: EstablishmentMembership(id: id, name: id, role: UserRole.owner),
  });

  @override
  Future<Result<HomeDashboard>> getDashboard({Set<String>? establishmentIds}) async {
    requestedIds = establishmentIds;
    return const Result.success(
      HomeDashboard(
        activeAnimals: 0,
        monthlyAdditions: 0,
        monthlyRemovals: 0,
        knownLiveWeightKg: 0,
        animalsWithCurrentWeight: 0,
        animalsWithDailyGain: 0,
        categories: [],
        lots: [],
      ),
    );
  }
}
