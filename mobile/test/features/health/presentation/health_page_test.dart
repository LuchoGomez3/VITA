import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/widgets/app_sync_badge.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/features/health/presentation/pages/health_page.dart';
import 'package:frontend_mayoral/features/health/presentation/strings/health_strings.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('el encabezado muestra el indicador de sincronización que recibe', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HealthPage(syncIndicator: Icon(Icons.cloud_done_outlined, key: Key('sync-indicator'))),
      ),
    );

    expect(find.byKey(const Key('sync-indicator')), findsOneWidget);
    expect(find.byType(AppSyncBadge), findsNothing);
  });

  testWidgets('las tarjetas de ejemplo no abren el registro y el acceso general abre manga', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HealthPage()),
        GoRoute(
          path: AppRoutes.applyVaccination,
          builder: (_, state) => Text('manga=${state.uri.queryParameters['manga']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (_, child) => AppToastHost(child: child!),
      ),
    );

    for (final tab in [HealthStrings.vaccinationsTab, HealthStrings.alertsTab]) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HealthStrings.applyLink).first);
      await tester.pumpAndSettle();
      expect(find.text(HealthStrings.exampleMessage), findsOneWidget);
      expect(find.text('manga=1'), findsNothing);
      await tester.tap(find.text(HealthStrings.exampleMessage));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text(HealthStrings.vaccinationsTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(HealthRegistrationStrings.capture));
    await tester.pumpAndSettle();
    expect(find.text('manga=1'), findsOneWidget);
  });
}
