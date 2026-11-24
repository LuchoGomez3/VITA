import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_surface_card.dart';

void main() {
  testWidgets('vuelve interactiva toda la superficie cuando recibe onTap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSurfaceCard(
            onTap: () => taps++,
            child: const Text('Contenido'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Contenido'));

    expect(taps, 1);
    expect(find.byType(InkWell), findsOneWidget);
  });
}
