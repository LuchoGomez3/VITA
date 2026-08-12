import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_animal_lookup_repository.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';

void main() {
  group('RfidScanBloc', () {
    late _FakeRfidReadingSource readingSource;
    late _FakeRfidAnimalLookupRepository lookupRepository;
    late RfidScanBloc bloc;

    setUp(() {
      readingSource = _FakeRfidReadingSource();
      lookupRepository = _FakeRfidAnimalLookupRepository();
      bloc = RfidScanBloc(
        readingSource: readingSource,
        validateRfidReadingUseCase: ValidateRfidReadingUseCase(),
        findAnimalByRfidUseCase: FindAnimalByRfidUseCase(lookupRepository),
        establishmentId: 'establishment-id',
      );
      addTearDown(bloc.close);
    });

    test('starts the source and emits listening', () async {
      final expectation = expectLater(
        bloc.stream,
        emits(const RfidScanState.listening()),
      );

      bloc.add(const RfidScanEvent.listeningRequested());

      await expectation;
      expect(readingSource.isReading, isTrue);
    });

    test('stops the source and emits inactive', () async {
      await readingSource.startReading();
      final expectation = expectLater(
        bloc.stream,
        emits(const RfidScanState.inactive()),
      );

      bloc.add(const RfidScanEvent.stopped());

      await expectation;
      expect(readingSource.isReading, isFalse);
    });

    test('emits the result states from the processing flow', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInAnyOrder([
          const RfidScanState.invalid(reading: '123'),
          RfidScanState.found(animal: _identifiedAnimal),
          const RfidScanState.notFound(rfid: '982000412991417'),
          const RfidScanState.timeout(),
          const RfidScanState.error(),
        ]),
      );

      bloc
        ..add(const RfidScanEvent.invalidReadingDetected(reading: '123'))
        ..add(RfidScanEvent.animalFound(animal: _identifiedAnimal))
        ..add(const RfidScanEvent.animalNotFound(rfid: '982000412991417'))
        ..add(const RfidScanEvent.timeoutElapsed())
        ..add(const RfidScanEvent.errorOccurred());

      await expectation;
    });

    test('finds a valid reading in the local repository', () async {
      lookupRepository.animal = _identifiedAnimal;
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const RfidScanState.listening(),
          RfidScanState.found(animal: _identifiedAnimal),
        ]),
      );

      bloc.add(const RfidScanEvent.listeningRequested());
      await Future<void>.delayed(Duration.zero);
      readingSource.addReading('982000412991416');

      await expectation;
    });

    test('emits invalid when the source completes an invalid reading', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const RfidScanState.listening(),
          const RfidScanState.invalid(reading: '98200041299A416'),
        ]),
      );

      bloc.add(const RfidScanEvent.listeningRequested());
      await Future<void>.delayed(Duration.zero);
      readingSource.addReading('98200041299A416');

      await expectation;
      expect(readingSource.isReading, isFalse);

      readingSource.addReading('982000412991416');
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, const RfidScanState.invalid(reading: '98200041299A416'));
    });

    test('stops the source when it reports an error', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const RfidScanState.listening(),
          const RfidScanState.error(),
        ]),
      );

      bloc.add(const RfidScanEvent.listeningRequested());
      await Future<void>.delayed(Duration.zero);
      readingSource.addError(StateError('RFID source failed'));

      await expectation;
      expect(readingSource.isReading, isFalse);

      readingSource.addReading('982000412991416');
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, const RfidScanState.error());
    });
  });
}

final _identifiedAnimal = IdentifiedAnimal(
  id: 'animal-id',
  rfidTagNumber: '982000412991416',
  visualTag: '003 1295',
  sex: IdentifiedAnimalSex.female,
  breed: 'Aberdeen Angus',
  categoryName: 'Ternera',
  lotName: 'La Cumbre',
  updatedAt: DateTime(2025, 3, 14),
);

class _FakeRfidAnimalLookupRepository implements RfidAnimalLookupRepository {
  IdentifiedAnimal? animal;

  @override
  Future<Result<IdentifiedAnimal?>> findByRfidTagNumber({
    required String rfidTagNumber,
    required String establishmentId,
  }) async => Result.success(animal);
}

class _FakeRfidReadingSource implements RfidReadingSource {
  final StreamController<String> _controller = StreamController<String>.broadcast();

  @override
  bool isReading = false;

  @override
  Stream<String> get readings => _controller.stream;

  @override
  Future<void> dispose() => _controller.close();

  @override
  Future<void> startReading() async {
    isReading = true;
  }

  @override
  Future<void> stopReading() async {
    isReading = false;
  }

  void addReading(String reading) {
    _controller.add(reading);
  }

  void addError(Object error) {
    _controller.addError(error);
  }
}
