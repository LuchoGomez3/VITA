import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/use_cases/get_animal_movement_history_use_case.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/movement_history_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/tabs/animal_movements_tab.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/entities/movement_entities.dart';
import 'package:frontend_mayoral/features/animal_movement/domain/repositories/animal_movement_repository.dart';

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
        syncStatus: MovementSyncStatus.pending,
        isCurrent: true,
      ),
      MovementHistoryEntry(
        movementId: 'm1',
        fromLotName: null,
        toLotName: 'El Bajo',
        occurredAt: DateTime(2026, 3),
        reason: 'Alta',
        syncStatus: MovementSyncStatus.synchronized,
      ),
    ]);

    expect(find.text(AnimalDetailStrings.historyTitle(2).toUpperCase()), findsOneWidget);
    expect(find.text('El Bajo → La Cumbre ${AnimalDetailStrings.currentLot}'), findsOneWidget);
    expect(find.text('${AnimalDetailStrings.noOrigin} → El Bajo'), findsOneWidget);
    expect(find.text(AnimalDetailStrings.pendingSync), findsOneWidget);
    expect(find.text('Rotación pastoreo'), findsOneWidget);
  });

  testWidgets('sin movimientos lo explica', (tester) async {
    await pump(tester, const []);

    expect(find.text(AnimalDetailStrings.historyEmpty), findsOneWidget);
  });

  testWidgets('la fila actual puede estar después de otra con fecha más reciente', (tester) async {
    await pump(tester, [
      MovementHistoryEntry(
        movementId: 'previo',
        fromLotName: 'La Cumbre',
        toLotName: 'El Bajo',
        occurredAt: DateTime(2026, 6),
        reason: 'Anterior',
        syncStatus: MovementSyncStatus.synchronized,
      ),
      MovementHistoryEntry(
        movementId: 'actual',
        fromLotName: 'El Bajo',
        toLotName: 'La Cumbre',
        occurredAt: DateTime(2026, 5),
        reason: 'Retroactivo',
        syncStatus: MovementSyncStatus.pending,
        isCurrent: true,
      ),
    ]);

    expect(find.text('El Bajo → La Cumbre ${AnimalDetailStrings.currentLot}'), findsOneWidget);
    expect(find.text('La Cumbre → El Bajo ${AnimalDetailStrings.currentLot}'), findsNothing);
  });

  testWidgets('un rechazo se identifica y no se presenta como pendiente o actual', (tester) async {
    await pump(tester, [
      MovementHistoryEntry(
        movementId: 'rechazado',
        fromLotName: 'Origen',
        toLotName: 'Destino',
        occurredAt: DateTime(2026, 10),
        reason: 'Rotación',
        syncStatus: MovementSyncStatus.rejected,
      ),
    ]);

    expect(find.text(AnimalDetailStrings.movementRejected), findsOneWidget);
    expect(find.text(AnimalDetailStrings.movementRejectionHint), findsOneWidget);
    expect(find.text(AnimalDetailStrings.pendingSync), findsNothing);
    expect(find.textContaining(AnimalDetailStrings.currentLot), findsNothing);
  });
}

class _FakeRepository implements AnimalMovementRepository {
  _FakeRepository(this.history);

  final List<MovementHistoryEntry> history;

  @override
  Stream<void> get historyChanges => const Stream.empty();

  @override
  Future<Result<List<MovementHistoryEntry>>> getHistory(String animalId) async => Result.success(history);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
