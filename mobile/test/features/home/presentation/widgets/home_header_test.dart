import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_header.dart';

void main() {
  testWidgets('el establecimiento elegido en el menú queda activo en la caja', (tester) async {
    final repository = _FakeHomeDashboardRepository();
    final cubit = HomeDashboardCubit(
      getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
      getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: HomeHeader(
              greeting: 'Hola',
              establishmentMenuController: MenuController(),
              onSelected: cubit.selectEstablishment,
              onCreateEstablishment: () {},
              onIdentifyAnimal: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('${HomeStrings.establishmentPrefix} ${HomeStrings.allEstablishments}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('La Sirena'));
    await tester.pumpAndSettle();

    expect(cubit.state.selectedEstablishmentId, 'establishment-1');
    expect(find.text('${HomeStrings.establishmentPrefix} La Sirena'), findsOneWidget);
  });
}

class _FakeHomeDashboardRepository implements HomeDashboardRepository {
  @override
  Future<Result<Map<String, EstablishmentMembership>>> getEstablishments() async {
    return const Result.success({
      'establishment-1': EstablishmentMembership(id: 'establishment-1', name: 'La Sirena', role: UserRole.owner),
    });
  }

  @override
  Future<Result<HomeDashboard>> getDashboard({Set<String>? establishmentIds}) async {
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
