import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_success_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('disables establishment action while its flow is unavailable', (
    tester,
  ) async {
    await _pumpSuccessPage(tester, hasEstablishments: false);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(
      find.text(SignUpStrings.configureEstablishmentButton),
      findsOneWidget,
    );
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('allows an account with establishments to continue home', (
    tester,
  ) async {
    await _pumpSuccessPage(tester, hasEstablishments: true);

    expect(find.text(SignUpStrings.goToHomeButton), findsOneWidget);
    await tester.tap(find.text(SignUpStrings.goToHomeButton));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}

Future<void> _pumpSuccessPage(
  WidgetTester tester, {
  required bool hasEstablishments,
}) async {
  final router = GoRouter(
    initialLocation: '/success',
    routes: [
      GoRoute(
        path: '/success',
        builder: (context, state) => SignUpSuccessPage(
          userData: _user,
          hasEstablishments: hasEstablishments,
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
