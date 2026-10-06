import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock/domain/repositories/livestock_establishment_repository.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';
import 'package:frontend_mayoral/features/livestock/presentation/cubit/livestock_access_cubit.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/livestock/presentation/strings/livestock_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('abre directamente la venta para un establecimiento autorizado', (
    tester,
  ) async {
    final router = _router(const [
      EstablishmentMembership(
        id: 'establishment-id',
        name: 'La Esperanza',
        role: UserRole.owner,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('livestockSaleRegisterButton')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saleDestination')), findsOneWidget);
    expect(find.text('establishment-id'), findsOneWidget);
  });

  testWidgets('oculta registrar venta cuando el usuario es employee', (
    tester,
  ) async {
    final router = _router(const [
      EstablishmentMembership(
        id: 'employee-id',
        name: 'Campo Empleado',
        role: UserRole.employee,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('livestockSaleRegisterButton')),
      findsNothing,
    );
  });

  testWidgets('solicita establecimiento cuando hay mas de uno autorizado', (
    tester,
  ) async {
    final router = _router(const [
      EstablishmentMembership(
        id: 'first-id',
        name: 'La Esperanza',
        role: UserRole.admin,
      ),
      EstablishmentMembership(
        id: 'second-id',
        name: 'Los Aromos',
        role: UserRole.owner,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('livestockSaleRegisterButton')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(LivestockStrings.saleEstablishmentSelectionTitle),
      findsOneWidget,
    );
    await tester.tap(find.text('Los Aromos'));
    await tester.pumpAndSettle();

    expect(find.text('second-id'), findsOneWidget);
  });
}

GoRouter _router(List<EstablishmentMembership> establishments) {
  return GoRouter(
    initialLocation: AppRoutes.livestock,
    routes: [
      GoRoute(
        path: AppRoutes.livestock,
        builder: (context, state) => LivestockPage(
          onIdentifyAnimal: () {},
          createAccessCubit: () => LivestockAccessCubit(
            getSaleEstablishments: GetLivestockSaleEstablishmentsUseCase(
              _EstablishmentRepository(establishments),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.livestockSaleRegister,
        builder: (context, state) => Scaffold(
          key: const Key('saleDestination'),
          body: Text(
            state.uri.queryParameters['establecimientoId'] ?? 'missing',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep1,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.field,
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
}

class _EstablishmentRepository implements LivestockEstablishmentRepository {
  const _EstablishmentRepository(this.establishments);

  final List<EstablishmentMembership> establishments;

  @override
  Future<Result<List<EstablishmentMembership>>> getEstablishments() async {
    return Result.success(establishments);
  }
}
