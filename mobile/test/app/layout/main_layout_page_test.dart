import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/layout/main_layout_page.dart';
import 'package:frontend_mayoral/app/layout/main_layout_strings.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/cubit/quick_read_cubit.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/strings/quick_read_strings.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/widgets/quick_read_panel.dart';
import 'package:go_router/go_router.dart';

import '../../features/quick_read/fake_quick_read_repository.dart';

void main() {
  Future<void> pumpLayout(WidgetTester tester) async {
    final repository = FakeQuickReadRepository();
    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainLayoutPage(
            navigationShell: navigationShell,
            createReaderCubit: () => QuickReadCubit(
              resolveTag: ResolveQuickReadTagUseCase(repository),
              refresh: RefreshQuickReadUseCase(repository),
              getEstablishments: GetQuickReadEstablishmentsUseCase(repository),
            ),
          ),
          branches: [
            for (final path in ['/inicio', '/hacienda', '/tramites', '/perfil'])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, _) => Center(child: Text('pantalla $path')),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('el botón central abre el lector y pasa a "Cerrar"; tocarlo de nuevo lo cierra', (tester) async {
    await pumpLayout(tester);
    expect(find.text(QuickReadStrings.read), findsOneWidget);
    expect(find.byIcon(Icons.contactless_outlined), findsOneWidget);
    expect(find.byType(QuickReadPanel), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(QuickReadPanel), findsOneWidget);
    expect(find.text(QuickReadStrings.waitingTitle), findsOneWidget);
    expect(find.text(QuickReadStrings.close), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(QuickReadPanel), findsNothing);
    expect(find.text(QuickReadStrings.read), findsOneWidget);
  });

  testWidgets('cambiar de pestaña o volver atrás cierra el lector', (tester) async {
    await pumpLayout(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(MainLayoutStrings.livestock));
    await tester.pumpAndSettle();
    expect(find.byType(QuickReadPanel), findsNothing);
    expect(find.text('pantalla /hacienda'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(QuickReadPanel), findsNothing);
    expect(find.text('pantalla /hacienda'), findsOneWidget);
  });
}
