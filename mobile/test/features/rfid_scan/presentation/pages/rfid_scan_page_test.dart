import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/pages/rfid_scan_page.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';

void main() {
  testWidgets('starts a HID reading from the identification screen', (tester) async {
    final source = HidRfidReadingSource();
    addTearDown(source.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RfidScanPage(
          establishmentId: 'establishment-id',
          createBloc: ({required establishmentId}) => RfidScanBloc(
            readingSource: source,
            validateRfidReadingUseCase: ValidateRfidReadingUseCase(),
            findAnimalByRfidUseCase: FindAnimalByRfidUseCase(
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
  });
}

class _FakeRfidAnimalLookupRepository implements RfidAnimalLookupRepository {
  @override
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async => const Result.success(null);
}
