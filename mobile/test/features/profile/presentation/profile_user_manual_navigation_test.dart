import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_repository.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/user_manual/domain/use_cases/get_user_manual_use_case.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/cubit/user_manual_cubit.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/pages/user_manual_page.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/strings/user_manual_strings.dart';
import 'package:go_router/go_router.dart';

import '../../user_manual/user_manual_fakes.dart';

class _EmptyProfileRepository implements ProfileRepository {
  @override
  Future<Result<List<EstablishmentDetails>>> getEstablishments() async => const Result.success([]);
}

Future<void> _pumpProfile(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: [
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => ProfilePage(
          email: 'productor@example.com',
          firstName: 'Ana',
          lastName: 'Pérez',
          cuit: null,
          createCubit: () => ProfileCubit(GetProfileEstablishmentsUseCase(_EmptyProfileRepository())),
          signOut: () async {},
          readAppVersion: () async => (version: '1.0.0', buildNumber: '1'),
          userId: null,
          createAppearanceCubit: (_) => throw UnimplementedError('Sin sesión no hay apariencia'),
        ),
      ),
      GoRoute(
        path: AppRoutes.userManual,
        builder: (context, state) => UserManualPage(
          createCubit: () => UserManualCubit(
            GetUserManualUseCase(repository: FakeUserManualRepository(), readMemberships: () async => const []),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

Finder _row(String label) => find.text(label);

void main() {
  testWidgets('"Manual de usuario" de Sobre la app abre el manual', (tester) async {
    await _pumpProfile(tester);

    await tester.ensureVisible(_row(UserManualStrings.title));
    await tester.pumpAndSettle();
    await tester.tap(_row(UserManualStrings.title));
    await tester.pumpAndSettle();

    expect(find.byType(UserManualPage), findsOneWidget);
    // Sin rol conocido muestra solo las secciones generales.
    expect(find.text('Primeros pasos'), findsOneWidget);
    expect(find.text('Invitar a tu equipo'), findsNothing);
  });

  testWidgets('"Soporte" sigue avisando que llega pronto', (tester) async {
    await _pumpProfile(tester);

    await tester.ensureVisible(_row('Soporte'));
    await tester.pumpAndSettle();
    await tester.tap(_row('Soporte'));
    await tester.pump();

    expect(find.text(ProfileStrings.comingSoonMessage), findsOneWidget);
    expect(find.byType(UserManualPage), findsNothing);
  });
}
