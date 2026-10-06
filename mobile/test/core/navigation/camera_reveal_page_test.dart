import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/navigation/camera_reveal_page.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('la ruta transparente vuelve sin transición adicional', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.push('/camera'),
                child: const Text('Abrir cámara'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/camera',
          pageBuilder: (context, state) => CameraRevealPage(
            state: state,
            child: const ColoredBox(
              key: Key('camera-background'),
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Abrir cámara'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('camera-background')), findsOneWidget);
    expect(tester.takeException(), isNull);

    router.pop();
    await tester.pump();

    expect(find.text('Abrir cámara'), findsOneWidget);
  });
}
