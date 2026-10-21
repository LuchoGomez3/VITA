import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/weighing/presentation/pages/weighing_page.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_method_sheet.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';
import 'package:go_router/go_router.dart';

const WeighingSubject _subject = (
  animalId: 'a1',
  establishmentId: 'campo-1',
  visualTag: '004 0028',
  rfidTagNumber: '982000412884005',
  breedAndCategory: 'Hereford · Novillo',
  currentWeightKg: 442,
);

void main() {
  late List<WeighingRequest> requests;
  late List<bool> results;

  Future<void> pumpStarter(WidgetTester tester) async {
    requests = [];
    results = [];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(await startWeighing(context, _subject)),
              child: const Text('pesar'),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.weighing,
          builder: (context, state) {
            requests.add(state.extra! as WeighingRequest);
            return Scaffold(
              body: TextButton(onPressed: () => context.pop(true), child: const Text('guardar')),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('pesar'));
    await tester.pumpAndSettle();
  }

  testWidgets('manual abre el pesaje del animal y devuelve si se guardó', (tester) async {
    await pumpStarter(tester);
    expect(find.text(WeighingStrings.methodSheetTitle), findsOneWidget);

    await tester.tap(find.text(WeighingStrings.methodManual));
    await tester.pumpAndSettle();
    expect(requests.single.animalId, 'a1');
    expect(requests.single.establishmentId, 'campo-1');
    expect(requests.single.initialTab, WeighingCaptureTab.manual);

    await tester.tap(find.text('guardar'));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('foto (IA) avisa que está próximamente y no abre nada', (tester) async {
    await pumpStarter(tester);

    await tester.tap(find.text(WeighingStrings.methodPhoto));
    await tester.pumpAndSettle();

    expect(find.text(WeighingStrings.photoComingSoon), findsOneWidget);
    expect(requests, isEmpty);
    expect(results, [false]);
  });
}
