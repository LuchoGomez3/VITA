import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';

void main() {
  testWidgets('aparece arriba con animación y se retira a los tres segundos', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Primero'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final message = find.text('No se pudieron actualizar los datos.');
    final enteringY = tester.getTopLeft(message).dy;
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getTopLeft(message).dy, greaterThan(enteringY));
    expect(tester.getTopLeft(message).dy, lessThan(100));

    await tester.pump(const Duration(milliseconds: 2700));
    expect(message, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pumpAndSettle();
    expect(message, findsNothing);
  });

  testWidgets('reemplaza el aviso y deja navegar y descartarlo con un toque', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Primero'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Segundo'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron actualizar los datos.'), findsNothing);
    final message = find.text('Falta seleccionar un establecimiento.');
    expect(message, findsOneWidget);

    await tester.tap(find.text('Ir a otra pantalla'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Otra pantalla'), findsOneWidget);
    expect(message, findsOneWidget);
    await tester.tap(message);
    await tester.pumpAndSettle();
    expect(message, findsNothing);
    expect(find.text('Otra pantalla'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    builder: (_, child) => AppToastHost(child: child!),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => AppToastHost.show(context, 'No se pudieron actualizar los datos.'),
                child: const Text('Primero'),
              ),
              TextButton(
                onPressed: () => AppToastHost.show(context, 'Falta seleccionar un establecimiento.'),
                child: const Text('Segundo'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('Otra pantalla'))),
                ),
                child: const Text('Ir a otra pantalla'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
