import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_sync_badge.dart';
import 'package:frontend_mayoral/features/health/presentation/pages/health_page.dart';

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
}
