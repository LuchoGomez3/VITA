import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_animal_selector.dart';
import 'package:go_router/go_router.dart';

class _AnimalRepository implements VisionAnimalRepository {
  int count = 1;
  int establishmentCount = 1;
  @override
  Future<VisionAnimalOptions> getOptions() async => VisionAnimalOptions(
    animals: [
      VisionAnimal(
        id: 'animal-1',
        establishmentId: 'farm-1',
        rfidTagNumber: '123456789012345',
        visualTag: '42',
        updatedAt: DateTime.utc(2026),
      ),
      for (var index = 1; index < count; index++)
        VisionAnimal(
          id: 'animal-${index + 1}',
          establishmentId: 'farm-1',
          rfidTagNumber: '12345678901234$index',
          visualTag: 'visual-$index',
          updatedAt: DateTime.utc(2026),
        ),
      if (establishmentCount > 1)
        VisionAnimal(
          id: 'other-animal',
          establishmentId: 'farm-2',
          rfidTagNumber: '123456789012345',
          visualTag: '42',
          updatedAt: DateTime.utc(2026),
        ),
    ],
    establishments: [
      const VisionEstablishment(id: 'farm-1', name: 'Campo 1'),
      if (establishmentCount > 1) const VisionEstablishment(id: 'farm-2', name: 'Campo 2'),
    ],
  );
}

void main() {
  testWidgets('exige establecimiento y distingue animales con las mismas caravanas', (tester) async {
    final repository = _AnimalRepository()..establishmentCount = 2;
    VisionAnimal? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => VisionAnimalSelector(
                getAnimalOptions: GetVisionAnimalOptions(repository),
                selectedAnimal: selected,
                onSelected: (animal) => setState(() => selected = animal),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    expect(tester.widget<AppTextFormField>(find.byType(AppTextFormField)).enabled, isFalse);
    expect(tester.widget<AppOutlinedButton>(find.byType(AppOutlinedButton)).onPressed, isNull);
    expect(find.text(VisionWeighingStrings.selectEstablishment), findsWidgets);

    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campo 2').last);
    await tester.pumpAndSettle();
    expect(find.text('Caravana RFID: 123456789012345'), findsOneWidget);
    expect(tester.widget<AppTextFormField>(find.byType(AppTextFormField)).enabled, isTrue);
    await tester.ensureVisible(find.text('Caravana RFID: 123456789012345'));
    await tester.tap(find.text('Caravana RFID: 123456789012345'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'other-animal');
    expect(selected?.establishmentId, 'farm-2');

    await tester.ensureVisible(find.byType(DropdownMenu<String>));
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campo 1').last);
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.text('Caravana RFID: 123456789012345'), findsOneWidget);
    await tester.ensureVisible(find.text('Caravana RFID: 123456789012345'));
    await tester.tap(find.text('Caravana RFID: 123456789012345'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'animal-1');
    expect(selected?.establishmentId, 'farm-1');
  });

  testWidgets('permite ingresar una caravana fuera de los cinco animales recientes', (tester) async {
    final repository = _AnimalRepository()..count = 8;
    VisionAnimal? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: VisionAnimalSelector(
              getAnimalOptions: GetVisionAnimalOptions(repository),
              selectedAnimal: null,
              onSelected: (animal) => selected = animal,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Caravana visual: visual-7'), findsNothing);
    await tester.enterText(find.byType(TextFormField), 'visual-7');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Caravana visual: visual-7'));
    expect(selected?.id, 'animal-8');
  });

  testWidgets('vuelve del lector y muestra el animal en la misma revisión', (tester) async {
    VisionAnimal? selected;
    final router = GoRouter(
      initialLocation: '/review',
      routes: [
        GoRoute(
          path: '/review',
          builder: (context, state) => Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => VisionAnimalSelector(
                getAnimalOptions: GetVisionAnimalOptions(_AnimalRepository()),
                selectedAnimal: selected,
                onSelected: (animal) => setState(() => selected = animal),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.rfidScan,
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                Text(state.uri.queryParameters['establecimientoId'] ?? ''),
                TextButton(
                  onPressed: () => context.pop('animal-1'),
                  child: const Text('Confirmar lectura'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text(VisionWeighingStrings.scanAnimal));
    await tester.pumpAndSettle();
    expect(find.text('farm-1'), findsOneWidget);
    await tester.tap(find.text('Confirmar lectura'));
    await tester.pumpAndSettle();

    expect(selected?.id, 'animal-1');
    expect(find.text('Caravana RFID: 123456789012345'), findsOneWidget);
  });
}
