import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/user_manual/data/parsers/manual_markdown_parser.dart';
import 'package:frontend_mayoral/features/user_manual/domain/entities/manual_section.dart';
import 'package:frontend_mayoral/features/user_manual/domain/use_cases/get_user_manual_use_case.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/cubit/user_manual_cubit.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/pages/user_manual_page.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/pages/user_manual_section_page.dart';
import 'package:frontend_mayoral/features/user_manual/presentation/strings/user_manual_strings.dart';
import 'package:go_router/go_router.dart';

import '../user_manual_fakes.dart';

UserManualCubit Function() _cubitFor(List<UserRole> roles, {FakeUserManualRepository? repository}) =>
    () => UserManualCubit(
      GetUserManualUseCase(
        repository: repository ?? FakeUserManualRepository(),
        readMemberships: () async => [
          for (final (index, role) in roles.indexed) EstablishmentMembership(id: '$index', name: 'Campo', role: role),
        ],
      ),
    );

/// Monta el manual con las rutas reales del índice y del detalle.
Future<void> _pumpManual(WidgetTester tester, UserManualCubit Function() createCubit) async {
  final router = GoRouter(
    initialLocation: AppRoutes.userManual,
    routes: [
      GoRoute(
        path: AppRoutes.userManual,
        builder: (context, state) => UserManualPage(createCubit: createCubit),
      ),
      GoRoute(
        path: AppRoutes.userManualSection,
        builder: (context, state) => UserManualSectionPage(section: state.extra! as ManualSection),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

/// Busca un [RichText] cuyo texto tenga un tramo en negrita igual a [text].
Finder _boldSpan(String text) => find.byWidgetPredicate((widget) {
  if (widget is! RichText) return false;
  var found = false;
  widget.text.visitChildren((span) {
    if (span is TextSpan && span.text == text && span.style?.fontWeight == FontWeight.w700) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
});

void main() {
  group('UserManualPage', () {
    testWidgets('a un dueño le muestra todas sus secciones y marca las que no son para todos', (tester) async {
      await _pumpManual(tester, _cubitFor([UserRole.owner]));

      expect(find.text(UserManualStrings.title), findsOneWidget);
      expect(find.text(UserManualStrings.offlineHint), findsOneWidget);
      expect(find.text('Primeros pasos'), findsOneWidget);
      expect(find.text('Invitar a tu equipo'), findsOneWidget);
      expect(find.text('Crear un establecimiento'), findsOneWidget);
      expect(find.text('Para dueño y administrador'), findsOneWidget);
      expect(find.text('Para dueño'), findsOneWidget);
    });

    testWidgets('a un empleado no le muestra invitar ni crear establecimientos', (tester) async {
      await _pumpManual(tester, _cubitFor([UserRole.employee]));

      expect(find.text('Primeros pasos'), findsOneWidget);
      expect(find.text('Registrar pesajes'), findsOneWidget);
      expect(find.text('Invitar a tu equipo'), findsNothing);
      expect(find.text('Crear un establecimiento'), findsNothing);
      expect(find.text(UserManualStrings.rolesHint({UserRole.employee})), findsOneWidget);
    });

    testWidgets('tocar una sección abre su detalle', (tester) async {
      await _pumpManual(tester, _cubitFor([UserRole.owner]));

      await tester.tap(find.text('Invitar a tu equipo'));
      await tester.pumpAndSettle();

      expect(find.byType(UserManualSectionPage), findsOneWidget);
      expect(find.text('Invitar a tu equipo'), findsOneWidget);
      expect(find.text('Texto de prueba', findRichText: true), findsOneWidget);
      expect(find.text('Para dueño y administrador'), findsOneWidget);
    });

    testWidgets('si no se puede leer el manual ofrece reintentar', (tester) async {
      final repository = FakeUserManualRepository(const Result.failure(DomainException(message: 'sin manual')));
      await _pumpManual(tester, _cubitFor([UserRole.owner], repository: repository));

      expect(find.text(UserManualStrings.loadError), findsOneWidget);

      repository.result = Result.success(sampleSections);
      await tester.tap(find.text(UserManualStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('Primeros pasos'), findsOneWidget);
    });
  });

  group('UserManualSectionPage', () {
    testWidgets('dibuja títulos, listas, negrita y notas', (tester) async {
      final section = ManualMarkdownParser.parseSection('demo', '''
---
titulo: Leer caravanas
roles: owner, admin, employee
---
## Leer una caravana

1. Tocá **Leer**.
2. Acercá el bastón.

- Con **Descartar** vaciás la lista.

> Funciona sin señal.
''');
      await tester.pumpWidget(MaterialApp(home: UserManualSectionPage(section: section)));

      expect(find.text('Leer caravanas'), findsOneWidget);
      expect(find.text('Leer una caravana', findRichText: true), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('•'), findsOneWidget);
      expect(find.text('Tocá Leer.', findRichText: true), findsOneWidget);
      expect(_boldSpan('Leer'), findsOneWidget);
      expect(_boldSpan('Descartar'), findsOneWidget);
      expect(find.text('Funciona sin señal.', findRichText: true), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      // Es general: no lleva la etiqueta de roles.
      expect(find.textContaining('Para '), findsNothing);
    });
  });
}
