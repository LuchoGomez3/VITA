import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_success_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('does not overflow on a short screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpSuccessPage(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('shows the registered owner cuit', (tester) async {
    await _pumpSuccessPage(tester);

    expect(find.text('${SignUpStrings.successCuitLabel}  ${_user.cuit}'), findsOneWidget);
  });

  testWidgets('continues to establishment registration after signup', (
    tester,
  ) async {
    await _pumpSuccessPage(tester);

    await tester.tap(find.text(SignUpStrings.configureEstablishmentButton));
    await tester.pumpAndSettle();

    expect(find.text('establishment-register'), findsOneWidget);
  });

  testWidgets('allows postponing establishment registration and going home', (
    tester,
  ) async {
    await _pumpSuccessPage(tester);

    await tester.tap(find.text(SignUpStrings.goToHomeButton));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}

Future<void> _pumpSuccessPage(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/success',
    routes: [
      GoRoute(
        path: '/success',
        builder: (context, state) => SignUpSuccessPage(
          userData: _user,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterEmpty,
        builder: (context, state) => const Scaffold(
          body: Text('establishment-register'),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('home')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

const _user = AppUser(
  id: 'user-id',
  email: 'ana@example.com',
  firstName: 'Ana',
  lastName: 'Perez',
  cuit: '20123456786',
);
