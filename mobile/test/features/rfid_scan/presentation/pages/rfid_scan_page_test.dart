import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/search_animals_by_rfid_prefix_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/pages/rfid_scan_page.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';

void main() {
  testWidgets('starts a HID reading from the identification screen', (tester) async {
    final source = HidRfidReadingSource();

    await tester.pumpWidget(
      MaterialApp(
        home: RfidScanPage(
          establishmentId: 'establishment-id',
          createBloc: ({required establishmentId}) => RfidScanBloc(
            readingSource: source,
            validateRfidReadingUseCase: const ValidateRfidReadingUseCase(),
            findAnimalByRfidUseCase: const FindAnimalByRfidUseCase(
              _FakeRfidAnimalLookupRepository(),
            ),
            establishmentId: establishmentId,
          ),
          onHidKeyEvent: source.handleKeyEvent,
          onAnimalDetailRequested: (_) {},
          onRegisterAnimalRequested: (_) {},
        ),
      ),
    );

    expect(find.text(RfidScanStrings.startReading), findsOneWidget);

    await tester.tap(find.text(RfidScanStrings.startReading));
    await tester.pump();

    expect(find.text(RfidScanStrings.listeningTitle), findsOneWidget);
    expect(find.text(RfidScanStrings.cancelReading), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('returns the RFID when it is opened as a sale selector', (
    tester,
  ) async {
    final source = HidRfidReadingSource();
    String? selectedRfid;
    late RfidScanBloc bloc;

    await tester.pumpWidget(
      MaterialApp(
        home: RfidScanPage(
          establishmentId: 'establishment-id',
          createBloc: ({required establishmentId}) {
            return bloc = RfidScanBloc(
              readingSource: source,
              validateRfidReadingUseCase: const ValidateRfidReadingUseCase(),
              findAnimalByRfidUseCase: FindAnimalByRfidUseCase(
                _FakeRfidAnimalLookupRepository(animal: _animal),
              ),
              establishmentId: establishmentId,
            );
          },
          onHidKeyEvent: source.handleKeyEvent,
          onAnimalDetailRequested: (_) {},
          onRegisterAnimalRequested: (_) {},
          onAnimalSelected: (rfid) => selectedRfid = rfid,
          returnRfidOnSelection: true,
        ),
      ),
    );

    bloc.add(RfidScanEvent.animalFound(animal: _animal));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (bloc.state.maybeWhen(found: (_) => true, orElse: () => false)) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(RfidScanStrings.selectForSale), findsOneWidget);
    await tester.tap(find.text(RfidScanStrings.selectForSale));

    expect(selectedRfid, _rfid);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('devuelve el animal encontrado cuando el lector se usa como selector', (tester) async {
    final source = HidRfidReadingSource();
    late RfidScanBloc bloc;
    String? selectedId;
    await tester.pumpWidget(
      MaterialApp(
        home: RfidScanPage(
          establishmentId: 'establishment-id',
          createBloc: ({required establishmentId}) => bloc = RfidScanBloc(
            readingSource: source,
            validateRfidReadingUseCase: ValidateRfidReadingUseCase(),
            findAnimalByRfidUseCase: FindAnimalByRfidUseCase(_FakeRfidAnimalLookupRepository()),
            establishmentId: establishmentId,
          ),
          onHidKeyEvent: source.handleKeyEvent,
          onAnimalDetailRequested: (_) {},
          onRegisterAnimalRequested: (_) {},
          onAnimalSelected: (id) => selectedId = id,
        ),
      ),
    );
    bloc.add(
      RfidScanEvent.animalFound(
        animal: IdentifiedAnimal(
          id: 'animal-1',
          rfidTagNumber: '123456789012345',
          visualTag: '1',
          sex: IdentifiedAnimalSex.female,
          breed: 'Angus',
          categoryName: 'Vaca',
          lotName: 'Lote 1',
          updatedAt: DateTime.utc(2026),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(RfidScanStrings.useAnimal));
    await tester.tap(find.text(RfidScanStrings.useAnimal));
    expect(selectedId, 'animal-1');
  });

  testWidgets('muestra coincidencias durante el ingreso manual', (tester) async {
    final source = HidRfidReadingSource();
    final repository = _FakeRfidAnimalLookupRepository(
      suggestions: [_animal],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RfidScanPage(
          establishmentId: 'establishment-id',
          createBloc: ({required establishmentId}) => RfidScanBloc(
            readingSource: source,
            validateRfidReadingUseCase: const ValidateRfidReadingUseCase(),
            findAnimalByRfidUseCase: FindAnimalByRfidUseCase(repository),
            searchAnimalsByRfidPrefixUseCase: SearchAnimalsByRfidPrefixUseCase(repository),
            establishmentId: establishmentId,
          ),
          onHidKeyEvent: source.handleKeyEvent,
          onAnimalDetailRequested: (_) {},
          onRegisterAnimalRequested: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('manualRfidInput')), '982');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('manualRfidSuggestion-animal-id')),
      findsOneWidget,
    );
  });
}

class _FakeRfidAnimalLookupRepository implements RfidAnimalLookupRepository {
  const _FakeRfidAnimalLookupRepository({
    this.animal,
    this.suggestions = const [],
  });

  final IdentifiedAnimal? animal;
  final List<IdentifiedAnimal> suggestions;

  @override
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async => Result.success(animal);

  @override
  Future<Result<List<IdentifiedAnimal>>> findByRfidPrefix({
    required String rfidPrefix,
    required String establishmentId,
  }) async => Result.success(suggestions);
}

const _rfid = '982000000001295';

final _animal = IdentifiedAnimal(
  id: 'animal-id',
  rfidTagNumber: _rfid,
  visualTag: '1295',
  sex: IdentifiedAnimalSex.male,
  breed: 'Angus',
  categoryName: 'Novillo',
  lotName: 'Lote Norte',
  updatedAt: DateTime.utc(2026, 10, 3),
);
