import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail_enums.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';

import '../../animal_detail_fixture.dart';

void main() {
  testWidgets('historial muestra asignaciones y traslados, pendientes y rechazos en orden cronológico', (tester) async {
    final detail = animalDetailFixture().copyWith(
      lotMovementHistory: [
        AnimalLotMovementEvent(
          id: 'assignment',
          date: DateTime.utc(2026, 10, 3),
          destinationName: 'Sur',
          reason: 'Asignación inicial',
          syncStatus: AnimalSyncStatus.synchronized,
        ),
        AnimalLotMovementEvent(
          id: 'transfer',
          date: DateTime.utc(2026, 10, 4),
          sourceName: 'Sur',
          destinationName: 'Norte',
          reason: 'Rotación',
          syncStatus: AnimalSyncStatus.pending,
        ),
        AnimalLotMovementEvent(
          id: 'rejected',
          date: DateTime.utc(2026, 10, 5),
          sourceName: 'Norte',
          destinationName: 'Este',
          reason: 'Descanso',
          syncStatus: AnimalSyncStatus.rejected,
          syncErrorCode: 'source_conflict',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: AnimalEventHistory(animalDetail: detail)),
        ),
      ),
    );
    expect(find.text(AnimalDetailStrings.initialLotAssignmentTitle), findsOneWidget);
    expect(find.text(AnimalDetailStrings.lotTransferTitle), findsNWidgets(2));
    expect(find.textContaining('Sin lote asignado → Sur'), findsOneWidget);
    expect(find.textContaining('Sur → Norte\nRotación\nPendiente de sincronización'), findsOneWidget);
    expect(find.textContaining('Rechazado por el servidor (source_conflict)'), findsOneWidget);
    expect(
      tester.getTopLeft(find.textContaining('Norte → Este')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Sur → Norte')).dy),
    );
  });
}
