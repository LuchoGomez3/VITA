import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/use_cases/animal_movement_use_cases.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/strings/animal_movement_strings.dart';
import 'package:frontend_mayoral/features/animal_movement/presentation/widgets/animal_movements_tab.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<MovementHistoryEntry> history) async {
    final cubit = MovementHistoryCubit(GetAnimalMovementHistoryUseCase(_FakeRepository(history)));
    addTearDown(cubit.close);
    await cubit.load('a1');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const AnimalMovementsTab()),
        ),
      ),
    );
  }

  testWidgets('muestra el historial con el potrero actual y lo pendiente', (tester) async {
    await pump(tester, [
      MovementHistoryEntry(
        movementId: 'm2',
        fromLotName: 'El Bajo',
        toLotName: 'La Cumbre',
        occurredAt: DateTime(2026, 10, 20),
        reason: 'Rotación pastoreo',
        isPending: true,
      ),
      MovementHistoryEntry(
        movementId: 'm1',
        fromLotName: null,
        toLotName: 'El Bajo',
        occurredAt: DateTime(2026, 3, 1),
        reason: 'Alta',
        isPending: false,
      ),
    ]);

    expect(find.text(AnimalMovementStrings.historyTitle(2).toUpperCase()), findsOneWidget);
    expect(find.text('El Bajo → La Cumbre ${AnimalMovementStrings.currentLot}'), findsOneWidget);
    expect(find.text('${AnimalMovementStrings.noOrigin} → El Bajo'), findsOneWidget);
    expect(find.text(AnimalMovementStrings.pendingSync), findsOneWidget);
    expect(find.text('Rotación pastoreo'), findsOneWidget);
  });

  testWidgets('sin movimientos lo explica', (tester) async {
    await pump(tester, const []);

    expect(find.text(AnimalMovementStrings.historyEmpty), findsOneWidget);
  });
}

class _FakeRepository implements AnimalMovementRepository {
  _FakeRepository(this.history);

  final List<MovementHistoryEntry> history;

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) async => Result.success(history);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
