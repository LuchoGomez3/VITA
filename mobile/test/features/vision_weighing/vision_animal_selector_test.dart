import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/entities/vision_animal.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/repositories/vision_animal_repository.dart';
import 'package:frontend_mayoral/features/vision_weighing/domain/use_cases/get_vision_animal_options.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/strings/vision_weighing_strings.dart';
import 'package:frontend_mayoral/features/vision_weighing/presentation/widgets/vision_animal_selector.dart';
import 'package:go_router/go_router.dart';

class _AnimalRepository implements VisionAnimalRepository {
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
    ],
    establishments: const [VisionEstablishment(id: 'farm-1', name: 'Campo 1')],
  );
}

void main() {
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
