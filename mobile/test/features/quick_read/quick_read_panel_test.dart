import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/cubit/quick_read_cubit.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/strings/quick_read_strings.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/widgets/quick_read_panel.dart';
import 'package:frontend_mayoral/features/quick_read/presentation/widgets/quick_read_tiles.dart';
import 'package:go_router/go_router.dart';

import 'fake_quick_read_repository.dart';

const _rfidA1 = '982000412884005';
const _rfidA2 = '982000412884006';
const _newRfid = '982000999000111';

void main() {
  late FakeQuickReadRepository repository;
  late List<Object?> movedExtras;
  late List<Uri> registerUris;
  var closed = 0;

  setUp(() {
    closed = 0;
    movedExtras = [];
    registerUris = [];
    repository = FakeQuickReadRepository(
      byTag: {
        _rfidA1: quickReadAnimal('a1'),
        _rfidA2: quickReadAnimal('a2', visualTag: '003 1287', rfid: _rfidA2, lotName: 'La Cumbre'),
      },
    );
  });

  Future<void> pumpPanel(WidgetTester tester) async {
    final session = QuickReadCubit(
      resolveTag: ResolveQuickReadTagUseCase(repository),
      refresh: RefreshQuickReadUseCase(repository),
      getEstablishments: GetQuickReadEstablishmentsUseCase(repository),
    );
    addTearDown(session.close);
    await session.start();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: QuickReadPanel(cubit: session, onClose: () => closed++),
          ),
        ),
        GoRoute(
          path: AppRoutes.groupMovement,
          builder: (context, state) {
            movedExtras.add(state.extra);
            return Scaffold(
              body: TextButton(
                onPressed: () => context.pop(const GroupMovementSummary(movedCount: 2, alreadyThereCount: 0)),
                child: const Text('confirmar movimiento'),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.animalRegisterStep1,
          builder: (context, state) {
            registerUris.add(state.uri);
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  final rfid = state.uri.queryParameters['rfid']!;
                  repository.byTag[rfid] = quickReadAnimal('nuevo', visualTag: '005 0001', rfid: rfid);
                  context.pop('nuevo');
                },
                child: const Text('confirmar alta'),
              ),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  /// El bastón HID tipea los dígitos y manda Enter.
  Future<void> readWithStick(WidgetTester tester, String rfid) async {
    for (final digit in rfid.split('')) {
      final key = LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + int.parse(digit));
      await tester.sendKeyDownEvent(key, character: digit);
      await tester.sendKeyUpEvent(key);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  QuickActionTile tile(WidgetTester tester, String label) =>
      tester.widget<QuickActionTile>(find.widgetWithText(QuickActionTile, label));

  testWidgets('espera, una registrada con sus acciones y varias sin "Registrar pesos"', (tester) async {
    await pumpPanel(tester);
    expect(find.text(QuickReadStrings.waitingTitle), findsOneWidget);
    expect(find.text(QuickReadStrings.ready), findsOneWidget);

    await readWithStick(tester, _rfidA1);

    expect(find.text(QuickReadStrings.oneRead), findsOneWidget);
    expect(find.text('004 0028'), findsOneWidget);
    expect(find.text(QuickReadStrings.lastWeight('442')), findsOneWidget);
    expect(find.text(QuickReadStrings.currentLot('El Bajo')), findsOneWidget);
    expect(tile(tester, QuickReadStrings.registerWeight).onTap, isNotNull);
    expect(tile(tester, QuickReadStrings.moveLot).onTap, isNotNull);
    expect(tile(tester, QuickReadStrings.goToRecord).onTap, isNotNull);
    expect(tile(tester, QuickReadStrings.registerTreatment).onTap, isNull);

    await readWithStick(tester, _rfidA2);
    await readWithStick(tester, _newRfid);

    expect(find.text(QuickReadStrings.keepReading), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text(QuickReadStrings.registered(2)), findsOneWidget);
    expect(find.text(QuickReadStrings.unregistered(1)), findsOneWidget);
    expect(find.text(QuickReadStrings.applyTo(2)), findsOneWidget);
    expect(tile(tester, QuickReadStrings.moveLot).onTap, isNotNull);
    expect(tile(tester, QuickReadStrings.registerTreatment).onTap, isNull);
    expect(find.text(QuickReadStrings.registerNewAnimals(1)), findsOneWidget);
    expect(find.textContaining('Registrar pesos'), findsNothing);

    // La lista colapsada muestra solo la última leída.
    expect(find.text(_newRfid), findsOneWidget);
    expect(find.text('003 1287'), findsNothing);
    await tester.tap(find.textContaining(QuickReadStrings.seeList));
    await tester.pumpAndSettle();
    expect(find.text('003 1287'), findsOneWidget);
  });

  testWidgets('mover de lote manda las registradas juntas y avisa al volver', (tester) async {
    await pumpPanel(tester);
    await readWithStick(tester, _rfidA1);
    await readWithStick(tester, _rfidA2);

    await tester.tap(find.text(QuickReadStrings.moveLot));
    await tester.pumpAndSettle();
    expect(movedExtras.single, ['a2', 'a1']);

    await tester.tap(find.text('confirmar movimiento'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(QuickReadStrings.registered(2)), findsOneWidget);
  });

  testWidgets('una caravana sin registrar se da de alta y vuelve como registrada', (tester) async {
    await pumpPanel(tester);
    await readWithStick(tester, _newRfid);

    expect(find.text(QuickReadStrings.unregisteredTitle), findsOneWidget);
    expect(find.text(QuickReadStrings.notInEstablishment('La Sirena')), findsOneWidget);
    expect(tile(tester, QuickReadStrings.registerWeight).onTap, isNull);

    await tester.tap(find.text(QuickReadStrings.registerAnimal));
    await tester.pumpAndSettle();
    expect(registerUris.single.queryParameters, {
      'rfid': _newRfid,
      'establecimientoId': 'campo-1',
      'origen': 'lector',
    });

    await tester.tap(find.text('confirmar alta'));
    await tester.pumpAndSettle();
    expect(find.text('005 0001'), findsOneWidget);
    expect(find.text(QuickReadStrings.whatToDo), findsOneWidget);
  });

  testWidgets('a mano: una caravana desconocida muestra el error; descartar vuelve a esperar', (tester) async {
    await pumpPanel(tester);

    await tester.tap(find.text(QuickReadStrings.manualEntry));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text(QuickReadStrings.add));
    await tester.pumpAndSettle();
    expect(find.textContaining('No hay ningún animal activo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), _rfidA1);
    await tester.tap(find.text(QuickReadStrings.add));
    await tester.pumpAndSettle();
    expect(find.text('004 0028'), findsOneWidget);

    await tester.tap(find.text(QuickReadStrings.discard));
    await tester.pumpAndSettle();
    expect(find.text(QuickReadStrings.waitingTitle), findsOneWidget);
  });

  testWidgets('tocar el fondo cierra el panel solo si no hay caravanas leídas', (tester) async {
    await pumpPanel(tester);

    await tester.tapAt(const Offset(20, 20));
    expect(closed, 1);

    await readWithStick(tester, _rfidA1);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(closed, 1);
    expect(find.text('004 0028'), findsOneWidget);
  });
}
